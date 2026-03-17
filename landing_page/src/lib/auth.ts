import { supabase } from "@/lib/supabase";

export async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser();
  if (error) return null;
  return data.user ?? null;
}

export async function signOut() {
  await supabase.auth.signOut();
}

