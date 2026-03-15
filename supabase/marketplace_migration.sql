-- Add marketplace fields to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_available BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS specialties TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS rating NUMERIC DEFAULT 5.0,
ADD COLUMN IF NOT EXISTS public_profile_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS years_of_experience INTEGER DEFAULT 0;

-- Create marketplace_requests table
CREATE TABLE IF NOT EXISTS public.marketplace_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tailor_id uuid NOT NULL REFERENCES public.profiles(id),
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_phone text,
  description text NOT NULL,
  status text NOT NULL DEFAULT 'pending', -- pending, accepted, rejected, completed
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT marketplace_requests_pkey PRIMARY KEY (id)
);

-- Enable RLS for marketplace_requests
ALTER TABLE public.marketplace_requests ENABLE ROW LEVEL SECURITY;

-- Policies for marketplace_requests
CREATE POLICY "Tailors can view their own requests" ON public.marketplace_requests
  FOR SELECT USING (auth.uid() = tailor_id);

CREATE POLICY "Public can insert requests" ON public.marketplace_requests
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Tailors can update their own requests" ON public.marketplace_requests
  FOR UPDATE USING (auth.uid() = tailor_id);

-- Update RLS for profiles to allow public viewing of enabled profiles
CREATE POLICY "Public can view enabled tailor profiles" ON public.profiles
  FOR SELECT USING (public_profile_enabled = true);
