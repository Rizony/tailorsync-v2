import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { reference, user_id, plan_id } = await req.json()

    if (!reference || !user_id || !plan_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Verify the transaction with Paystack
    const verifyRes = await fetch(`https://api.paystack.co/transaction/verify/${reference}`, {
      headers: {
        'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
      },
    })

    const verifyData = await verifyRes.json()

    if (!verifyData.status || verifyData.data?.status !== 'success') {
      return new Response(
        JSON.stringify({ success: false, error: 'Payment not confirmed by Paystack' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Determine subscription tier
    const subscriptionTier = plan_id.includes('premium')
      ? 'premium'
      : plan_id.includes('standard')
      ? 'standard'
      : 'freemium'

    // Calculate expiry (30 days for monthly, 365 for annual)
    const isAnnual = plan_id.includes('annual')
    const daysToAdd = isAnnual ? 365 : 30
    const now = new Date()
    const expiresAt = new Date(now.getTime() + daysToAdd * 24 * 60 * 60 * 1000)

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Update the profile
    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        subscription_tier: subscriptionTier,
        subscription_started_at: now.toISOString(),
        subscription_expires_at: expiresAt.toISOString(),
        last_payment_provider: 'paystack',
        last_transaction_ref: reference,
      })
      .eq('id', user_id)

    if (updateError) {
      console.error('DB update error:', updateError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to update subscription' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Process referral commission if applicable
    const { data: userData } = await supabase
      .from('profiles')
      .select('referrer_id')
      .eq('id', user_id)
      .single()

    if (userData?.referrer_id) {
      const { data: referrerData } = await supabase
        .from('profiles')
        .select('subscription_tier')
        .eq('id', userData.referrer_id)
        .single()

      if (referrerData?.subscription_tier === 'premium') {
        const subscriptionAmount = subscriptionTier === 'premium' ? 5000 : 3000
        const commissionAmount = Math.round(subscriptionAmount * 0.40) // 40% first subscribe

        await supabase.rpc('increment_wallet_balance', {
          user_id: userData.referrer_id,
          amount: commissionAmount,
        })

        await supabase.from('referral_transactions').insert({
          referrer_id: userData.referrer_id,
          referred_user_id: user_id,
          subscription_tier: subscriptionTier,
          subscription_amount: subscriptionAmount,
          commission_rate: 0.40,
          commission_amount: commissionAmount,
          is_first_month: true,
          created_at: now.toISOString(),
        })
      }
    }

    console.log(`Verified and activated ${subscriptionTier} for user ${user_id}`)

    return new Response(
      JSON.stringify({ success: true, tier: subscriptionTier }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('verify-paystack-payment error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
