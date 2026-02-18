-- Create jobs table based on user provided schema
CREATE TABLE IF NOT EXISTS public.jobs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  customer_id uuid NOT NULL REFERENCES public.customers(id),
  title text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  balance_due numeric NOT NULL DEFAULT 0,
  due_date timestamp with time zone NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  images text[] DEFAULT '{}',
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  assigned_to uuid REFERENCES public.profiles(id),
  is_outsourced boolean NOT NULL DEFAULT false,
  CONSTRAINT jobs_pkey PRIMARY KEY (id)
);

-- Enable RLS
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own jobs" ON public.jobs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own jobs" ON public.jobs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own jobs" ON public.jobs
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own jobs" ON public.jobs
  FOR DELETE USING (auth.uid() = user_id);
