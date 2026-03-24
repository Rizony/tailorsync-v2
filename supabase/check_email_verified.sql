-- Function to check if a user's email is verified (confirmed) in auth.users
-- This is used by the ForgotPasswordScreen to prevent reset links from being sent to unverified emails.
CREATE OR REPLACE FUNCTION public.is_email_verified(email_input TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with elevated privileges to access auth.users
SET search_path = public
AS $$
DECLARE
  is_confirmed BOOLEAN;
BEGIN
  SELECT (email_confirmed_at IS NOT NULL) INTO is_confirmed
  FROM auth.users
  WHERE email = email_input
  LIMIT 1;

  RETURN COALESCE(is_confirmed, FALSE);
END;
$$;
