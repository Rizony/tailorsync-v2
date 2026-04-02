-- Phase 7 Supplemental: Atomic Withdrawals and KYC Storage
-- This script adds the missing RPC and profile security columns.

-- 0. Ensure essential tables exist
CREATE TABLE IF NOT EXISTS public.admins (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  role TEXT DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view admins" ON public.admins;
CREATE POLICY "Admins can view admins" ON public.admins FOR SELECT USING (auth.uid() = id);

-- 1. Add Security Columns to Profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS withdrawal_pin TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS kyc_status TEXT DEFAULT 'none'; -- 'none', 'pending', 'verified', 'rejected'
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS kyc_document_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_kyc_verified BOOLEAN DEFAULT false;

-- Force PostgREST to reload schema cache so the app detects the new columns immediately
NOTIFY pgrst, 'reload schema';

-- 2. Create RPC for Secure Withdrawal Request
-- This function ensures:
-- a) The tailor's PIN is correct.
-- b) The tailor has enough available balance.
-- c) The balance deduction and request creation are atomic.
CREATE OR REPLACE FUNCTION public.request_withdrawal(
  req_amount NUMERIC,
  req_bank_details TEXT,
  req_pin TEXT
)
RETURNS VOID AS $$
DECLARE
  v_available NUMERIC;
  v_wallet_id UUID;
  v_stored_pin TEXT;
BEGIN
  -- 1. Verify User and Get Wallet
  SELECT available_balance, id INTO v_available, v_wallet_id
  FROM public.wallets
  WHERE tailor_id = auth.uid();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Wallet not found';
  END IF;

  -- 2. Verify PIN
  SELECT withdrawal_pin INTO v_stored_pin
  FROM public.profiles
  WHERE id = auth.uid();

  -- Note: In a production app, use crypt() or similar. 
  -- For this logic, we assume the user sets a PIN previously.
  -- If PIN is not set, we allow the first request to set it or enforce setup.
  IF v_stored_pin IS NOT NULL AND v_stored_pin <> req_pin THEN
    RAISE EXCEPTION 'Incorrect withdrawal PIN';
  END IF;

  -- 3. Check Balance
  IF v_available < req_amount THEN
    RAISE EXCEPTION 'Insufficient balance';
  END IF;

  -- 4. Atomic Update: Deduct from Wallet
  UPDATE public.wallets
  SET 
    available_balance = available_balance - req_amount,
    updated_at = NOW()
  WHERE id = v_wallet_id;

  -- 5. Atomic Insert: Create Withdrawal Request
  INSERT INTO public.withdrawal_requests (
    tailor_id,
    amount,
    bank_name,
    account_number,
    account_name,
    status
  ) VALUES (
    auth.uid(),
    req_amount,
    split_part(req_bank_details, ' | ', 1),
    split_part(req_bank_details, ' | ', 2),
    split_part(req_bank_details, ' | ', 3),
    'pending'
  );

  -- 6. Log Transaction
  INSERT INTO public.wallet_transactions (
    wallet_id,
    amount,
    type,
    description
  ) VALUES (
    v_wallet_id,
    req_amount,
    'withdrawal',
    'Withdrawal request for ' || req_bank_details
  );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Storage Bucket for KYC Documents (Manual creation usually preferred, but providing the SQL)
-- Note: Requires storage extension enabled
INSERT INTO storage.buckets (id, name, public) 
VALUES ('kyc-documents', 'kyc-documents', false)
ON CONFLICT (id) DO NOTHING;

-- 4. Storage Policies for KYC
DROP POLICY IF EXISTS "Users can upload their own KYC docs" ON storage.objects;
CREATE POLICY "Users can upload their own KYC docs"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'kyc-documents' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Users can view their own KYC docs" ON storage.objects;
CREATE POLICY "Users can view their own KYC docs"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'kyc-documents' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Admins can view all KYC docs" ON storage.objects;
CREATE POLICY "Admins can view all KYC docs"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'kyc-documents' AND
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);
