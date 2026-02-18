# 💳 Payment Setup Guide - Flutterwave & Paystack

## Overview

TailorSync now uses **Flutterwave** and **Paystack** for Nigerian payment processing, replacing RevenueCat. This allows users to pay via:
- Card payments
- Bank transfers
- USSD
- Mobile money
- Account transfers

---

## 🔧 Setup Instructions

### 1. Flutterwave Setup

1. **Create Flutterwave Account**
   - Go to https://dashboard.flutterwave.com/
   - Sign up for a business account
   - Complete KYC verification

2. **Get API Keys**
   - Navigate to Settings → API Keys
   - Copy your **Public Key** (starts with `FLWPUBK_`)
   - Copy your **Secret Key** (starts with `FLWSECK_`) - keep this secret!

3. **Update Code**
   - Open `lib/core/billing/billing_service.dart`
   - Replace `_flutterwavePublicKey` with your actual public key
   - For production, use production keys (remove `_TEST`)

4. **Update Payment Widget**
   - Open `lib/features/monetization/widgets/flutterwave_payment_widget.dart`
   - Replace `'FLWPUBK_TEST_YOUR_PUBLIC_KEY'` with your actual key
   - Or better: Store keys in environment variables or Supabase secrets

---

### 2. Paystack Setup

1. **Create Paystack Account**
   - Go to https://dashboard.paystack.com/
   - Sign up for a business account
   - Complete business verification

2. **Get API Keys**
   - Navigate to Settings → API Keys & Webhooks
   - Copy your **Public Key** (starts with `pk_`)
   - Copy your **Secret Key** (starts with `sk_`) - keep this secret!

3. **Create Backend Endpoint**

   Paystack requires a backend endpoint to securely generate payment links. You have two options:

   **Option A: Supabase Edge Function (Recommended)**
   
   Create a Supabase Edge Function at `supabase/functions/create-paystack-payment/index.ts`:
   
   ```typescript
   import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
   
   const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!
   
   serve(async (req) => {
     if (req.method !== 'POST') {
       return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 })
     }
   
     try {
       const { email, amount, reference, callback_url, metadata } = await req.json()
   
       const response = await fetch('https://api.paystack.co/transaction/initialize', {
         method: 'POST',
         headers: {
           'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
           'Content-Type': 'application/json',
         },
         body: JSON.stringify({
           email,
           amount: amount * 100, // Convert to kobo
           reference,
           callback_url,
           metadata,
         }),
       })
   
       const data = await response.json()
       
       if (data.status) {
         return new Response(JSON.stringify({ payment_url: data.data.authorization_url }), {
           headers: { 'Content-Type': 'application/json' },
         })
       } else {
         return new Response(JSON.stringify({ error: data.message }), { status: 400 })
       }
     } catch (error) {
       return new Response(JSON.stringify({ error: error.message }), { status: 500 })
     }
   })
   ```
   
   **Set Environment Variable:**
   ```bash
   supabase secrets set PAYSTACK_SECRET_KEY=sk_test_your_secret_key
   ```
   
   **Deploy Function:**
   ```bash
   supabase functions deploy create-paystack-payment
   ```

   **Option B: Separate Backend Server**
   
   Create an endpoint that accepts payment requests and returns Paystack payment URLs.
   Update `lib/core/billing/billing_service.dart` line ~60 with your endpoint URL.

4. **Update Code**
   - Open `lib/core/billing/billing_service.dart`
   - Update `getPaystackPaymentUrl()` method
   - Replace `'https://your-backend.com/api/paystack/create-payment-link'` with your actual endpoint
   - Or use Supabase Edge Function: `'https://your-project.supabase.co/functions/v1/create-paystack-payment'`

---

### 3. Webhook Setup (Important!)

Both Flutterwave and Paystack need webhooks to verify payments and activate subscriptions.

#### Flutterwave Webhook

1. Go to Flutterwave Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-project.supabase.co/functions/v1/flutterwave-webhook`
3. Select events: `charge.completed`, `transfer.completed`

#### Paystack Webhook

1. Go to Paystack Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-project.supabase.co/functions/v1/paystack-webhook`
3. Select events: `charge.success`, `subscription.create`

#### Create Webhook Handlers

Create Supabase Edge Functions to handle webhooks:

**Flutterwave Webhook** (`supabase/functions/flutterwave-webhook/index.ts`):
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FLUTTERWAVE_SECRET_HASH = Deno.env.get('FLUTTERWAVE_SECRET_HASH')!

