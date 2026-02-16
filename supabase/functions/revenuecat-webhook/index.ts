import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

// Supabase service client (server-side only)
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

type RevenueCatEvent = {
  type?: string;
  app_user_id?: string;
  appUserId?: string;
  entitlements?: {
    active?: Record<string, unknown>;
    [key: string]: any;
  };
  customer_info?: {
    entitlements?: {
      active?: Record<string, unknown>;
      [key: string]: any;
    };
    [key: string]: any;
  };
  [key: string]: any;
};

serve(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  let payload: any;
  try {
    payload = await req.json();
  } catch (_e) {
    return new Response("Invalid JSON body", { status: 400 });
  }

  const event: RevenueCatEvent = payload.event ?? payload;

  const appUserId = event.app_user_id ?? event.appUserId;
  if (!appUserId) {
    console.error("Missing app_user_id in RevenueCat payload", payload);
    return new Response("Missing app_user_id", { status: 400 });
  }

  // Determine the current subscription tier from active entitlements.
  // We assume RevenueCat entitlements are named "premium" and "standard".
  let tier: "freemium" | "standard" | "premium" = "freemium";

  // RevenueCat can send entitlements in different shapes depending on the webhook type.
  const entitlements =
    event.entitlements ??
    event.customer_info?.entitlements ??
    ({} as RevenueCatEvent["entitlements"]);

  let activeKeys: string[] = [];

  if (entitlements?.active && typeof entitlements.active === "object") {
    activeKeys = Object.keys(entitlements.active);
  } else if (entitlements && typeof entitlements === "object") {
    // Fallback: older payloads may put entitlements at the top level with is_active flags
    activeKeys = Object.entries(entitlements)
      .filter(([_, value]) => (value as any)?.is_active === true)
      .map(([key]) => key);
  }

  if (activeKeys.includes("premium")) {
    tier = "premium";
  } else if (activeKeys.includes("standard")) {
    tier = "standard";
  }

  console.log("Updating subscription tier from webhook", {
    appUserId,
    tier,
    activeEntitlements: activeKeys,
  });

  const { error } = await supabase
    .from("profiles")
    .update({ subscription_tier: tier })
    .eq("id", appUserId);

  if (error) {
    console.error("Error updating profile subscription_tier", error);
    return new Response("Supabase update error", { status: 500 });
  }

  return new Response(
    JSON.stringify({ success: true, appUserId, tier }),
    {
      status: 200,
      headers: { "Content-Type": "application/json" },
    },
  );
});

// supabase/functions/revenuecat-webhook/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // 1. Parse the RevenueCat Webhook Body
  const body = await req.json()
  const event = body.event
  
  // We only care about NEW purchases or RENEWALS
  if (event.type !== 'INITIAL_PURCHASE' && event.type !== 'RENEWAL') {
    return new Response(JSON.stringify({ message: "Ignored event type" }), { status: 200 })
  }

  // 2. Initialize Supabase Admin Client
  const supabase = createClient(
    Deno.env.get('https://rxovaccqxwisjdsrznjy.supabase.co') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const userId = event.app_user_id // This should match your Supabase Auth ID
  const price = event.price_in_purchased_currency
  
  // 3. Find who referred this user
  const { data: userProfile } = await supabase
    .from('profiles')
    .select('referrer_id')
    .eq('id', userId)
    .single()

  if (!userProfile?.referrer_id) {
    return new Response(JSON.stringify({ message: "No referrer found" }), { status: 200 })
  }

  // 4. Calculate Commission (40% for First, 20% for Renewal)
  let commissionRate = 0.20
  if (event.type === 'INITIAL_PURCHASE') {
    commissionRate = 0.40
  }

  const commissionAmount = price * commissionRate

  // 5. Pay the Referrer safely
  const { error } = await supabase.rpc('increment_wallet', {
    row_id: userProfile.referrer_id,
    amount_to_add: commissionAmount
  })

  if (error) {
    console.error("Failed to pay commission:", error)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }

  return new Response(
    JSON.stringify({ message: `Commission paid: ${commissionAmount}` }),
    { headers: { "Content-Type": "application/json" } }
  )
})