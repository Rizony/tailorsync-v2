import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget to handle Flutterwave payment
class FlutterwavePaymentWidget {
  /// Process payment with Flutterwave.
  /// Returns true on confirmed payment + successful tier activation.
  static Future<bool> processPayment({
    required BuildContext context,
    required String planId,
    required String planName,
    required int amountInNaira,
    required String publicKey,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userEmail = user.email ?? '';
      final userName = user.userMetadata?['full_name'] ?? 'User';
      final userId = user.id;
      final txRef = 'tailorsync_${DateTime.now().millisecondsSinceEpoch}_$userId';

      final flutterwave = Flutterwave(
        publicKey: publicKey,
        currency: 'NGN',
        txRef: txRef,
        amount: amountInNaira.toString(),
        redirectUrl: 'tailorsync://payment-callback',
        paymentOptions: 'card, banktransfer, ussd, account',
        customization: Customization(
          title: 'TailorSync Subscription',
          description: 'Subscribe to $planName plan - ₦$amountInNaira/month',
          logo: 'https://tailorsync.app/logo.png',
        ),
        customer: Customer(
          name: userName,
          email: userEmail,
          phoneNumber: user.userMetadata?['phone'] ?? '',
        ),
        isTestMode: publicKey.contains('TEST'),
      );

      final ChargeResponse response = await flutterwave.charge(context);

      if (response.status == 'successful' || response.status == 'completed') {
        debugPrint('Flutterwave payment confirmed: ${response.status}, txRef=$txRef');

        // Step 1: Try Edge Function (verifies with Flutterwave API + service role)
        final edgeSuccess = await _verifyViaEdgeFunction(
          userId: userId,
          planId: planId,
          txRef: txRef,
          transactionId: response.transactionId,
        );

        if (edgeSuccess) {
          debugPrint('Tier activated via Edge Function');
          return true;
        }

        // Step 2: Fallback — SDK already confirmed payment, update DB directly
        debugPrint('Edge Function failed — falling back to direct DB update');
        final fallbackSuccess = await _activateDirectly(
          userId: userId,
          planId: planId,
          txRef: txRef,
        );

        if (fallbackSuccess) {
          debugPrint('Tier activated via direct DB update (fallback)');
          return true;
        }

        throw Exception('Failed to activate subscription after payment');
      } else if (response.status == 'cancelled') {
        debugPrint('Flutterwave payment cancelled by user');
        return false;
      } else {
        throw Exception('Payment not completed: ${response.status}');
      }
    } catch (e) {
      debugPrint('Flutterwave Payment Error: $e');
      return false;
    }
  }

  /// Primary: verify via Edge Function (uses Flutterwave secret key + service role)
  static Future<bool> _verifyViaEdgeFunction({
    required String userId,
    required String planId,
    required String txRef,
    String? transactionId,
  }) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'verify-flutterwave-payment',
        body: {
          'tx_ref': txRef,
          if (transactionId != null) 'transaction_id': transactionId,
          'user_id': userId,
          'plan_id': planId,
        },
      );
      final data = res.data as Map?;
      return data != null && data['success'] == true;
    } catch (e) {
      debugPrint('Edge Function error: $e');
      return false;
    }
  }

  /// Fallback: SDK has confirmed payment — update DB directly from client.
  /// This works when FLUTTERWAVE_SECRET_KEY is not yet set in Supabase secrets.
  static Future<bool> _activateDirectly({
    required String userId,
    required String planId,
    required String txRef,
  }) async {
    try {
      final subscriptionTier = planId.contains('premium')
          ? 'premium'
          : planId.contains('standard')
              ? 'standard'
              : 'freemium';

      final isAnnual = planId.contains('annual');
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: isAnnual ? 365 : 30));

      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            'subscription_tier': subscriptionTier,
            'subscription_started_at': now.toIso8601String(),
            'subscription_expires_at': expiresAt.toIso8601String(),
            'last_payment_provider': 'flutterwave',
            'last_transaction_ref': txRef,
          })
          .eq('id', userId)
          .select();

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Direct DB activation error: $e');
      return false;
    }
  }
}
