-- Fix for Row Level Security blocking guest job requests

-- 1. Ensure the anon role has permission to insert
GRANT INSERT ON TABLE public.marketplace_requests TO anon;
GRANT SELECT ON TABLE public.marketplace_requests TO anon;

-- 2. Create the explicit policy for anonymous users
DROP POLICY IF EXISTS "Public can insert requests" ON public.marketplace_requests;

CREATE POLICY "Public can insert requests" 
ON public.marketplace_requests
FOR INSERT 
TO anon
WITH CHECK (customer_id IS NULL);
