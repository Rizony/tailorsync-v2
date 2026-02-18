# 🚀 TailorSync Launch Checklist & Recommendations

## 📋 Current Status Summary

**Project:** TailorSync v2 - Nigeria Tailoring Business Management App  
**Tech Stack:** Flutter, Supabase, Flutterwave/Paystack, Google Mobile Ads  
**Plans:** Freemium, Standard (₦3,000/mo), Premium (₦5,000/mo)

---

## ⚠️ CRITICAL BLOCKERS (Must Fix Before Launch)

### 1. **RevenueCat Configuration** 🔴
- **Issue:** Android API key is placeholder (`goog_your_actual_android_key`)
- **Action Required:**
  - Get actual RevenueCat API keys from dashboard
  - Update `lib/core/billing/billing_service.dart` line 8
  - Configure products in RevenueCat dashboard:
    - `standard_monthly_id` → ₦3,000/month
    - `premium_monthly_id` → ₦5,000/month
  - Set up entitlements: `standard` and `premium`

### 2. **Google Mobile Ads** 🔴
- **Issue:** Using test ad unit IDs (`ca-app-pub-3940256099942544/5224354917`)
- **Action Required:**
  - Create AdMob account
  - Create rewarded ad unit for Android
  - Create rewarded ad unit for iOS
  - Update `lib/core/ads/ad_service.dart` line 7
  - Add production ad unit IDs

### 3. **Incomplete Core Screens** 🔴
- **Issue:** Orders and Customers screens are placeholders
- **Current State:**
  - Orders Screen: Just shows "Orders Screen" text
  - Customers Screen: Just shows "Customers Screen" text
- **Action Required:** Build functional screens (see UI/UX section below)

### 4. **Supabase Database Schema** 🟡
- **Verify Required Tables:**
  - `profiles` (with subscription_tier, referral_code, wallet_balance, ad_credits)
  - `customers` (with user_id foreign key)
  - `orders` (if not exists)
  - `referrals` (for tracking referral commissions)
- **Action Required:** Run migrations/verify schema matches AppUser and Customer models

---

## 🎨 UI/UX IMPROVEMENTS (High Priority)

### 1. **Orders Screen** (Currently Placeholder)
**Recommended Features:**
- List of orders with status (Pending, In Progress, Completed, Delivered)
- Search/filter functionality
- Add new order button (FAB)
- Order details: Customer, measurements, due date, price
- Status update actions
- Pull-to-refresh
- Empty state with illustration

**Design Suggestions:**
- Use Material 3 cards with elevation
- Color-coded status badges
- Swipe actions (mark complete, delete)
- Nigerian Naira (₦) formatting

### 2. **Customers Screen** (Currently Placeholder)
**Recommended Features:**
- Customer list with search
- Add customer button (FAB)
- Customer cards showing: Name, phone, last order date
- Tap to view customer details
- Freemium limit indicator (e.g., "15/20 customers")
- Upgrade prompt when limit reached
- Empty state with CTA

**Design Suggestions:**
- Avatar initials for customers
- Quick actions (Call, Message, New Order)
- Filter by recent/active customers
- Smooth animations

### 3. **Upgrade Screen Enhancements**
**Current:** Basic plan cards
**Improvements:**
- Add Freemium plan card (for comparison)
- Show current plan badge
- Feature comparison table
- Testimonials/social proof
- "Most Popular" badge animation
- Success animation after purchase
- Loading states during purchase

### 4. **Daily Ad Gate Screen**
**Current:** Functional but basic
**Improvements:**
- Better loading state
- Ad loading progress indicator
- Skip option (if allowed) with countdown
- Motivational messaging for Nigerian tailors
- Smooth transitions

### 5. **Login Screen**
**Current:** Basic email input
**Improvements:**
- Add phone number login option (popular in Nigeria)
- Social login buttons (Google, Apple)
- Better error messages
- Loading animation
- "Remember me" option
- Forgot password link

