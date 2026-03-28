import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts"

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!
// PAYSTACK_WEBHOOK_SECRET is your Paystack dashboard webhook secret.
// If not set (e.g. in local dev), signature check is skipped with a warning.
const PAYSTACK_WEBHOOK_SECRET = Deno.env.get('PAYSTACK_WEBHOOK_SECRET') ?? ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-paystack-signature',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.text()

    // ── Paystack webhook signature verification ────────────────────────────────
    // Paystack signs every webhook with HMAC-SHA512 using your secret key.
    // Reject any request whose signature doesn't match to prevent spoofed events.
    if (PAYSTACK_WEBHOOK_SECRET) {
      const signature = req.headers.get('x-paystack-signature') ?? ''
      const expectedHash = hmac('sha512', PAYSTACK_WEBHOOK_SECRET, body, 'utf8', 'hex') as string
      if (signature !== expectedHash) {
        console.error('Invalid Paystack webhook signature')
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    } else {
      console.warn('PAYSTACK_WEBHOOK_SECRET not set — skipping signature check (dev mode)')
    }

    const payload = JSON.parse(body)
    const { event, data } = payload

    // Handle successful charge
    if (event === 'charge.success') {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

      // Extract metadata from transaction
      const metadata = data.metadata || {}
      const { plan_id, user_id } = metadata

      // --- Marketplace payment flow (client -> tailor, platform takes 10%) ---
      const marketplaceRequestId =
        metadata.marketplace_request_id || metadata.request_id || metadata.marketplaceRequestId
      const marketplaceTailorId = metadata.tailor_id || metadata.tailorId
      const marketplaceCustomerId = metadata.customer_id || metadata.customerId

      if (marketplaceRequestId && marketplaceTailorId) {
        const reference = data.reference || data.id?.toString()

        // Paystack sends `amount` in kobo; convert to Naira for storage
        const amountNaira = (data.amount ?? 0) / 100
        const commissionRate = 0.10
        const commissionAmount = Math.round(amountNaira * commissionRate * 100) / 100
        const netAmount = Math.round((amountNaira - commissionAmount) * 100) / 100

        // Record payment (idempotent by unique reference)
        await supabase.from('marketplace_payments').upsert({
          request_id: marketplaceRequestId,
          customer_id: marketplaceCustomerId ?? null,
          tailor_id: marketplaceTailorId,
          provider: 'paystack',
          reference,
          amount: amountNaira,
          commission_rate: commissionRate,
          commission_amount: commissionAmount,
          net_amount: netAmount,
          status: 'paid',
          raw: payload,
        }, { onConflict: 'reference' })

        // Mark request as paid
        await supabase
          .from('marketplace_requests')
          .update({ payment_status: 'paid', paid_at: new Date().toISOString() })
          .eq('id', marketplaceRequestId)

        // Escrow split definition
        const availableAmount = Math.round((netAmount / 2) * 100) / 100;
        const pendingAmount = netAmount - availableAmount;

        // Credit tailor escrow wallet
        await supabase.rpc('escrow_credit_wallet', {
          p_tailor_id: marketplaceTailorId,
          p_available_amount: availableAmount,
          p_pending_amount: pendingAmount,
          p_reference: reference,
          p_request_id: marketplaceRequestId
        })

        // Record platform revenue (commission)
        await supabase.from('platform_revenue').insert({
          source: 'marketplace_payment',
          source_id: marketplaceRequestId,
          amount: commissionAmount,
          currency: 'NGN',
        })

        // Process referral commission for this marketplace transaction (40% of the 10% platform fee)
        // Applies to both the tailor and the customer if they have referrers, up to 5 transactions each.
        const processMarketplaceReferral = async (userId: string | null) => {
          if (!userId) return;
          const { data: userData } = await supabase
            .from('profiles')
            .select('referrer_id')
            .eq('id', userId)
            .single()

          if (!userData?.referrer_id) return;

          // Must be a Premium Partner to earn referrals
          const { data: referrerData } = await supabase
            .from('profiles')
            .select('subscription_tier')
            .eq('id', userData.referrer_id)
            .single()

          if (referrerData?.subscription_tier !== 'premium') return;

          // Check if under 5 completed transactions for this referred user
          const { count } = await supabase
            .from('referral_transactions')
            .select('*', { count: 'exact', head: true })
            .eq('referred_user_id', userId)
            .eq('subscription_tier', 'marketplace_payment')

          if (count !== null && count >= 5) return; // Limit reached

          // Partner gets 40% of Needlix's fee
          const partnerCommission = Math.round(commissionAmount * 0.40 * 100) / 100

          if (partnerCommission > 0) {
            // Increment referrer's wallet balance
            await supabase.rpc('increment_wallet_balance', {
              user_id: userData.referrer_id,
              amount: partnerCommission,
            })

            // Record referral transaction (using subscription_tier as type)
            await supabase.from('referral_transactions').insert({
              referrer_id: userData.referrer_id,
              referred_user_id: userId,
              subscription_tier: 'marketplace_payment',
              subscription_amount: amountNaira,
              commission_rate: 0.40,
              commission_amount: partnerCommission,
              is_first_month: false,
              created_at: new Date().toISOString(),
            })
            console.log(`Earned ${partnerCommission} NGN referral commission for marketplace pay (User: ${userId})`)
          }
        }

        await processMarketplaceReferral(marketplaceTailorId);
        await processMarketplaceReferral(marketplaceCustomerId);

        console.log(`Marketplace payment paid: request=${marketplaceRequestId} tailor=${marketplaceTailorId} amount=${amountNaira}`)
        return new Response(
          JSON.stringify({ received: true }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      if (!plan_id || !user_id) {
        console.error('Missing plan_id or user_id in metadata')
        return new Response(
          JSON.stringify({ error: 'Missing required metadata' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Determine subscription tier from planId
      const subscriptionTier = plan_id.includes('premium')
        ? 'premium'
        : plan_id.includes('standard')
        ? 'standard'
        : 'freemium'

      // Calculate expiry date (30 days from now)
      const now = new Date()
      const expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)

      // Update user profile with subscription
      const { error: updateError } = await supabase
        .from('profiles')
        .update({
          subscription_tier: subscriptionTier,
          subscription_started_at: now.toISOString(),
          subscription_expires_at: expiresAt.toISOString(),
          last_payment_provider: 'paystack',
          last_transaction_ref: data.reference || data.id?.toString(),
        })
        .eq('id', user_id)

      if (updateError) {
        console.error('Error updating subscription:', updateError)
        return new Response(
          JSON.stringify({ error: 'Failed to activate subscription' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Process referral commission if applicable.
      // Use the actual Paystack-verified amount (kobo → Naira) rather than hardcoded values.
      const subscriptionAmountNaira = (data.amount ?? 0) / 100

      const { data: userData } = await supabase
        .from('profiles')
        .select('referrer_id, subscription_tier')
        .eq('id', user_id)
        .single()

      if (userData?.referrer_id) {
        // Check if referrer is Premium
        const { data: referrerData } = await supabase
          .from('profiles')
          .select('subscription_tier')
          .eq('id', userData.referrer_id)
          .single()

        if (referrerData?.subscription_tier === 'premium') {
          // 40% commission on the actual charged amount
          const commissionAmount = Math.round(subscriptionAmountNaira * 0.40)

          // Increment referrer's wallet balance
          await supabase.rpc('increment_wallet_balance', {
            user_id: userData.referrer_id,
            amount: commissionAmount,
          })

          // Record referral transaction
          await supabase.from('referral_transactions').insert({
            referrer_id: userData.referrer_id,
            referred_user_id: user_id,
            subscription_tier: subscriptionTier,
            subscription_amount: subscriptionAmountNaira,
            commission_rate: 0.40,
            commission_amount: commissionAmount,
            is_first_month: true,
            created_at: now.toISOString(),
          })
        }
      }

      console.log(`Subscription activated for user ${user_id}: ${subscriptionTier}`)
    }

    return new Response(
      JSON.stringify({ received: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Paystack webhook error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
