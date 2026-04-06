-- Migration to add tailored profile filtering capabilities: tailor type and GPS coordinates

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS tailor_type text DEFAULT 'Unisex',
ADD COLUMN IF NOT EXISTS latitude double precision,
ADD COLUMN IF NOT EXISTS longitude double precision;

-- We don't add specific restrictions to allow tailors to freely update their types and locations.
-- Recreate the full view of the profiles if there is any view depending on it, but typical supabase schemas don't require this.
