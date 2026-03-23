-- Idempotent Support Schema Fix

-- 1. Ensure support_tickets has all necessary columns
ALTER TABLE public.support_tickets ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.support_tickets ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high'));
ALTER TABLE public.support_tickets ALTER COLUMN description DROP NOT NULL; -- Make nullable if it exists
-- OR just drop it if you're sure you don't need it:
-- ALTER TABLE public.support_tickets DROP COLUMN IF EXISTS description;

-- 2. Ensure profiles has is_admin
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 3. Re-apply the trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_support_ticket_updated_at ON public.support_tickets;
CREATE TRIGGER set_support_ticket_updated_at
BEFORE UPDATE ON public.support_tickets
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- 4. No policies here to avoid conflicts; use setup_support.sql for policies
