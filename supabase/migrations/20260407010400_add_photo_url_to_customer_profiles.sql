-- Add photo_url and email fields to customer_profiles to support the web profile updates
ALTER TABLE public.customer_profiles
ADD COLUMN IF NOT EXISTS photo_url text,
ADD COLUMN IF NOT EXISTS email text;

-- Force PostgREST to reload its schema cache so the API recognizes these new columns immediately
NOTIFY pgrst, 'reload schema';
