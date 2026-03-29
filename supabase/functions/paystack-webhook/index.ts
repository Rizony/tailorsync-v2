import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

/** Verify Paystack HMAC-SHA512 webhook signature using native Deno crypto. */
async function verifyPaystackSignature(secret: string, body: string, signature: string): Promise<boolean> {
  const encoder = new TextEncoder()
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-512' },
    false,
    ['sign']
  )
  const signatureBytes = await crypto.subtle.sign('HMAC', key, encoder.encode(body))
  const expectedHex = Array.from(new Uint8Array(signatureBytes))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
  return expectedHex === signature
}

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
    console.log('--- Paystack Webhook Received ---')
    
    // Read environment variables inside the handler to prevent startup crashes
    // Paystack natively uses your Secret Key to sign webhook events
    const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY') ?? ''
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const body = await req.text()
    const signature = req.headers.get('x-paystack-signature') ?? ''

    // ── Paystack webhook signature verification ────────────────────────────────
    if (PAYSTACK_SECRET_KEY) {
      const isValid = await verifyPaystackSignature(PAYSTACK_SECRET_KEY, body, signature)
      if (!isValid) {
        console.error('Invalid Paystack webhook signature')
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      console.log('Signature verified successfully')
    } else {
      console.error('PAYSTACK_SECRET_KEY not set — cannot verify webhook')
      return new Response(
        JSON.stringify({ error: 'Missing Paystack Secret Key' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const payload = JSON.parse(body)
    const { event, data } = payload
    console.log(`Event: ${event}`)

    // Handle successful charge
    if (event === 'charge.success') {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

      // Extract metadata from transaction
      const metadata = data.metadata || {}
      console.log('Metadata:', JSON.stringify(metadata))

      const { plan_id, user_id } = metadata
      
      // --- Marketplace payment flow (client -> tailor, platform takes 10%) ---
      const marketplaceRequestId =
        metadata.marketplace_request_id || metadata.request_id || metadata.marketplaceRequestId
      const marketplaceTailorId = metadata.tailor_id || metadata.tailorId
      const marketplaceCustomerId = metadata.customer_id || metadata.customerId

      if (marketplaceRequestId && marketplaceTailorId) {
        const reference = data.reference || data.id?.toString()
        console.log(`Processing marketplace payment for request: ${marketplaceRequestId}`)

        // Paystack sends `amount` in kobo; convert to Naira for storage
        const amountNaira = (data.amount ?? 0) / 100
        const commissionRate = 0.10
        const commissionAmount = Math.round(amountNaira * commissionRate * 100) / 100
        const netAmount = Math.round((amountNaira - commissionAmount) * 100) / 100

        // Record payment (idempotent by unique reference)
        const { error: paymentError } = await supabase.from('marketplace_payments').upsert({
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

        if (paymentError) {
          console.error('Error inserting marketplace_payment:', paymentError)
          throw paymentError
        }

        // Mark request as paid
        const { error: requestUpdateError } = await supabase
          .from('marketplace_requests')
          .update({ payment_status: 'paid', paid_at: new Date().toISOString() })
          .eq('id', marketplaceRequestId)

        if (requestUpdateError) {
          console.error('Error updating marketplace_request:', requestUpdateError)
          throw requestUpdateError
        }

        // Escrow split definition
        const availableAmount = Math.round((netAmount / 2) * 100) / 100;
        const pendingAmount = netAmount - availableAmount;

        // Credit tailor escrow wallet
        console.log(`Crediting wallet for tailor: ${marketplaceTailorId}`)
        const { error: rpcError } = await supabase.rpc('escrow_credit_wallet', {
          p_tailor_id: marketplaceTailorId,
          p_available_amount: availableAmount,
          p_pending_amount: pendingAmount,
          p_reference: reference,
          p_request_id: marketplaceRequestId
        })

        if (rpcError) {
          console.error('Error in escrow_credit_wallet RPC:', rpcError)
          // We don't throw here to avoid failing the whole webhook if wallet credit fails, 
          // but logging it is critical.
        }

        // Record platform revenue (commission)
        const { error: revenueError } = await supabase.from('platform_revenue').insert({
          source: 'marketplace_payment',
          source_id: marketplaceRequestId,
          amount: commissionAmount,
          currency: 'NGN',
        })
        
        if (revenueError) {
          console.error('Error recording platform revenue:', revenueError)
        }

        // Process referral commission
        const processMarketplaceReferral = async (userId: string | null, label: string) => {
          if (!userId) return;
          console.log(`Checking referral for ${label}: ${userId}`)
          
          const { data: userData, error: userError } = await supabase
            .from('profiles')
            .select('referrer_id')
            .eq('id', userId)
            .single()

          if (userError || !userData?.referrer_id) return;

          const { data: referrerData, error: refError } = await supabase
            .from('profiles')
            .select('subscription_tier')
            .eq('id', userData.referrer_id)
            .single()

          if (refError || referrerData?.subscription_tier !== 'premium') return;

          const { count, error: countError } = await supabase
            .from('referral_transactions')
            .select('*', { count: 'exact', head: true })
            .eq('referred_user_id', userId)
            .eq('subscription_tier', 'marketplace_payment')

          if (countError || (count !== null && count >= 5)) return;

          const partnerCommission = Math.round(commissionAmount * 0.40 * 100) / 100

          if (partnerCommission > 0) {
            const { error: walletIncError } = await supabase.rpc('increment_wallet_balance', {
              user_id: userData.referrer_id,
              amount: partnerCommission,
            })

            if (walletIncError) {
              console.error(`Error incrementing referrer wallet for ${label}:`, walletIncError)
              return;
            }

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
            console.log(`Earned ${partnerCommission} NGN referral commission for ${label}: ${userId}`)
          }
        }

        await processMarketplaceReferral(marketplaceTailorId, 'Tailor');
        await processMarketplaceReferral(marketplaceCustomerId, 'Customer');

        console.log(`Webhook processed successfully for request ${marketplaceRequestId}`)
        return new Response(
          JSON.stringify({ received: true }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // --- Subscription flow (if plan_id and user_id exist) ---
      if (plan_id && user_id) {
        console.log(`Processing subscription for user: ${user_id}, plan: ${plan_id}`)
        
        const subscriptionTier = plan_id.includes('premium')
          ? 'premium'
          : plan_id.includes('standard')
          ? 'standard'
          : 'freemium'

        const now = new Date()
        const expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)

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
          throw updateError
        }

        const subscriptionAmountNaira = (data.amount ?? 0) / 100

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
            const commissionAmount = Math.round(subscriptionAmountNaira * 0.40)
            
            await supabase.rpc('increment_wallet_balance', {
              user_id: userData.referrer_id,
              amount: commissionAmount,
            })

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

        console.log(`Subscription activated: user=${user_id} tier=${subscriptionTier}`)
      } else {
        console.warn('Unknown charge.success payload structure (missing marketplace IDs and subscription IDs)')
      }
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
