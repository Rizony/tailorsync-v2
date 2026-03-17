-- Marketplace payments + platform commission (Needlix 10%)

-- Track payment state for each marketplace request
ALTER TABLE public.marketplace_requests
ADD COLUMN IF NOT EXISTS payment_status text NOT NULL DEFAULT 'unpaid', -- unpaid, pending, paid, failed, refunded
ADD COLUMN IF NOT EXISTS paid_at timestamp with time zone;

-- Record verified payments (webhooks write with service role)
CREATE TABLE IF NOT EXISTS public.marketplace_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES public.marketplace_requests(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES auth.users(id),
  tailor_id uuid NOT NULL REFERENCES public.profiles(id),
  provider text NOT NULL, -- paystack | flutterwave
  reference text NOT NULL UNIQUE,
  amount numeric NOT NULL, -- major currency units (e.g., Naira)
  commission_rate numeric NOT NULL DEFAULT 0.10,
  commission_amount numeric NOT NULL DEFAULT 0,
  net_amount numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending', -- pending, paid, failed, refunded
  raw jsonb,
  created_at timestamp with time zone DEFAULT now()
);

-- Optional: simple ledger for platform revenue
CREATE TABLE IF NOT EXISTS public.platform_revenue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text NOT NULL, -- marketplace_payment, referral, etc.
  source_id uuid,
  amount numeric NOT NULL,
  currency text NOT NULL DEFAULT 'NGN',
  created_at timestamp with time zone DEFAULT now()
);

