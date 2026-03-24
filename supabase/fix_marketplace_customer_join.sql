-- Fix PostgREST join discovery for customer_id
-- Currently, customer_id references auth.users(id), which prevents automatic joins with public.profiles.

ALTER TABLE public.marketplace_requests
DROP CONSTRAINT IF EXISTS marketplace_requests_customer_id_fkey;

ALTER TABLE public.marketplace_requests
ADD CONSTRAINT marketplace_requests_customer_id_fkey 
FOREIGN KEY (customer_id) 
REFERENCES public.profiles(id);

-- Ensure tailor_id also has a consistent reference and name
ALTER TABLE public.marketplace_requests
DROP CONSTRAINT IF EXISTS marketplace_requests_tailor_id_fkey;

ALTER TABLE public.marketplace_requests
ADD CONSTRAINT marketplace_requests_tailor_id_fkey 
FOREIGN KEY (tailor_id) 
REFERENCES public.profiles(id);
