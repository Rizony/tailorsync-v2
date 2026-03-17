-- Quotes + client ratings for marketplace requests

ALTER TABLE public.marketplace_requests
ADD COLUMN IF NOT EXISTS quote_amount numeric, -- major currency units (e.g., Naira)
ADD COLUMN IF NOT EXISTS quote_currency text DEFAULT 'NGN',
ADD COLUMN IF NOT EXISTS quote_message text,
ADD COLUMN IF NOT EXISTS quoted_at timestamp with time zone,
ADD COLUMN IF NOT EXISTS quoted_by uuid REFERENCES public.profiles(id);

-- One rating per request (post-completion)
CREATE TABLE IF NOT EXISTS public.marketplace_ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL UNIQUE REFERENCES public.marketplace_requests(id) ON DELETE CASCADE,
  tailor_id uuid NOT NULL REFERENCES public.profiles(id),
  customer_id uuid NOT NULL REFERENCES auth.users(id),
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review text,
  created_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.marketplace_ratings ENABLE ROW LEVEL SECURITY;

-- Clients can insert their own ratings
DROP POLICY IF EXISTS "Clients can rate their own requests" ON public.marketplace_ratings;
CREATE POLICY "Clients can rate their own requests" ON public.marketplace_ratings
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Tailors and clients can view ratings tied to them
DROP POLICY IF EXISTS "Tailors and clients can view ratings" ON public.marketplace_ratings;
CREATE POLICY "Tailors and clients can view ratings" ON public.marketplace_ratings
  FOR SELECT USING (auth.uid() = customer_id OR auth.uid() = tailor_id);

-- Keep profiles.rating in sync (simple average over marketplace_ratings)
CREATE OR REPLACE FUNCTION public.recompute_tailor_rating(p_tailor_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET rating = COALESCE((
    SELECT AVG(r.rating)::numeric(10,2)
    FROM public.marketplace_ratings r
    WHERE r.tailor_id = p_tailor_id
  ), 5.0)
  WHERE id = p_tailor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.on_marketplace_rating_change()
RETURNS trigger AS $$
BEGIN
  PERFORM public.recompute_tailor_rating(NEW.tailor_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_marketplace_rating_change ON public.marketplace_ratings;
CREATE TRIGGER trg_marketplace_rating_change
AFTER INSERT OR UPDATE ON public.marketplace_ratings
FOR EACH ROW
EXECUTE FUNCTION public.on_marketplace_rating_change();

