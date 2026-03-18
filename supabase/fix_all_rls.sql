-- Comprehensive Fix for Marketplace Requests RLS

-- 1. Ensure RLS is enabled
ALTER TABLE public.marketplace_requests ENABLE ROW LEVEL SECURITY;

-- 2. Grant permissions to both roles to ensure they can perform the operations
GRANT ALL ON TABLE public.marketplace_requests TO anon, authenticated;

-- 3. Recreate policies for authenticated clients
DROP POLICY IF EXISTS "Clients can view their own requests" ON public.marketplace_requests;
CREATE POLICY "Clients can view their own requests" ON public.marketplace_requests
  FOR SELECT USING (auth.uid() = customer_id);

DROP POLICY IF EXISTS "Clients can insert their own requests" ON public.marketplace_requests;
CREATE POLICY "Clients can insert their own requests" ON public.marketplace_requests
  FOR INSERT WITH CHECK (customer_id IS NULL OR auth.uid() = customer_id);

DROP POLICY IF EXISTS "Clients can update their own requests" ON public.marketplace_requests;
CREATE POLICY "Clients can update their own requests" ON public.marketplace_requests
  FOR UPDATE USING (auth.uid() = customer_id);

-- 4. Recreate policy for anonymous (guest) users
DROP POLICY IF EXISTS "Public can insert requests" ON public.marketplace_requests;
CREATE POLICY "Public can insert requests" ON public.marketplace_requests
  FOR INSERT WITH CHECK (customer_id IS NULL);

-- 5. Keep tailors' access (from original setup)
DROP POLICY IF EXISTS "Tailors can manage their requests" ON public.marketplace_requests;
CREATE POLICY "Tailors can manage their requests" ON public.marketplace_requests
  FOR ALL USING (auth.uid() = tailor_id);
