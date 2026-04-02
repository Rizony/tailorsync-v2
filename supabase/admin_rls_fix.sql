-- Allow admins to update user profiles (KYC approvals, etc)
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
CREATE POLICY "Admins can update profiles" 
  ON public.profiles FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()));

-- Also ensure admins can manage withdrawal requests
DROP POLICY IF EXISTS "Admins can update withdrawals" ON public.withdrawal_requests;
CREATE POLICY "Admins can update withdrawals" 
  ON public.withdrawal_requests FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()));

-- Also ensure admins can manage support tickets if needed
DROP POLICY IF EXISTS "Admins can update support tickets" ON public.support_tickets;
CREATE POLICY "Admins can update support tickets" 
  ON public.support_tickets FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()));
