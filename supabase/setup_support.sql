-- Support System Tables

-- 1. Ensure profiles has is_admin
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 2. Create support_tickets table
CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Create support_messages table
CREATE TABLE IF NOT EXISTS public.support_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL, -- User ID or Admin ID (from auth.users)
    message TEXT NOT NULL,
    is_admin_reply BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- 4. Policies for support_tickets
-- Users can view their own tickets
DROP POLICY IF EXISTS "Users can view their own tickets" ON public.support_tickets;
CREATE POLICY "Users can view their own tickets" ON public.support_tickets
    FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own tickets
DROP POLICY IF EXISTS "Users can create their own tickets" ON public.support_tickets;
CREATE POLICY "Users can create their own tickets" ON public.support_tickets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Admins can view all tickets
DROP POLICY IF EXISTS "Admins can view all tickets" ON public.support_tickets;
CREATE POLICY "Admins can view all tickets" ON public.support_tickets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- 5. Policies for support_messages
-- Users can view messages for their own tickets
DROP POLICY IF EXISTS "Users can view messages for their own tickets" ON public.support_messages;
CREATE POLICY "Users can view messages for their own tickets" ON public.support_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.support_tickets
            WHERE id = ticket_id AND user_id = auth.uid()
        )
    );

-- Users can send messages to their own tickets
DROP POLICY IF EXISTS "Users can send messages to their own tickets" ON public.support_messages;
CREATE POLICY "Users can send messages to their own tickets" ON public.support_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.support_tickets
            WHERE id = ticket_id AND user_id = auth.uid()
        )
    );

-- Admins can view and send all messages
DROP POLICY IF EXISTS "Admins can manage all support messages" ON public.support_messages;
CREATE POLICY "Admins can manage all support messages" ON public.support_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- 6. Trigger for updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_support_ticket_updated_at
BEFORE UPDATE ON public.support_tickets
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();
