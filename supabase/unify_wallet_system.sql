-- 0. Ensure Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create Wallets table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tailor_id UUID REFERENCES public.profiles(id) NOT NULL UNIQUE,
  available_balance NUMERIC DEFAULT 0,
  pending_balance NUMERIC DEFAULT 0,
  currency TEXT DEFAULT 'NGN',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Fix wallets to ensure it uses tailor_id (if it was created with user_id)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallets') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wallets' AND column_name = 'user_id') 
           AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wallets' AND column_name = 'tailor_id') THEN
            ALTER TABLE public.wallets RENAME COLUMN user_id TO tailor_id;
        END IF;
    END IF;
END $$;

-- 2. Create Wallet Transactions table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id UUID REFERENCES public.wallets(id) NOT NULL,
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL, -- 'credit_pending', 'release_pending', 'credit_available', 'withdrawal'
  description TEXT,
  reference TEXT,
  order_id UUID, -- References orders(id) if exists
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Fix withdrawal_requests to reference profiles directly for better joins
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'withdrawal_requests') THEN
        -- If user_id exists and tailor_id doesn't (from a previous version), rename it
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'withdrawal_requests' AND column_name = 'user_id') 
           AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'withdrawal_requests' AND column_name = 'tailor_id') THEN
            ALTER TABLE public.withdrawal_requests RENAME COLUMN user_id TO tailor_id;
        END IF;

        -- Apply the foreign key to public.profiles(id)
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'withdrawal_requests' AND column_name = 'tailor_id') THEN
            ALTER TABLE public.withdrawal_requests 
            DROP CONSTRAINT IF EXISTS withdrawal_requests_tailor_id_fkey,
            ADD CONSTRAINT withdrawal_requests_tailor_id_fkey FOREIGN KEY (tailor_id) REFERENCES public.profiles(id);
        END IF;
    END IF;
END $$;

-- 3. Create Referral Transactions table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.referral_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID REFERENCES public.profiles(id),
  referred_user_id UUID REFERENCES public.profiles(id),
  subscription_tier TEXT,
  subscription_amount INTEGER,
  commission_rate DECIMAL,
  commission_amount DECIMAL,
  is_first_month BOOLEAN,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable RLS
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- 5. Basic RLS Policies
DO $$ 
BEGIN
    -- Wallets
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view their own wallet') THEN
        CREATE POLICY "Users can view their own wallet" ON wallets FOR SELECT USING (auth.uid() = tailor_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins can view all wallets') THEN
        CREATE POLICY "Admins can view all wallets" ON wallets FOR SELECT USING (
            EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
        );
    END IF;

    -- Transactions
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view their own transactions') THEN
        CREATE POLICY "Users can view their own transactions" ON wallet_transactions FOR SELECT USING (
            wallet_id IN (SELECT id FROM wallets WHERE tailor_id = auth.uid())
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins can view all transactions') THEN
        CREATE POLICY "Admins can view all transactions" ON wallet_transactions FOR SELECT USING (
            EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
        );
    END IF;
END $$;

-- 6. Trigger to auto-create wallet for new profiles
CREATE OR REPLACE FUNCTION public.handle_new_user_wallet()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.wallets (tailor_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created_wallet ON auth.users;
CREATE TRIGGER on_auth_user_created_wallet
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user_wallet();

-- Fill wallets for existing users
INSERT INTO public.wallets (tailor_id)
SELECT id FROM auth.users ON CONFLICT DO NOTHING;

-- 7. Drop and Redefine increment_wallet_balance
DROP FUNCTION IF EXISTS public.increment_wallet_balance(uuid, decimal);
DROP FUNCTION IF EXISTS public.increment_wallet_balance(uuid, numeric);

CREATE OR REPLACE FUNCTION public.increment_wallet_balance(user_id UUID, amount NUMERIC)
RETURNS VOID AS $$
DECLARE
  v_wallet_id UUID;
BEGIN
  -- Get the wallet ID (Ensure it exists)
  SELECT id INTO v_wallet_id FROM public.wallets WHERE tailor_id = user_id;
  
  -- If for some reason the wallet doesn't exist, create it
  IF v_wallet_id IS NULL THEN
    INSERT INTO public.wallets (tailor_id) VALUES (user_id)
    ON CONFLICT (tailor_id) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_wallet_id;
  END IF;

  -- Update Balance in the 'wallets' table (Available Balance)
  UPDATE public.wallets
  SET 
    available_balance = COALESCE(available_balance, 0) + COALESCE(amount, 0),
    updated_at = NOW()
  WHERE id = v_wallet_id;

  -- Log Transaction in the 'wallet_transactions' table
  IF COALESCE(amount, 0) > 0 THEN
    INSERT INTO public.wallet_transactions (wallet_id, amount, type, description)
    VALUES (v_wallet_id, amount, 'credit_available', 'Referral Commission');
  END IF;

  -- (Backward Compatibility) Also update profiles.wallet_balance
  UPDATE public.profiles
  SET wallet_balance = COALESCE(wallet_balance, 0) + COALESCE(amount, 0)
  WHERE id = user_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Migrating any existing balance from profiles to wallets (Safely idempotent)
UPDATE public.wallets w
SET available_balance = COALESCE(w.available_balance, 0) + COALESCE(p.wallet_balance, 0)
FROM public.profiles p
WHERE w.tailor_id = p.id 
AND p.wallet_balance > 0;

-- Reset migrated balances to avoid double counting if script is re-run (optional but safer)
-- UPDATE public.profiles SET wallet_balance = 0 WHERE wallet_balance > 0;
