-- Enable client portal for marketplace requests:
-- - Tie each request to an authenticated client via customer_id
-- - Allow clients to SELECT/UPDATE their own requests (e.g., for rating/payment status)

ALTER TABLE public.marketplace_requests
ADD COLUMN IF NOT EXISTS customer_id uuid REFERENCES auth.users(id);

-- Client-provided request details (optional)
ALTER TABLE public.marketplace_requests
ADD COLUMN IF NOT EXISTS item_quantity integer,
ADD COLUMN IF NOT EXISTS image_urls text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS reference_links text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS customer_whatsapp text;

-- Backfill is optional. If you have old requests, they will remain visible to tailors only.
-- Clients should create new requests while logged in to populate customer_id.

ALTER TABLE public.marketplace_requests ENABLE ROW LEVEL SECURITY;

-- Clients can view their own requests
DROP POLICY IF EXISTS "Clients can view their own requests" ON public.marketplace_requests;
CREATE POLICY "Clients can view their own requests" ON public.marketplace_requests
  FOR SELECT USING (auth.uid() = customer_id);

-- Clients can insert their own requests (customer_id must match)
DROP POLICY IF EXISTS "Clients can insert their own requests" ON public.marketplace_requests;
CREATE POLICY "Clients can insert their own requests" ON public.marketplace_requests
  FOR INSERT WITH CHECK (customer_id IS NULL OR auth.uid() = customer_id);

-- Keep anonymous visitors working: allow public insert when no customer_id is provided.
DROP POLICY IF EXISTS "Public can insert requests" ON public.marketplace_requests;
CREATE POLICY "Public can insert requests" ON public.marketplace_requests
  FOR INSERT WITH CHECK (customer_id IS NULL);

-- Clients can update their own requests (for future fields like ratings / confirmations)
DROP POLICY IF EXISTS "Clients can update their own requests" ON public.marketplace_requests;
CREATE POLICY "Clients can update their own requests" ON public.marketplace_requests
  FOR UPDATE USING (auth.uid() = customer_id);

-- Storage notes (manual step in Supabase Dashboard):
-- 1) Create a public bucket named: marketplace_uploads
-- 2) Add policies so authenticated users can upload to their own folder prefix if you want it locked down.
--    For quick start, you can keep the bucket public while you iterate.

