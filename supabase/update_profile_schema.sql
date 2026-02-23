-- Add new columns for Branding, Contact Info, and Currency to the profiles table

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS shop_address TEXT,
ADD COLUMN IF NOT EXISTS phone_number TEXT,
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS website TEXT,
ADD COLUMN IF NOT EXISTS social_media_handle TEXT,
ADD COLUMN IF NOT EXISTS currency_code TEXT DEFAULT 'NGN',
ADD COLUMN IF NOT EXISTS currency_symbol TEXT DEFAULT '₦';

-- Optional: Add comments for clarity
COMMENT ON COLUMN profiles.currency_code IS 'ISO 4217 Currency Code (e.g., NGN, USD)';
COMMENT ON COLUMN profiles.currency_symbol IS 'Currency Symbol (e.g., ₦, $)';
