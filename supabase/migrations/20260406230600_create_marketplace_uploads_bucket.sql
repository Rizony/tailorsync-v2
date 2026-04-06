-- Attempt to insert the 'marketplace_uploads' bucket if it doesn't already exist.
-- Set it to public so that the URLs are accessible to Tailors and the Web App without signed tokens.
INSERT INTO storage.buckets (id, name, public)
VALUES ('marketplace_uploads', 'marketplace_uploads', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Drop existing policies if they exist to prevent conflicts on re-runs
DROP POLICY IF EXISTS "Public Marketplace Uploads Viewing" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload to marketplace_uploads" ON storage.objects;

-- Allow public viewing of documents (e.g. Profile avatars and order reference photos)
CREATE POLICY "Public Marketplace Uploads Viewing"
ON storage.objects FOR SELECT
USING ( bucket_id = 'marketplace_uploads' );

-- Allow authenticated users to upload their own images
-- This covers both profile pictures (avatars/) and marketplace order requests (requests/)
CREATE POLICY "Authenticated users can upload to marketplace_uploads"
ON storage.objects FOR INSERT 
TO authenticated
WITH CHECK (
  bucket_id = 'marketplace_uploads' 
);

-- Note: We are allowing any authenticated user to insert. If you want to enforce that users 
-- can only upload to or manage their own specific folder structures, you can modify the WITH CHECK 
-- above (e.g., (storage.foldername(name))[1] = auth.uid()::text or similar access controls).
