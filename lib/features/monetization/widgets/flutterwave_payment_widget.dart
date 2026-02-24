import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget to handle Flutterwave payment
class FlutterwavePaymentWidget {
  /// Process payment with Flutterwave
  static Future<bool> processPayment({
    required BuildContext context,
    required String planId,
    required String planName,
    required int amountInNaira,
    required String publicKey,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final userEmail = user.email ?? '';
      final userName = user.userMetadata?['full_name'] ?? 'User';
      final userId = user.id;

      // Generate transaction reference
      final txRef = "tailorsync_${DateTime.now().millisecondsSinceEpoch}_$userId";

      final flutterwave = Flutterwave(
        publicKey: publicKey,
        currency: "NGN",
        txRef: txRef,
        amount: amountInNaira.toString(),
        // Flutterwave Standard SDK requires a redirect URL even for mobile flows.
        // This can be any HTTPS URL you control.
        redirectUrl: "https://tailorsync.app/payment-callback",
        paymentOptions: "card, banktransfer, ussd, account",
        customization: Customization(
          title: "TailorSync Subscription",
          description: "Subscribe to $planName plan - ₦${amountInNaira.toString()}/month",
          logo: "https://tailorsync.app/logo.png",
        ),
        customer: Customer(
          name: userName,
          email: userEmail,
          phoneNumber: user.userMetadata?['phone'] ?? '',
        ),
        isTestMode: publicKey.contains('TEST'), // Auto-detect test mode
      );

      final ChargeResponse response = await flutterwave.charge(context);

      if (response.status == "successful") {
        // Payment successful - verify and activate subscription
        final success = await _verifyAndActivateSubscription(
          userId: userId,
          planId: planId,
          transactionReference: txRef,
          paymentProvider: 'flutterwave',
        );

        if (success) {
          return true;
        } else {
          throw Exception("Failed to activate subscription");
        }
      } else {
        throw Exception("Payment ${response.status}");
      }
    } catch (e) {
      debugPrint("Flutterwave Payment Error: $e");
      return false;
    }
  }

  /// Verify payment via Edge Function (service role — bypasses RLS)
  static Future<bool> _verifyAndActivateSubscription({
    required String userId,
    required String planId,
    required String transactionReference,
    required String paymentProvider,
    String? transactionId,
  }) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'verify-flutterwave-payment',
        body: {
          'tx_ref': transactionReference,
          if (transactionId != null) 'transaction_id': transactionId,
          'user_id': userId,
          'plan_id': planId,
        },
      );
      final data = res.data as Map?;
      return data != null && data['success'] == true;
    } catch (e) {
      debugPrint('Flutterwave verify Edge Function error: $e');
      return false;
    }
  }
}
