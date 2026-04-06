import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://uoesjxeleiluelbpnzie.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVvZXNqeGVsZWlsdWVsYnBuemllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDA4NjksImV4cCI6MjA4MTcxNjg2OX0.0nLT4ztjZqt5B7xaPQtO0HSeFIfjEiPy9D_kzC-jLic';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
