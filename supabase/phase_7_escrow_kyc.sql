-- Phase 7: Escrow, Wallets, KYC, and Admin capabilities

-- 1. Create Admins table to secure the Admin Panel
CREATE TABLE IF NOT EXISTS admins (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  role TEXT DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Protect Admins
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view admins" ON admins FOR SELECT USING (auth.uid() = id);

-- 2. Wallets for Tailors
CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tailor_id UUID REFERENCES auth.users(id) NOT NULL UNIQUE,
  available_balance NUMERIC DEFAULT 0,
  pending_balance NUMERIC DEFAULT 0,
  currency TEXT DEFAULT 'NGN',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
-- Tailors can view their own wallet
CREATE POLICY "Tailors can view their own wallet" ON wallets FOR SELECT USING (auth.uid() = tailor_id);

-- 3. Wallet Transactions History
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id UUID REFERENCES wallets(id) NOT NULL,
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL, -- 'credit_pending', 'release_pending', 'credit_available', 'withdrawal'
  description TEXT,
  reference TEXT,
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
-- Tailors can view their own transactions through the wallet join
CREATE POLICY "Tailors can view their own transactions" ON wallet_transactions FOR SELECT USING (
  wallet_id IN (SELECT id FROM wallets WHERE tailor_id = auth.uid())
);

-- 4. Withdrawal Requests
CREATE TABLE IF NOT EXISTS withdrawal_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tailor_id UUID REFERENCES auth.users(id) NOT NULL,
  amount NUMERIC NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'paid'
  bank_name TEXT,
  account_number TEXT,
  account_name TEXT,
  admin_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  processed_at TIMESTAMPTZ
);

ALTER TABLE withdrawal_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tailors can manage their withdrawals" ON withdrawal_requests FOR ALL USING (auth.uid() = tailor_id);
-- Admins can view/update all
CREATE POLICY "Admins can manage withdrawals" ON withdrawal_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM admins WHERE id = auth.uid())
);

-- 5. KYC & Profile Enhancements for Tailors
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_kyc_verified BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS kyc_document_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS offers_measurement_help BOOLEAN DEFAULT false;

-- 6. Customer Profiles (for Measurements)
CREATE TABLE IF NOT EXISTS customer_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) UNIQUE, -- If they sign up on web app
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone_number TEXT,
  measurements JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE customer_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Customers can manage their own profile" ON customer_profiles FOR ALL USING (auth.uid() = user_id);
-- Public can view tailors but only tailors/themselves can view client measurements (simplified to public for ease of marketplace matching)
CREATE POLICY "Public can view customer profiles" ON customer_profiles FOR SELECT USING (true);


-- 7. Trigger to auto-create wallet for new profiles
CREATE OR REPLACE FUNCTION public.handle_new_tailor_wallet()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.wallets (tailor_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: We assume only tailors exist in profiles table currently. 
-- In a real scenario you filter by role, but here we just auto-create it.
DROP TRIGGER IF EXISTS on_auth_user_created_wallet ON auth.users;
CREATE TRIGGER on_auth_user_created_wallet
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_tailor_wallet();

-- Fill wallets for existing users
INSERT INTO public.wallets (tailor_id)
SELECT id FROM auth.users ON CONFLICT DO NOTHING;

-- 8. RPC: Credit Wallet for Escrow
CREATE OR REPLACE FUNCTION public.escrow_credit_wallet(
  p_tailor_id UUID,
  p_available_amount NUMERIC,
  p_pending_amount NUMERIC,
  p_reference TEXT,
  p_request_id UUID
)
RETURNS VOID AS $$
DECLARE
  v_wallet_id UUID;
  v_order_id UUID;
BEGIN
  -- Get the wallet ID
  SELECT id INTO v_wallet_id FROM public.wallets WHERE tailor_id = p_tailor_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Wallet not found for tailor %', p_tailor_id;
  END IF;

  -- Get the linked order ID from the marketplace request
  SELECT order_id INTO v_order_id FROM public.marketplace_requests WHERE id = p_request_id;

  -- Update balances
  UPDATE public.wallets
  SET 
    available_balance = available_balance + p_available_amount,
    pending_balance = pending_balance + p_pending_amount,
    updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Log available credit
  IF p_available_amount > 0 THEN
    INSERT INTO public.wallet_transactions (wallet_id, amount, type, description, reference, order_id)
    VALUES (v_wallet_id, p_available_amount, 'credit_available', 'Upfront 50% payout from accepted quote', p_reference, v_order_id);
  END IF;

  -- Log pending credit
  IF p_pending_amount > 0 THEN
    INSERT INTO public.wallet_transactions (wallet_id, amount, type, description, reference, order_id)
    VALUES (v_wallet_id, p_pending_amount, 'credit_pending', 'Escrow 50% pending completion', p_reference, v_order_id);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 9. RPC: Release Escrow (when order is delivered)
CREATE OR REPLACE FUNCTION public.escrow_release_pending(
  p_order_id UUID
)
RETURNS VOID AS $$
DECLARE
  v_request_id UUID;
  v_tailor_id UUID;
  v_wallet_id UUID;
  v_amount NUMERIC;
BEGIN
  -- Get the marketplace request and tailor
  SELECT id, tailor_id INTO v_request_id, v_tailor_id 
  FROM public.marketplace_requests 
  WHERE order_id = p_order_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Marketplace request not found for order %', p_order_id;
  END IF;

  -- Get the wallet
  SELECT id INTO v_wallet_id FROM public.wallets WHERE tailor_id = v_tailor_id;

  -- Find the exact pending transaction amount for this order
  SELECT sum(amount) INTO v_amount 
  FROM public.wallet_transactions 
  WHERE order_id = p_order_id AND type = 'credit_pending';

  IF v_amount IS NULL OR v_amount <= 0 THEN
    RAISE EXCEPTION 'No pending funds found for this order';
  END IF;

  -- Deduct pending, Add to available
  UPDATE public.wallets
  SET 
    pending_balance = pending_balance - v_amount,
    available_balance = available_balance + v_amount,
    updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Log the release
  INSERT INTO public.wallet_transactions (wallet_id, amount, type, description, order_id)
  VALUES (v_wallet_id, v_amount, 'release_pending', 'Escrow funds released for completed order', p_order_id);

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

