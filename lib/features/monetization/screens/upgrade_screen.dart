import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tailorsync_v2/core/billing/billing_service.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import '../widgets/plan_card.dart';
import '../widgets/flutterwave_payment_widget.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  String? _selectedPaymentMethod; // 'flutterwave' or 'paystack'
  bool _isProcessing = false;

  Future<void> _handlePlanSelection(String planId, String planName, int amount) async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final userEmail = user.email ?? '';

      if (_selectedPaymentMethod == 'flutterwave') {
        // Process Flutterwave payment
        
        // Get it from: https://dashboard.flutterwave.com/ → Settings → API Keys
        final success = await FlutterwavePaymentWidget.processPayment(
          context: context,
          planId: planId,
          planName: planName,
          amountInNaira: amount,
          publicKey: 'FLWPUBK_TEST-b479ce503a1b9c3554ed266761ad0ffc-X',  );
        
        if (success && mounted) {
          ref.invalidate(profileNotifierProvider);
        }
      } else if (_selectedPaymentMethod == 'paystack') {
        // Get Paystack payment URL
        final paymentUrl = await BillingService.getPaystackPaymentUrl(
          userEmail: userEmail,
          amountInNaira: amount,
          planId: planId,
          userId: user.id,
          planName: planName,
        );

        if (paymentUrl != null) {
          // Open payment URL in browser
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payment page opened. Complete payment to activate your subscription."),
                  duration: Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          throw Exception("Failed to generate payment link");
        }
      }

      // Refresh user profile after payment
      ref.invalidate(profileNotifierProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = ref.watch(profileNotifierProvider).value?.subscriptionTier;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade Account"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose the right fit for your shop",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Grow your tailoring business with better tools.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Payment Method Selection
            if (currentTier?.name != 'Premium' && currentTier?.name != 'Standard')
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Payment Method",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentMethodCard(
                            title: "Flutterwave",
                            icon: Icons.payment,
                            isSelected: _selectedPaymentMethod == 'flutterwave',
                            onTap: () => setState(() => _selectedPaymentMethod = 'flutterwave'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PaymentMethodCard(
                            title: "Paystack",
                            icon: Icons.account_balance_wallet,
                            isSelected: _selectedPaymentMethod == 'paystack',
                            onTap: () => setState(() => _selectedPaymentMethod = 'paystack'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Freemium Plan (for comparison)
            PlanCard(
              title: "Freemium",
              price: "Free",
              features: const [
                "Up to 20 customers (base)",
                "Watch ads to add more (1 per ad)",
                "Maximum 50 customers total",
                "Daily ad gate to unlock app",
                "Video ads in app",
              ],
              onSelect: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You're already on the Freemium plan")),
                );
              },
            ),

            // Standard Plan
            PlanCard(
              title: "Standard",
              price: "₦3,000/mo",
              features: const [
                "Everything in Freemium",
                "No Video Ads",
                "Unlimited Customers",
                "Cloud Backup (Customers, Orders, Invoices, Settings)",
                "PDF Invoices & Quotations",
              ],
              onSelect: () {
                if (_isProcessing) return;
                _handlePlanSelection('standard_monthly', 'Standard', 3000);
              },
            ),

            // Premium Plan
            PlanCard(
              title: "Premium",
              price: "₦5,000/mo",
              isPopular: true,
              features: const [
                "Everything in Standard",
                "Partner & Referral System",
                "Earn 40% commission on first month",
                "Earn 20% commission on recurring subscriptions",
                "Passive Income Tracking",
                "Only Premium users can refer others",
              ],
              onSelect: () {
                if (_isProcessing) return;
                _handlePlanSelection('premium_monthly', 'Premium', 5000);
              },
            ),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D3FD3).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF5D3FD3) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF5D3FD3) : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF5D3FD3) : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF5D3FD3), size: 16),
          ],
        ),
      ),
    );
  }
}
