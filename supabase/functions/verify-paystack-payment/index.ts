import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { reference, user_id, plan_id } = await req.json()

    const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY') ?? ''
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
       return new Response(
        JSON.stringify({ success: false, error: 'Server configuration error' }),
        { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // ── 1. Try Paystack API verification ──────────────────────────────────────
    let verifyData: any;
    if (PAYSTACK_SECRET_KEY) {
      const verifyRes = await fetch(
        `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
        { headers: { 'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}` } }
      )
      verifyData = await verifyRes.json()

      console.log('Paystack verify response:', JSON.stringify({
        status: verifyData.status,
        dataStatus: verifyData.data?.status,
        httpStatus: verifyRes.status,
        reference,
      }))

      if (!verifyData.status || verifyData.data?.status !== 'success') {
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
      console.warn('PAYSTACK_SECRET_KEY not set — cannot verify actual payment state')
      return new Response(
        JSON.stringify({ success: false, error: 'PAYSTACK_SECRET_KEY is required for verification' }),
        { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    const metadata = verifyData.data?.metadata || {}
    const amount = verifyData.data?.amount || 0
    
    // ── 2. Marketplace Flow ────────────────────────────────────────────────────
    const marketplaceRequestId = metadata.marketplace_request_id || metadata.request_id || metadata.marketplaceRequestId
    if (marketplaceRequestId) {
      console.log(`Verifying marketplace payment for request: ${marketplaceRequestId}`)
      // The heavy lifting (escrow, commissions) is handled by the webhook.
      // This frontend verification just ensures the DB is updated before the client redirects.
      
      const { error: updateError } = await supabase
        .from('marketplace_requests')
        .update({ payment_status: 'paid', paid_at: new Date().toISOString() })
        .eq('id', marketplaceRequestId)

      if (updateError) {
        console.error('DB update error on marketplace_request:', updateError)
        return new Response(
          JSON.stringify({ success: false, error: 'Failed to update marketplace request' }),
          { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({ success: true, type: 'marketplace' }),
        { headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    // ── 3. Subscription Flow ───────────────────────────────────────────────────
    if (!plan_id) {
       return new Response(
        JSON.stringify({ success: false, error: 'Not a marketplace payment and plan_id is missing' }),
        { status: 400, headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    const subscriptionTier = plan_id.includes('premium')
      ? 'premium'
      : plan_id.includes('standard')
        ? 'standard'
        : 'freemium'

    const isAnnual = plan_id.includes('annual')
    const now = new Date()
    const expiresAt = new Date(now.getTime() + (isAnnual ? 365 : 30) * 24 * 60 * 60 * 1000)

    const { error: profileUpdateError } = await supabase
      .from('profiles')
      .update({
        subscription_tier: subscriptionTier,
        subscription_started_at: now.toISOString(),
        subscription_expires_at: expiresAt.toISOString(),
        last_payment_provider: 'paystack',
        last_transaction_ref: reference,
      })
      .eq('id', user_id)

    if (profileUpdateError) {
      console.error('DB update error:', profileUpdateError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to update subscription' }),
        { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
      )
    }

    // Referral commission logic
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
        const commissionAmount = Math.round((amount / 100) * 0.40)

        await supabase.rpc('increment_wallet_balance', {
          user_id: userData.referrer_id,
          amount: commissionAmount,
        })

        await supabase.from('referral_transactions').insert({
          referrer_id: userData.referrer_id,
          referred_user_id: user_id,
          subscription_tier: subscriptionTier,
          subscription_amount: amount / 100,
          commission_rate: 0.40,
          commission_amount: commissionAmount,
          is_first_month: true,
          created_at: now.toISOString(),
        })
      }
    }

    console.log(`Paystack: activated ${subscriptionTier} for user ${user_id} (ref=${reference})`)

    return new Response(
      JSON.stringify({ success: true, type: 'subscription', tier: subscriptionTier }),
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
