-- Update the escrow_credit_wallet RPC to accept dynamic descriptions for transparency
-- This allows the Paystack webhook to explicitly explain the 10% platform fee.

CREATE OR REPLACE FUNCTION public.escrow_credit_wallet(
  p_tailor_id UUID,
  p_available_amount NUMERIC,
  p_pending_amount NUMERIC,
  p_reference TEXT,
  p_request_id UUID,
  p_available_desc TEXT DEFAULT 'Upfront 50% payout from accepted quote',
  p_pending_desc TEXT DEFAULT 'Escrow 50% pending completion'
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
    VALUES (v_wallet_id, p_available_amount, 'credit_available', p_available_desc, p_reference, v_order_id);
  END IF;

  -- Log pending credit
  IF p_pending_amount > 0 THEN
    INSERT INTO public.wallet_transactions (wallet_id, amount, type, description, reference, order_id)
    VALUES (v_wallet_id, p_pending_amount, 'credit_pending', p_pending_desc, p_reference, v_order_id);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
