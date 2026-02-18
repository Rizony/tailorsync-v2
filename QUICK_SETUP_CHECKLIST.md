# ✅ Quick Setup Checklist

Follow these steps in order to complete your payment setup.

## 🔑 Step 1: Get API Keys (5 minutes)

### Flutterwave
- [ ] Go to https://dashboard.flutterwave.com/
- [ ] Settings → API Keys
- [ ] Copy **Public Key** (`FLWPUBK_TEST_...`)
- [ ] Copy **Secret Key** (`FLWSECK_TEST_...`)
- [ ] Copy **Secret Hash** (for webhook verification)

### Paystack
- [ ] Go to https://dashboard.paystack.com/
- [ ] Settings → API Keys & Webhooks
- [ ] Copy **Public Key** (`pk_test_...`)
- [ ] Copy **Secret Key** (`sk_test_...`)

---

## 💻 Step 2: Update Code with API Keys (2 minutes)

### File 1: `lib/core/billing/billing_service.dart`
- [ ] Line 10: Replace `'FLWPUBK_TEST_YOUR_PUBLIC_KEY'` with your Flutterwave public key
- [ ] Line 15: Replace `'pk_test_YOUR_PUBLIC_KEY'` with your Paystack public key

### File 2: `lib/features/monetization/screens/upgrade_screen.dart`
- [ ] Line 50: Replace `'FLWPUBK_TEST_YOUR_PUBLIC_KEY'` with your Flutterwave public key

---

## 🔧 Step 3: Set Supabase Secrets (3 minutes)

Open terminal/PowerShell and run:

```bash
# Login to Supabase CLI
supabase login

# Link your project (replace with your project ID)
supabase link --project-ref rxovaccqxwisjdsrznjy

# Set secrets
supabase secrets set PAYSTACK_SECRET_KEY=sk_test_your_actual_secret_key
supabase secrets set FLUTTERWAVE_SECRET_HASH=your_flutterwave_secret_hash
```

---

## 🚀 Step 4: Deploy Edge Functions (2 minutes)

```bash
# Deploy all functions
supabase functions deploy flutterwave-webhook
supabase functions deploy create-paystack-payment
supabase functions deploy paystack-webhook
```

---

## 🌐 Step 5: Set Up Webhooks (5 minutes)

### Flutterwave Dashboard
- [ ] Go to Settings → Webhooks
- [ ] Add webhook URL: `https://rxovaccqxwisjdsrznjy.supabase.co/functions/v1/flutterwave-webhook`
- [ ] Select events: `charge.completed`
- [ ] Save

### Paystack Dashboard
- [ ] Go to Settings → API Keys & Webhooks
- [ ] Scroll to Webhooks section
- [ ] Add webhook URL: `https://rxovaccqxwisjdsrznjy.supabase.co/functions/v1/paystack-webhook`
- [ ] Select events: `charge.success`
- [ ] Save

---

## 📊 Step 6: Verify Database Schema (3 minutes)

1. [ ] Go to Supabase Dashboard → SQL Editor
2. [ ] Click "New Query"
3. [ ] Copy and paste the SQL from `PAYMENT_SETUP.md` (lines 228-260)
4. [ ] Click "Run"
5. [ ] Verify no errors

---

## 🧪 Step 7: Test Payments (10 minutes)

### Test Flutterwave
- [ ] Open app → Upgrade screen
- [ ] Select a plan
- [ ] Choose Flutterwave
- [ ] Use test card: `5531886652142950`, CVV: `564`, Expiry: `12/32`, PIN: `3310`
- [ ] Complete payment
- [ ] Check Supabase `profiles` table - subscription should be `premium` or `standard`

### Test Paystack
- [ ] Open app → Upgrade screen
- [ ] Select a plan
- [ ] Choose Paystack
- [ ] Payment page opens in browser
- [ ] Use test card: `4084084084084081`, CVV: `408`, Expiry: `01/23`, PIN: `0000`
- [ ] Complete payment
- [ ] Check Supabase `profiles` table - subscription should be activated

---

## ✅ Final Verification

- [ ] Flutterwave payment works
- [ ] Paystack payment works
- [ ] Subscription activates in database
- [ ] Webhook logs show successful processing
- [ ] No errors in Supabase Edge Function logs

---

## 🆘 If Something Doesn't Work

1. **Check Edge Function Logs:**
   - Supabase Dashboard → Edge Functions → Logs
   - Look for error messages

2. **Check Webhook Delivery:**
   - Flutterwave Dashboard → Transactions → Webhooks
   - Paystack Dashboard → Settings → Webhooks → View logs

3. **Verify Secrets:**
   ```bash
   supabase secrets list
   ```
   Should show `PAYSTACK_SECRET_KEY` and `FLUTTERWAVE_SECRET_HASH`

4. **Test Edge Functions Manually:**
   - Use Postman/curl to test webhook endpoints
   - Check Supabase function logs

---

**Need detailed instructions?** See `SETUP_GUIDE.md` for step-by-step explanations.
