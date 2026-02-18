# 🚀 Complete Payment Setup Guide - Step by Step

This guide will walk you through setting up Flutterwave and Paystack payments for TailorSync, even if you're new to payment integrations.

---

## 📋 Prerequisites

- ✅ Flutterwave account (in test mode)
- ✅ Paystack account (in test mode)
- ✅ Supabase project set up
- ✅ Supabase CLI installed (for deploying Edge Functions)

---

## Step 1: Get Your API Keys 🔑

### Flutterwave API Keys

1. **Log in to Flutterwave Dashboard**
   - Go to: https://dashboard.flutterwave.com/
   - Sign in with your account

2. **Navigate to API Keys**
   - Click on **Settings** (gear icon) in the left sidebar
   - Click on **API Keys** from the settings menu

3. **Copy Your Test Keys**
   - You'll see two keys:
     - **Public Key**: Starts with `FLWPUBK_TEST_...` (this is safe to use in frontend)
     - **Secret Key**: Starts with `FLWSECK_TEST_...` (keep this secret!)
   - **Copy both keys** - you'll need them later

4. **Get Webhook Secret Hash** (for webhook verification)
   - Still in Settings → API Keys
   - Look for **"Secret Hash"** or **"Webhook Secret"**
   - Copy this value (you'll need it for webhook setup)

### Paystack API Keys

1. **Log in to Paystack Dashboard**
   - Go to: https://dashboard.paystack.com/
   - Sign in with your account

2. **Navigate to API Keys**
   - Click on **Settings** (gear icon) in the top right
   - Click on **API Keys & Webhooks**

3. **Copy Your Test Keys**
   - You'll see:
     - **Public Key**: Starts with `pk_test_...` (this is safe to use in frontend)
     - **Secret Key**: Starts with `sk_test_...` (keep this secret!)
   - **Copy both keys** - you'll need them later

---

## Step 2: Add API Keys to Your Code 💻

### 2.1 Update Flutterwave Public Key in `billing_service.dart`

1. Open: `lib/core/billing/billing_service.dart`
2. Find line 10 (around line 10):
   ```dart
   static const String _flutterwavePublicKey = 'FLWPUBK_TEST_YOUR_PUBLIC_KEY';
   ```
3. Replace `'FLWPUBK_TEST_YOUR_PUBLIC_KEY'` with your actual Flutterwave public key:
   ```dart
   static const String _flutterwavePublicKey = 'FLWPUBK_TEST_xxxxxxxxxxxxx';
   ```

### 2.2 Update Flutterwave Public Key in `upgrade_screen.dart`

1. Open: `lib/features/monetization/screens/upgrade_screen.dart`
2. Find line 50:
   ```dart
   publicKey: 'FLWPUBK_TEST_YOUR_PUBLIC_KEY', // TODO: Replace with actual key
   ```
3. Replace with your actual key:
   ```dart
   publicKey: 'FLWPUBK_TEST_xxxxxxxxxxxxx',
   ```

### 2.3 Update Paystack Public Key in `billing_service.dart`

1. Still in `lib/core/billing/billing_service.dart`
2. Find line 15:
   ```dart
   static const String _paystackPublicKey = 'pk_test_YOUR_PUBLIC_KEY';
   ```
3. Replace with your actual Paystack public key:
   ```dart
   static const String _paystackPublicKey = 'pk_test_xxxxxxxxxxxxx';
   ```

---

## Step 3: Create Supabase Edge Functions 🔧

### 3.1 Create Paystack Payment Link Generator

This function securely generates Paystack payment links using your secret key.

1. **Create the function directory:**
   ```bash
   mkdir -p supabase/functions/create-paystack-payment
   ```

2. **Create the function file:**
   Create `supabase/functions/create-paystack-payment/index.ts` with this content:

   ```typescript
   import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
   
   const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!
   
   serve(async (req) => {
     if (req.method !== 'POST') {
       return new Response(
         JSON.stringify({ error: 'Method not allowed' }),
         { status: 405, headers: { 'Content-Type': 'application/json' } }
       )
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
           amount: amount * 100, // Convert to kobo (Paystack uses kobo)
           reference,
           callback_url,
           metadata,
         }),
       })
   
       const data = await response.json()
       
       if (data.status) {
         return new Response(
           JSON.stringify({ payment_url: data.data.authorization_url }),
           { headers: { 'Content-Type': 'application/json' } }
         )
       } else {
         return new Response(
           JSON.stringify({ error: data.message }),
           { status: 400, headers: { 'Content-Type': 'application/json' } }
         )
       }
     } catch (error) {
       return new Response(
         JSON.stringify({ error: error.message || 'Internal server error' }),
         { status: 500, headers: { 'Content-Type': 'application/json' } }
       )
     }
   })
   ```

### 3.2 Create Paystack Webhook Handler

This function handles Paystack payment confirmations.

1. **Create the function directory:**
   ```bash
   mkdir -p supabase/functions/paystack-webhook
   ```

2. **Create the function file:**
   Create `supabase/functions/paystack-webhook/index.ts` with this content:

   ```typescript
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
   ```

---

## Step 4: Update Code to Use Paystack Endpoint 🔗

### 4.1 Update `billing_service.dart`

1. Open: `lib/core/billing/billing_service.dart`
2. Find line 88-89 (around line 88):
   ```dart
   final response = await http.post(
     Uri.parse('https://your-backend.com/api/paystack/create-payment-link'),
   ```
3. Replace with your Supabase Edge Function URL:
   ```dart
   final response = await http.post(
     Uri.parse('https://YOUR_PROJECT_ID.supabase.co/functions/v1/create-paystack-payment'),
   ```
   **Replace `YOUR_PROJECT_ID`** with your actual Supabase project ID (found in Supabase dashboard → Settings → API)

4. **Add authorization header** (required for Supabase Edge Functions):
   Find the headers section (around line 90) and update it:
   ```dart
   headers: {
     'Content-Type': 'application/json',
     'Authorization': 'Bearer ${Supabase.instance.client.supabaseKey}',
   },
   ```

---

## Step 5: Set Environment Variables in Supabase 🔐

You need to set secret keys in Supabase so the Edge Functions can use them.

### 5.1 Install Supabase CLI (if not already installed)

```bash
# Windows (using Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Or using npm
npm install -g supabase
```

### 5.2 Login to Supabase CLI

```bash
supabase login
```

### 5.3 Link Your Project

```bash
supabase link --project-ref YOUR_PROJECT_ID
```

### 5.4 Set Secrets

```bash
# Set Paystack secret key
supabase secrets set PAYSTACK_SECRET_KEY=sk_test_your_actual_secret_key

# Set Flutterwave secret hash (for webhook verification)
supabase secrets set FLUTTERWAVE_SECRET_HASH=your_flutterwave_secret_hash
```

**Note:** Supabase automatically provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to Edge Functions, so you don't need to set those.

---

## Step 6: Deploy Edge Functions 🚀

Deploy all three Edge Functions:

```bash
# Deploy Flutterwave webhook (already exists)
supabase functions deploy flutterwave-webhook

# Deploy Paystack payment link generator
supabase functions deploy create-paystack-payment

# Deploy Paystack webhook
supabase functions deploy paystack-webhook
```

---

## Step 7: Set Up Webhooks in Dashboards 🌐

### 7.1 Flutterwave Webhook

1. **Go to Flutterwave Dashboard**
   - Navigate to: Settings → Webhooks

2. **Add Webhook URL**
   - Click **"Add Webhook"**
   - Enter URL: `https://YOUR_PROJECT_ID.supabase.co/functions/v1/flutterwave-webhook`
   - **Replace `YOUR_PROJECT_ID`** with your Supabase project ID

3. **Select Events**
   - Check: `charge.completed`
   - Check: `transfer.completed` (optional)

4. **Save**

### 7.2 Paystack Webhook

1. **Go to Paystack Dashboard**
   - Navigate to: Settings → API Keys & Webhooks
   - Scroll to **"Webhooks"** section

2. **Add Webhook URL**
   - Click **"Add Webhook"**
   - Enter URL: `https://YOUR_PROJECT_ID.supabase.co/functions/v1/paystack-webhook`
   - **Replace `YOUR_PROJECT_ID`** with your Supabase project ID

3. **Select Events**
   - Check: `charge.success`
   - Check: `subscription.create` (optional, for future use)

4. **Save**

---

## Step 8: Verify Database Schema 📊

### 8.1 Open Supabase SQL Editor

1. Go to your Supabase Dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click **"New Query"**

### 8.2 Run This SQL Script

Copy and paste this entire script, then click **"Run"**:

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

### 8.3 Verify Tables Exist

Check that these tables/columns exist:
- ✅ `profiles` table has all the columns listed above
- ✅ `referral_transactions` table exists
- ✅ `increment_wallet_balance` function exists

---

## Step 9: Test Your Setup 🧪

### 9.1 Test Flutterwave Payment

1. **Use Test Card:**
   - Card Number: `5531886652142950`
   - CVV: `564`
   - Expiry: `12/32`
   - PIN: `3310`
   - OTP: `123456`

2. **Test Flow:**
   - Open your app
   - Go to upgrade screen
   - Select a plan
   - Choose Flutterwave
   - Use test card details
   - Complete payment
   - Check Supabase `profiles` table - subscription should be activated

### 9.2 Test Paystack Payment

1. **Use Test Card:**
   - Card Number: `4084084084084081`
   - CVV: `408`
   - Expiry: `01/23`
   - PIN: `0000`
   - OTP: `123456`

2. **Test Flow:**
   - Open your app
   - Go to upgrade screen
   - Select a plan
   - Choose Paystack
   - Payment page should open in browser
   - Use test card details
   - Complete payment
   - Check Supabase `profiles` table - subscription should be activated

### 9.3 Check Webhook Logs

1. **Supabase Dashboard:**
   - Go to: Edge Functions → Logs
   - Check for webhook function logs
   - Should see successful processing messages

2. **Flutterwave Dashboard:**
   - Go to: Transactions → Webhooks
   - Check webhook delivery status

3. **Paystack Dashboard:**
   - Go to: Settings → Webhooks
   - Check webhook delivery logs

---

## ✅ Checklist

- [ ] Got Flutterwave API keys (public + secret + webhook hash)
- [ ] Got Paystack API keys (public + secret)
- [ ] Updated Flutterwave public key in `billing_service.dart`
- [ ] Updated Flutterwave public key in `upgrade_screen.dart`
- [ ] Updated Paystack public key in `billing_service.dart`
- [ ] Created `create-paystack-payment` Edge Function
- [ ] Created `paystack-webhook` Edge Function
- [ ] Updated Paystack endpoint URL in `billing_service.dart`
- [ ] Set Supabase secrets (PAYSTACK_SECRET_KEY, FLUTTERWAVE_SECRET_HASH)
- [ ] Deployed all Edge Functions
- [ ] Set up Flutterwave webhook in dashboard
- [ ] Set up Paystack webhook in dashboard
- [ ] Verified database schema (ran SQL script)
- [ ] Tested Flutterwave payment flow
- [ ] Tested Paystack payment flow

---

## 🆘 Troubleshooting

### Payment Not Processing?

- ✅ Check API keys are correct (test keys for test mode)
- ✅ Verify keys don't have extra spaces when copying
- ✅ Check network connectivity
- ✅ Review payment provider dashboard logs

### Webhook Not Working?

- ✅ Verify webhook URL is correct (check project ID)
- ✅ Check webhook is enabled in dashboard
- ✅ Review Supabase Edge Function logs
- ✅ Verify secret keys are set correctly
- ✅ Test webhook with a test payment

### Subscription Not Activating?

- ✅ Check webhook is receiving events (check logs)
- ✅ Verify database schema is correct
- ✅ Check user_id and plan_id are in metadata
- ✅ Review Supabase function logs for errors

### Edge Function Deployment Failed?

- ✅ Check Supabase CLI is logged in
- ✅ Verify project is linked correctly
- ✅ Check function code syntax
- ✅ Ensure all imports are correct

---

## 📚 Additional Resources

- **Flutterwave Docs:** https://developer.flutterwave.com/docs
- **Paystack Docs:** https://paystack.com/docs
- **Supabase Edge Functions:** https://supabase.com/docs/guides/functions

---

**Need Help?** If you get stuck, check the error messages in:
- Supabase Edge Function logs
- Flutterwave/Paystack dashboard logs
- Your app's debug console

Good luck! 🚀
