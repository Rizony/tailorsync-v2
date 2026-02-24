import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FLUTTERWAVE_SECRET_KEY = Deno.env.get('FLUTTERWAVE_SECRET_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { transaction_id, tx_ref, user_id, plan_id } = await req.json()

        if (!user_id || !plan_id || (!transaction_id && !tx_ref)) {
            return new Response(
                JSON.stringify({ success: false, error: 'Missing required fields' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Verify with Flutterwave API using transaction_id (preferred) or tx_ref
        const verifyUrl = transaction_id
            ? `https://api.flutterwave.com/v3/transactions/${transaction_id}/verify`
            : `https://api.flutterwave.com/v3/transactions/verify_by_reference?tx_ref=${tx_ref}`

        const verifyRes = await fetch(verifyUrl, {
            headers: {
                'Authorization': `Bearer ${FLUTTERWAVE_SECRET_KEY}`,
                'Content-Type': 'application/json',
            },
        })

        const verifyData = await verifyRes.json()

        if (verifyData.status !== 'success' || verifyData.data?.status !== 'successful') {
            return new Response(
                JSON.stringify({ success: false, error: 'Payment not confirmed by Flutterwave' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Determine tier from plan_id
        const subscriptionTier = plan_id.includes('premium')
            ? 'premium'
            : plan_id.includes('standard')
                ? 'standard'
                : 'freemium'

        const isAnnual = plan_id.includes('annual')
        const daysToAdd = isAnnual ? 365 : 30
        const now = new Date()
        const expiresAt = new Date(now.getTime() + daysToAdd * 24 * 60 * 60 * 1000)

        const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

        const { error: updateError } = await supabase
            .from('profiles')
            .update({
                subscription_tier: subscriptionTier,
                subscription_started_at: now.toISOString(),
                subscription_expires_at: expiresAt.toISOString(),
                last_payment_provider: 'flutterwave',
                last_transaction_ref: tx_ref ?? transaction_id?.toString(),
            })
            .eq('id', user_id)

        if (updateError) {
            console.error('DB update error:', updateError)
            return new Response(
                JSON.stringify({ success: false, error: 'Failed to update subscription' }),
                { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Process referral commission
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

        console.log(`Flutterwave: activated ${subscriptionTier} for user ${user_id}`)

        return new Response(
            JSON.stringify({ success: true, tier: subscriptionTier }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    } catch (error) {
        console.error('verify-flutterwave-payment error:', error)
        return new Response(
            JSON.stringify({ success: false, error: error.message }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})
