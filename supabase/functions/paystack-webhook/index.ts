import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  try {
    const body = await req.text()
    const hash = req.headers.get('x-paystack-signature')
    
    // Verify webhook signature (basic check - you can enhance this)
    // In production, verify the hash using crypto
    
    const payload = JSON.parse(body)
    const { event, data } = payload

    // Handle successful charge
    if (event === 'charge.success') {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

      // Extract metadata from transaction
      const metadata = data.metadata || {}
      const { plan_id, user_id } = metadata

      if (!plan_id || !user_id) {
        console.error('Missing plan_id or user_id in metadata')
        return new Response(
          JSON.stringify({ error: 'Missing required metadata' }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
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
          { status: 500, headers: { 'Content-Type': 'application/json' } }
        )
      }

      // Process referral commission if applicable
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
          // Calculate commission (40% first month, 20% subsequent)
          const subscriptionAmount = subscriptionTier === 'premium' ? 5000 : 3000
          const isFirstMonth = true // You might want to check this from database
          const commissionRate = isFirstMonth ? 0.40 : 0.20
          const commissionAmount = Math.round(subscriptionAmount * commissionRate)

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
            subscription_amount: subscriptionAmount,
            commission_rate: commissionRate,
            commission_amount: commissionAmount,
            is_first_month: isFirstMonth,
            created_at: now.toISOString(),
          })
        }
      }

      console.log(`Subscription activated for user ${user_id}: ${subscriptionTier}`)
    }

    return new Response(
      JSON.stringify({ received: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Paystack webhook error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
