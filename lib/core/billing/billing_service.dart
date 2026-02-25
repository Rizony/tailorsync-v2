import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutterwave_standard/flutterwave.dart';

class BillingService {
  // Get these from your Flutterwave dashboard: https://dashboard.flutterwave.com/
  static const String _flutterwavePublicKey = 'FLWPUBK_TEST-c4c8b96627b8fa2ca1bb01d58362e530-X';
  
  /// Initialize billing service (no longer needed for RevenueCat)
  static Future<void> init() async {
    // No initialization needed for Flutterwave/Paystack
    // They initialize on-demand during payment
  }

  /// Purchase a subscription plan using Flutterwave
  /// Returns true if payment was successful
  static Future<bool> purchasePlanWithFlutterwave({
    required BuildContext context,
    required String planId,
    required String userEmail,
    required String userName,
    required String userId,
    required int amountInNaira,
    required String planName,
  }) async {
    try {
      // Generate transaction reference
      final txRef = "tailorsync_${DateTime.now().millisecondsSinceEpoch}_$userId";

      final flutterwave = Flutterwave(
        publicKey: _flutterwavePublicKey,
        currency: "NGN",
        txRef: txRef,
        amount: amountInNaira.toString(),
        // Required by Flutterwave Standard SDK
        redirectUrl: "https://tailorsync.app/payment-callback",
        paymentOptions: "card, banktransfer, ussd, account",
        customization: Customization(
          title: "TailorSync Subscription",
          description: "Subscribe to $planName plan",
          logo: "https://tailorsync.app/logo.png", // Add your logo URL
        ),
        customer: Customer(
          name: userName,
          email: userEmail,
        ),
        isTestMode: _flutterwavePublicKey.contains('TEST'),
      );

      final ChargeResponse response = await flutterwave.charge(context);

      if (response.status == "successful") {
        return await verifyAndActivateSubscription(
          userId: userId,
          planId: planId,
          transactionReference: txRef,
          paymentProvider: 'flutterwave',
        );
      }

      return false;
    } catch (e) {
      debugPrint("Flutterwave Payment Error: $e");
      return false;
    }
  }

  /// Purchase a subscription plan using Paystack (web-based)
  /// Returns payment URL that should be opened in browser
  static Future<String?> getPaystackPaymentUrl({
    required String userEmail,
    required int amountInNaira,
    required String planId,
    required String userId,
    required String planName,
  }) async {
    try {
      // Generate transaction reference
      final txRef = "tailorsync_${DateTime.now().millisecondsSinceEpoch}_$userId";
      
      // that generates Paystack payment links securely
      // For now, this is a placeholder that you'll need to implement
      // Example endpoint: POST /api/paystack/create-payment-link
      
      // The endpoint should:
      // 1. Create a Paystack payment link with the amount
      // 2. Include callback URL that points back to your app
      // 3. Return the payment URL
      
      // Preferred: call your Supabase Edge Function via the Supabase client.
      // This avoids trying to access an anon key at runtime.
      final res = await Supabase.instance.client.functions.invoke(
        'create-paystack-payment',
        body: {
          'email': userEmail,
          'amount': amountInNaira, // Edge function converts to kobo (×100)
          'reference': txRef,
          'callback_url': 'tailorsync://payment-callback',
          'metadata': {
            'plan_id': planId,
            'user_id': userId,
            'plan_name': planName,
          },
        },
      );

      final data = res.data;
      if (data is Map && data['payment_url'] is String) {
        return data['payment_url'] as String;
      }
      
      return null;
    } catch (e) {
      debugPrint("Paystack Payment URL Error: $e");
      return null;
    }
  }

  /// Verify payment and update subscription status in Supabase
  /// Call this after payment is completed (via webhook or callback)
  static Future<bool> verifyAndActivateSubscription({
    required String userId,
    required String planId,
    required String transactionReference,
    required String paymentProvider, // 'flutterwave' or 'paystack'
  }) async {
    try {
      // Determine subscription tier from planId
      final subscriptionTier = planId.contains('premium') 
          ? 'premium' 
          : planId.contains('standard') 
              ? 'standard' 
              : 'freemium';

      // Update user profile in Supabase
      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            'subscription_tier': subscriptionTier,
            'subscription_started_at': DateTime.now().toIso8601String(),
            'subscription_expires_at': DateTime.now()
                .add(const Duration(days: 30))
                .toIso8601String(),
            'last_payment_provider': paymentProvider,
            'last_transaction_ref': transactionReference,
          })
          .eq('id', userId)
          .select();

