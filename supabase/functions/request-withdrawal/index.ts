import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

    try {
        const { user_id, amount, bank_name, account_number, account_name } = await req.json()

        if (!user_id || !amount || !bank_name || !account_number || !account_name) {
            return new Response(
                JSON.stringify({ success: false, error: 'All fields are required' }),
                { status: 400, headers: { ...cors, 'Content-Type': 'application/json' } }
            )
        }

        const numAmount = Number(amount)
        if (isNaN(numAmount) || numAmount < 500) {
            return new Response(
                JSON.stringify({ success: false, error: 'Minimum withdrawal amount is ₦500' }),
                { status: 400, headers: { ...cors, 'Content-Type': 'application/json' } }
            )
        }

        const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

        // Check user's wallet balance
        const { data: profile, error: profileErr } = await supabase
            .from('profiles')
            .select('wallet_balance')
            .eq('id', user_id)
            .single()

        if (profileErr || !profile) {
            return new Response(
                JSON.stringify({ success: false, error: 'User not found' }),
                { status: 404, headers: { ...cors, 'Content-Type': 'application/json' } }
            )
        }

        const walletBalance = Number(profile.wallet_balance ?? 0)
        if (numAmount > walletBalance) {
            return new Response(
                JSON.stringify({ success: false, error: `Insufficient balance. Your wallet has ₦${walletBalance.toLocaleString()}` }),
                { status: 400, headers: { ...cors, 'Content-Type': 'application/json' } }
            )
        }

        // Insert withdrawal request
        const { error: insertErr } = await supabase
            .from('withdrawal_requests')
            .insert({
                user_id,
                amount: numAmount,
                bank_name,
                account_number,
                account_name,
                status: 'pending',
                created_at: new Date().toISOString(),
            })

        if (insertErr) {
            console.error('Insert error:', insertErr)
            return new Response(
                JSON.stringify({ success: false, error: 'Failed to submit request' }),
                { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
            )
        }

        // Hold the amount (deduct from balance so it's reserved)
        const newBalance = walletBalance - numAmount
        await supabase
            .from('profiles')
            .update({ wallet_balance: newBalance })
            .eq('id', user_id)

        console.log(`Withdrawal request: user=${user_id} amount=${numAmount}`)

        return new Response(
            JSON.stringify({ success: true, new_balance: newBalance }),
            { headers: { ...cors, 'Content-Type': 'application/json' } }
        )
    } catch (err) {
        return new Response(
            JSON.stringify({ success: false, error: err.message }),
            { status: 500, headers: { ...cors, 'Content-Type': 'application/json' } }
        )
    }
})
