-- Enable Realtime for the marketplace_requests table so the Flutter app receives instant notifications/updates!
ALTER PUBLICATION supabase_realtime ADD TABLE public.marketplace_requests;