      if (response.isNotEmpty) {
        // If user was referred, process referral commission
        final userData = await Supabase.instance.client
            .from('profiles')
            .select('referrer_id')
            .eq('id', userId)
            .single();

        if (userData['referrer_id'] != null) {
          await _processReferralCommission(
            referrerId: userData['referrer_id'],
            referredUserId: userId,
            subscriptionTier: subscriptionTier,
            amount: subscriptionTier == 'premium' ? 5000 : 3000,
            isFirstMonth: true, // Check if this is first subscription
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Subscription Activation Error: $e");
      return false;
    }
  }

  /// Process referral commission for Premium partners
  /// 40% on first month, 20% on subsequent months
  static Future<void> _processReferralCommission({
    required String referrerId,
    required String referredUserId,
    required String subscriptionTier,
    required int amount,
    required bool isFirstMonth,
  }) async {
    try {
      // Check if referrer is Premium (can only refer if Premium)
      final referrerData = await Supabase.instance.client
          .from('profiles')
          .select('subscription_tier')
          .eq('id', referrerId)
          .single();

      if (referrerData['subscription_tier'] != 'premium') {
        return; // Only Premium users can earn commissions
      }

      // Calculate commission (40% first month, 20% subsequent)
      final commissionRate = isFirstMonth ? 0.40 : 0.20;
      final commissionAmount = (amount * commissionRate).round();

      // Update referrer's wallet balance
      await Supabase.instance.client.rpc('increment_wallet_balance', params: {
        'user_id': referrerId,
        'amount': commissionAmount,
      });

      // Record referral transaction
      await Supabase.instance.client.from('referral_transactions').insert({
        'referrer_id': referrerId,
        'referred_user_id': referredUserId,
        'subscription_tier': subscriptionTier,
        'subscription_amount': amount,
        'commission_rate': commissionRate,
        'commission_amount': commissionAmount,
        'is_first_month': isFirstMonth,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Referral Commission Error: $e");
    }
  }

  /// Check current subscription status from Supabase
  static Future<String> checkSubscriptionStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return "freemium";

      final response = await Supabase.instance.client
          .from('profiles')
          .select('subscription_tier, subscription_expires_at')
          .eq('id', user.id)
          .single();

      final tier = response['subscription_tier'] ?? 'freemium';
      final expiresAt = response['subscription_expires_at'];

      // Check if subscription has expired
      if (expiresAt != null) {
        final expiryDate = DateTime.parse(expiresAt);
        if (DateTime.now().isAfter(expiryDate)) {
          // Subscription expired, downgrade to freemium
          await Supabase.instance.client
              .from('profiles')
              .update({'subscription_tier': 'freemium'})
              .eq('id', user.id);
          return "freemium";
        }
      }

      return tier;
    } catch (e) {
      debugPrint("Error checking subscription status: $e");
      return "freemium";
    }
  }

  /// Process monthly recurring commission for existing referrals
  /// Call this via scheduled job/webhook when subscriptions renew
  static Future<void> processMonthlyReferralCommissions() async {
    try {
      // Get all active Premium users with referrals
      final referrers = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('subscription_tier', 'premium');

      for (final referrer in referrers) {
        // Get all users referred by this Premium user
        final referredUsers = await Supabase.instance.client
            .from('profiles')
            .select('id, subscription_tier, subscription_expires_at')
            .eq('referrer_id', referrer['id'])
            .inFilter('subscription_tier', ['standard', 'premium']);

        for (final referred in referredUsers) {
          // Check if subscription is still active
          if (referred['subscription_expires_at'] != null) {
            final expiresAt = DateTime.parse(referred['subscription_expires_at']);
            if (DateTime.now().isAfter(expiresAt)) continue;
          }

          final tier = referred['subscription_tier'];
          final amount = tier == 'premium' ? 5000 : 3000;

          // Process commission (20% for recurring)
          await _processReferralCommission(
            referrerId: referrer['id'],
            referredUserId: referred['id'],
            subscriptionTier: tier,
            amount: amount,
            isFirstMonth: false,
          );
        }
      }
    } catch (e) {
      debugPrint("Monthly Referral Commission Processing Error: $e");
    }
  }
}
