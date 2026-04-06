-- Attempt to insert the 'kyc-documents' bucket if it doesn't already exist.
-- Set it to public so that the URLs are accessible to Admins without needing signed tokens.
INSERT INTO storage.buckets (id, name, public)
VALUES ('kyc-documents', 'kyc-documents', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Drop existing policies if they exist to prevent conflicts on re-runs
DROP POLICY IF EXISTS "Public KYC Document Viewing" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own KYC documents" ON storage.objects;

-- Allow public viewing of documents (since the bucket is public, this enforces reads)
CREATE POLICY "Public KYC Document Viewing"
ON storage.objects FOR SELECT
USING ( bucket_id = 'kyc-documents' );

-- Allow authenticated users to upload their own documents to their specific folder
CREATE POLICY "Users can upload their own KYC documents"
ON storage.objects FOR INSERT 
TO authenticated
WITH CHECK (
  bucket_id = 'kyc-documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
