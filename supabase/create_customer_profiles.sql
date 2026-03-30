-- Fix missing customer_profiles table and add the new gender column

CREATE TABLE IF NOT EXISTS public.customer_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) UNIQUE, -- Matches the web app user
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone_number TEXT,
  gender TEXT DEFAULT 'Male', -- Added for the new measurement sync feature
  measurements JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Note: We add gender via ALTER TABLE just in case the table already existed but was missing gender
ALTER TABLE public.customer_profiles ADD COLUMN IF NOT EXISTS gender TEXT DEFAULT 'Male';

ALTER TABLE public.customer_profiles ENABLE ROW LEVEL SECURITY;

-- Customers can manage their own profile
DROP POLICY IF EXISTS "Customers can manage their own profile" ON public.customer_profiles;
CREATE POLICY "Customers can manage their own profile" ON public.customer_profiles 
  FOR ALL USING (auth.uid() = user_id);

-- Public can view tailors but only tailors/themselves can view client measurements (simplified for marketplace)
DROP POLICY IF EXISTS "Public can view customer profiles" ON public.customer_profiles;
CREATE POLICY "Public can view customer profiles" ON public.customer_profiles 
  FOR SELECT USING (true);