### 6. **General UI Polish**
- **Consistent Color Scheme:** Purple (#5D3FD3) is good, ensure consistency
- **Typography:** Use Google Fonts (already in pubspec) - consider Inter or Poppins
- **Spacing:** Consistent padding/margins (8px grid)
- **Icons:** Use Material Icons consistently
- **Animations:** Add subtle transitions (flutter_animate already included)
- **Loading States:** Shimmer effects (shimmer package already included)
- **Error States:** Friendly error messages with retry options
- **Empty States:** Illustrations with helpful CTAs

---

## 💰 MONETIZATION & PLAN DETAILS

### Current Plan Structure (From Code):
- **Freemium:** Free, 20 customer limit, daily ad gate, video ads
- **Standard:** ₦3,000/month, no ads, unlimited customers, cloud backup, PDF invoices
- **Premium:** ₦5,000/month, everything + referral system, 40% commission

### ⚠️ QUESTIONS FOR YOU:

1. **Freemium Plan:**
   - Can users watch ads to add more customers beyond 20? (Code suggests yes via `adCredits`)
   - How many customers per ad watch?
   - Is there a maximum even with ads?

2. **Standard Plan:**
   - What exactly is "Cloud Backup"? (Auto-sync to Supabase?)
   - PDF Invoices/Quotations - what information do they include?
   - Any other features not listed?

3. **Premium Plan:**
   - **Referral System:** How does it work exactly?
     - Who can refer? (Only Premium users?)
     - What happens when someone signs up via referral?
     - 40% commission on what? (Monthly subscription fee?)
     - How is commission calculated and paid out?
   - **Partner System:** Is this different from referrals?
   - **Passive Income Tracking:** What metrics are tracked?

4. **Billing:**
   - Payment methods? (Card, Bank Transfer, Mobile Money?)
   - Currency: Naira only or multi-currency?
   - Subscription renewal: Auto-renew or manual?
   - Trial period? (e.g., 7-day free trial for Standard/Premium?)

5. **Ad Strategy:**
   - Where else do ads appear besides daily gate?
   - Banner ads in freemium?
   - Interstitial ads between screens?

---

## 🔧 TECHNICAL IMPROVEMENTS

### 1. **Error Handling**
- Add try-catch blocks with user-friendly messages
- Network error handling
- Offline mode detection
- Retry mechanisms

### 2. **State Management**
- Ensure subscription status syncs across app
- Handle subscription expiration gracefully
- Update UI when subscription changes

### 3. **Performance**
- Lazy loading for customer/order lists
- Image caching (cached_network_image already included)
- Pagination for large lists
- Optimize Supabase queries

### 4. **Security**
- Validate all user inputs
- Sanitize data before Supabase insert
- Rate limiting on API calls
- Secure storage for sensitive data

### 5. **Analytics**
- Add Firebase Analytics or similar
- Track: Sign-ups, conversions, feature usage, errors
- Monitor subscription conversion rates

---

## 📱 PLATFORM-SPECIFIC SETUP

### Android
- [ ] Update `android/app/build.gradle` with proper version codes
- [ ] Configure app signing
- [ ] Add proper app icon (already configured)
- [ ] Update AndroidManifest permissions
- [ ] Test on multiple Android versions (API 21+)

### iOS
- [ ] Configure app signing & certificates
- [ ] Update Info.plist with proper descriptions
- [ ] Add app icon (already configured)
- [ ] Test on multiple iOS versions
- [ ] Configure App Store Connect

### Web (If applicable)
- [ ] Test responsive design
- [ ] Configure PWA features
- [ ] Test payment flows

---

## 🚀 LAUNCH SEQUENCE (Recommended Order)

### Phase 1: Core Functionality (Week 1)
1. ✅ Fix RevenueCat API keys
2. ✅ Fix AdMob ad unit IDs
3. ✅ Build Orders screen
4. ✅ Build Customers screen
5. ✅ Verify Supabase schema

### Phase 2: Polish & Testing (Week 2)
1. ✅ Enhance UI/UX across all screens
2. ✅ Add error handling
3. ✅ Test subscription flows
4. ✅ Test ad flows
5. ✅ Test referral system (if Premium)

### Phase 3: Pre-Launch (Week 3)
1. ✅ Beta testing with real tailors
2. ✅ Fix bugs from beta
3. ✅ Prepare app store listings
4. ✅ Set up analytics
5. ✅ Create support documentation

### Phase 4: Launch (Week 4)
1. ✅ Submit to Google Play Store
2. ✅ Submit to Apple App Store
3. ✅ Marketing/announcement
4. ✅ Monitor metrics
5. ✅ Quick bug fixes

---

## 📊 SUCCESS METRICS TO TRACK

- **User Acquisition:** Sign-ups per day
- **Conversion:** Freemium → Standard/Premium %
- **Retention:** Day 1, 7, 30 retention
- **Revenue:** MRR (Monthly Recurring Revenue)
- **Engagement:** Daily active users, orders created, customers added
- **Referrals:** Premium users, referral sign-ups, commissions paid

---

## 🎯 QUICK WINS (Can Do Immediately)

1. **Add Freemium Plan Card** to upgrade screen for comparison
2. **Improve empty states** with illustrations and CTAs
3. **Add loading shimmer** effects
4. **Polish button styles** and add hover/press states
5. **Add success animations** after actions
6. **Improve error messages** with retry buttons
7. **Add pull-to-refresh** on list screens
8. **Add search functionality** to customer/order lists

---

## 📝 NEXT STEPS

1. **Answer plan details questions** (see section above)
2. **Prioritize which screens** to build first
3. **Get API keys** for RevenueCat and AdMob
4. **Decide on launch timeline** (ASAP = focus on critical blockers first)

---

**Ready to launch ASAP?** Focus on:
1. Fix API keys (RevenueCat + AdMob)
2. Build Orders & Customers screens (basic versions)
3. Test subscription purchase flow
4. Polish UI with quick wins

Then iterate based on user feedback!
