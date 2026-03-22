-- Final fix for term and RLS unification: Ensure 'orders' table is secured.
-- This handles the case where 'jobs' was renamed or 'orders' was created without RLS.

-- 1. Enable RLS on orders (critical to prevent cross-account leaks)
ALTER TABLE IF EXISTS public.orders ENABLE ROW LEVEL SECURITY;

-- 2. Drop any legacy or conflicting policies
DROP POLICY IF EXISTS "Users can view their own jobs" ON public.orders;
DROP POLICY IF EXISTS "Users can view their own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can insert their own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can update their own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can delete their own orders" ON public.orders;

-- 3. Create strict user-level policies for 'orders'
CREATE POLICY "Users can view their own orders" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own orders" ON public.orders
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own orders" ON public.orders
  FOR DELETE USING (auth.uid() = user_id);

-- 4. Also ensure 'customers' table has RLS (just in case)
ALTER TABLE IF EXISTS public.customers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage their own customers" ON public.customers;
CREATE POLICY "Users can manage their own customers" ON public.customers
  FOR ALL USING (auth.uid() = user_id);

-- 5. Special Marketplace order tracking policy (for clients to track their specific order)
-- We use OR to allow both the tailor (via user_id) and the client (via marketplace link)
DROP POLICY IF EXISTS "Allow clients to view their tracking orders" ON public.orders;
CREATE POLICY "Allow clients to view their tracking orders" ON public.orders
  FOR SELECT USING (
    id IN (
      SELECT order_id FROM marketplace_requests 
      WHERE customer_email = (auth.jwt()->>'email')
    )
  );
