import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY') ?? ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { reference, user_id, plan_id } = await req.json()

    if (!reference || !user_id || !plan_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing required fields' }),
        { status: 400, headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    let paystackConfirmed = false

    // ── 1. Try Paystack API verification ──────────────────────────────────────
    if (PAYSTACK_SECRET_KEY) {
      const verifyRes = await fetch(
        `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
        { headers: { 'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}` } }
      )
      const verifyData = await verifyRes.json()

      console.log('Paystack verify response:', JSON.stringify({
        status: verifyData.status,
        dataStatus: verifyData.data?.status,
        httpStatus: verifyRes.status,
        reference,
      }))

      if (verifyData.status && verifyData.data?.status === 'success') {
        paystackConfirmed = true
      } else {
        console.error('Paystack did not confirm payment:', verifyData.message ?? verifyData)
        return new Response(
          JSON.stringify({
            success: false,
            error: `Paystack: ${verifyData.message ?? 'Payment not confirmed'}`,
            paystackStatus: verifyData.data?.status ?? 'unknown',
          }),
          { headers: { ...cors, 'Content-Type': 'application/json' } }
        )
      }
    } else {
      // ── 2. Fallback: PAYSTACK_SECRET_KEY not configured — trust the reference
      //    This is only for test/development. Set the secret in production.
      console.warn('PAYSTACK_SECRET_KEY not set — activating via reference directly (test mode)')
      paystackConfirmed = true
    }

    if (!paystackConfirmed) {
      return new Response(
        JSON.stringify({ success: false, error: 'Payment could not be verified' }),
        { headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    // ── 3. Determine subscription tier from plan_id ────────────────────────────
    const subscriptionTier = plan_id.includes('premium')
      ? 'premium'
      : plan_id.includes('standard')
        ? 'standard'
        : 'freemium'

    const isAnnual = plan_id.includes('annual')
    const now = new Date()
    const expiresAt = new Date(now.getTime() + (isAnnual ? 365 : 30) * 24 * 60 * 60 * 1000)

    // ── 4. Update profile ──────────────────────────────────────────────────────
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
        { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    // ── 5. Referral commission ─────────────────────────────────────────────────
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
        const amount = subscriptionTier === 'premium' ? 5000 : 3000
        const commission = Math.round(amount * 0.40)

        await supabase.rpc('increment_wallet_balance', {
          user_id: userData.referrer_id,
          amount: commission,
        })

        await supabase.from('referral_transactions').insert({
          referrer_id: userData.referrer_id,
          referred_user_id: user_id,
          subscription_tier: subscriptionTier,
          subscription_amount: amount,
          commission_rate: 0.40,
          commission_amount: commission,
          is_first_month: true,
          created_at: now.toISOString(),
        })
      }
    }

    console.log(`Paystack: activated ${subscriptionTier} for user ${user_id} (ref=${reference})`)

    return new Response(
      JSON.stringify({ success: true, tier: subscriptionTier }),
      { headers: { ...cors, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('verify-paystack-payment error:', err)
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
    )
  }
})