serve(async (req) => {
  const { event, data } = await req.json()
  
  if (event === 'charge.completed' && data.status === 'successful') {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    const { plan_id, user_id } = data.metadata || {}
    
    if (plan_id && user_id) {
      // Activate subscription
      await supabase
        .from('profiles')
        .update({
          subscription_tier: plan_id.includes('premium') ? 'premium' : 'standard',
          subscription_started_at: new Date().toISOString(),
          subscription_expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        })
        .eq('id', user_id)
    }
  }
  
  return new Response(JSON.stringify({ received: true }))
})
```

**Paystack Webhook** (`supabase/functions/paystack-webhook/index.ts`):
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!

serve(async (req) => {
  const hash = req.headers.get('x-paystack-signature')
  const body = await req.text()
  
  // Verify webhook signature (implement crypto verification)
  
  const { event, data } = JSON.parse(body)
  
  if (event === 'charge.success') {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    const { plan_id, user_id } = data.metadata || {}
    
    if (plan_id && user_id) {
      // Activate subscription
      await supabase
        .from('profiles')
        .update({
          subscription_tier: plan_id.includes('premium') ? 'premium' : 'standard',
          subscription_started_at: new Date().toISOString(),
          subscription_expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        })
        .eq('id', user_id)
    }
  }
  
  return new Response(JSON.stringify({ received: true }))
})
```

---

## 📋 Database Schema Updates

Ensure your Supabase `profiles` table has these columns:

```sql
-- Add/verify these columns in profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'freemium';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_started_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_payment_provider TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_transaction_ref TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS ad_credits INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS referrer_id UUID REFERENCES profiles(id);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS wallet_balance DECIMAL DEFAULT 0;

-- Create referral_transactions table
CREATE TABLE IF NOT EXISTS referral_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID REFERENCES profiles(id),
  referred_user_id UUID REFERENCES profiles(id),
  subscription_tier TEXT,
  subscription_amount INTEGER,
  commission_rate DECIMAL,
  commission_amount DECIMAL,
  is_first_month BOOLEAN,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create function to increment wallet balance
CREATE OR REPLACE FUNCTION increment_wallet_balance(user_id UUID, amount DECIMAL)
RETURNS void AS $$
BEGIN
  UPDATE profiles
  SET wallet_balance = wallet_balance + amount
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 🧪 Testing

### Test Mode

Both Flutterwave and Paystack have test modes:

**Flutterwave Test Cards:**
- Card: `5531886652142950`
- CVV: `564`
- Expiry: `12/32`
- PIN: `3310`
- OTP: `123456`

**Paystack Test Cards:**
- Card: `4084084084084081`
- CVV: `408`
- Expiry: `01/23`
- PIN: `0000`
- OTP: `123456`

### Testing Flow

1. Use test API keys (contain `TEST` in the key)
2. Make a test payment
3. Verify subscription activates in Supabase
4. Check referral commissions (if Premium user)
5. Test subscription expiration handling

---

## 🔐 Security Best Practices

1. **Never commit API keys to Git**
   - Use environment variables
   - Store in Supabase secrets
   - Use `.env` files (add to `.gitignore`)

2. **Verify webhook signatures**
   - Always verify webhook requests are from Flutterwave/Paystack
   - Use secret hashes/keys for verification

3. **Use HTTPS**
   - All webhook URLs must use HTTPS
   - Payment URLs should use HTTPS

4. **Rate Limiting**
   - Implement rate limiting on payment endpoints
   - Prevent duplicate payment attempts

---

## 📝 Next Steps

1. ✅ Get Flutterwave API keys
2. ✅ Get Paystack API keys
3. ✅ Create Supabase Edge Functions for Paystack
4. ✅ Set up webhooks
5. ✅ Update API keys in code
6. ✅ Test payment flows
7. ✅ Deploy to production

---

## 🆘 Troubleshooting

**Payment not processing?**
- Check API keys are correct
- Verify test mode matches (test keys for test mode)
- Check network connectivity
- Review Flutterwave/Paystack dashboard logs

**Webhook not receiving events?**
- Verify webhook URL is accessible (HTTPS)
- Check webhook configuration in dashboard
- Review Supabase function logs
- Test webhook with ngrok (for local testing)

**Subscription not activating?**
- Check webhook is processing correctly
- Verify database schema is correct
- Check Supabase function logs
- Verify user ID matches

---

**Need Help?** Check Flutterwave and Paystack documentation:
- Flutterwave: https://developer.flutterwave.com/docs
- Paystack: https://paystack.com/docs
