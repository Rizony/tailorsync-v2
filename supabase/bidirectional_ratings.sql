-- Migration to enable Tailor -> Client ratings
-- Run this in Supabase SQL Editor

-- 1. Add customer_rating to profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS customer_rating numeric DEFAULT 5.0;

-- 2. Modify marketplace_ratings
ALTER TABLE public.marketplace_ratings DROP CONSTRAINT IF EXISTS marketplace_ratings_request_id_key;

ALTER TABLE public.marketplace_ratings 
ADD COLUMN IF NOT EXISTS rater_role text CHECK (rater_role IN ('client', 'tailor')) DEFAULT 'client';

ALTER TABLE public.marketplace_ratings 
DROP CONSTRAINT IF EXISTS unique_request_rater_role;

ALTER TABLE public.marketplace_ratings 
ADD CONSTRAINT unique_request_rater_role UNIQUE (request_id, rater_role);

-- 3. Recompute Tailor Rating (Rated by Client)
CREATE OR REPLACE FUNCTION public.recompute_tailor_rating(p_tailor_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET rating = COALESCE((
    SELECT AVG(r.rating)::numeric(10,2)
    FROM public.marketplace_ratings r
    WHERE r.tailor_id = p_tailor_id AND r.rater_role = 'client'
  ), 5.0)
  WHERE id = p_tailor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recompute Client Rating (Rated by Tailor)
CREATE OR REPLACE FUNCTION public.recompute_client_rating(p_customer_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET customer_rating = COALESCE((
    SELECT AVG(r.rating)::numeric(10,2)
    FROM public.marketplace_ratings r
    WHERE r.customer_id = p_customer_id AND r.rater_role = 'tailor'
  ), 5.0)
  WHERE id = p_customer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Updated Trigger Function
CREATE OR REPLACE FUNCTION public.on_marketplace_rating_change()
RETURNS trigger AS $$
BEGIN
  IF NEW.rater_role = 'client' THEN
    PERFORM public.recompute_tailor_rating(NEW.tailor_id);
  ELSE
    PERFORM public.recompute_client_rating(NEW.customer_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Add policy for Tailors to rate
DROP POLICY IF EXISTS "Tailors can rate their clients" ON public.marketplace_ratings;
CREATE POLICY "Tailors can rate their clients" ON public.marketplace_ratings
  FOR INSERT WITH CHECK (auth.uid() = tailor_id AND rater_role = 'tailor');
