-- 1. Create a function to generate a unique referral code
CREATE OR REPLACE FUNCTION public.generate_referral_code(name_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  base_code TEXT;
  new_code TEXT;
  is_unique BOOLEAN := false;
BEGIN
  -- Take up to first 4 letters of name, fallback to 'USER'
  base_code := UPPER(REGEXP_REPLACE(COALESCE(name_input, 'USER'), '[^a-zA-Z]', '', 'g'));
  IF LENGTH(base_code) < 3 THEN
    base_code := 'USER';
  ELSE
    base_code := SUBSTRING(base_code FROM 1 FOR 4);
  END IF;

  -- Loop until we find a unique code
  WHILE NOT is_unique LOOP
    new_code := base_code || floor(random() * 9000 + 1000)::text;
    
    -- Check if it exists
    PERFORM 1 FROM public.profiles WHERE referral_code = new_code;
    IF NOT FOUND THEN
      is_unique := true;
    END IF;
  END LOOP;

  RETURN new_code;
END;
$$;

-- 2. Update handle_new_user trigger to properly link referred_by and generate referral_code
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  _referrer_id UUID;
  _new_referral_code TEXT;
  _referred_by_code TEXT;
BEGIN
  -- Extract passed referral code if any
  _referred_by_code := new.raw_user_meta_data->>'referred_by';

  -- Lookup referrer_id if a code was passed
  IF _referred_by_code IS NOT NULL AND _referred_by_code != '' THEN
    SELECT id INTO _referrer_id
    FROM public.profiles
    WHERE UPPER(referral_code) = UPPER(_referred_by_code);
  END IF;

  -- Generate referral code for this new user
  _new_referral_code := public.generate_referral_code(new.raw_user_meta_data->>'full_name');

  INSERT INTO public.profiles (
    id, 
    full_name, 
    created_at, 
    referrer_id, 
    referral_code
  )
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    now(),
    _referrer_id,
    _new_referral_code
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    referrer_id = COALESCE(public.profiles.referrer_id, EXCLUDED.referrer_id),
    referral_code = COALESCE(public.profiles.referral_code, EXCLUDED.referral_code);
    
  RETURN new;
END;
$$;

-- 3. Backfill missing referral codes and referrer_ids for existing users
DO $$
DECLARE
  r RECORD;
  _ref_id UUID;
BEGIN
  -- Generate codes for users without one
  FOR r IN SELECT id, full_name FROM public.profiles WHERE referral_code IS NULL LOOP
    UPDATE public.profiles
    SET referral_code = public.generate_referral_code(r.full_name)
    WHERE id = r.id;
  END LOOP;

  -- Search through auth.users to see if anyone signed up with a code but we missed linking them
  FOR r IN 
    SELECT u.id, u.raw_user_meta_data->>'referred_by' as rcode 
    FROM auth.users u 
    JOIN public.profiles p ON p.id = u.id 
    WHERE u.raw_user_meta_data->>'referred_by' IS NOT NULL 
    AND p.referrer_id IS NULL 
  LOOP
    SELECT id INTO _ref_id FROM public.profiles WHERE UPPER(referral_code) = UPPER(r.rcode);
    IF _ref_id IS NOT NULL THEN
      UPDATE public.profiles SET referrer_id = _ref_id WHERE id = r.id;
    END IF;
  END LOOP;
END;
$$;
