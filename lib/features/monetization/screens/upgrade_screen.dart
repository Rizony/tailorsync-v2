import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tailorsync_v2/core/billing/billing_service.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/models/plan_data.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';
import '../widgets/plan_card.dart';
import '../widgets/flutterwave_payment_widget.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  bool _isAnnual = false;
  bool _isProcessing = false;
  bool _showComparison = false;

  // Paystack post-payment verification
  String? _pendingTxRef;    // stored after browser opens
  String? _pendingUserId;
  String? _pendingPlanId;   // e.g. 'standard_monthly'
  bool _isVerifying = false;

  String? _pendingPaymentMethod; // chosen after tapping a plan
  PlanPricing? _pendingPlan;

  Future<void> _pay(PlanPricing plan) async {
    if (_pendingPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a payment method first')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final planId = _isAnnual
          ? '${plan.title.toLowerCase()}_annual'
          : '${plan.title.toLowerCase()}_monthly';
      final amount =
          _isAnnual ? plan.yearlyNaira : plan.monthlyNaira;

      if (_pendingPaymentMethod == 'flutterwave') {
        final success = await FlutterwavePaymentWidget.processPayment(
          context: context,
          planId: planId,
          planName: plan.title,
          amountInNaira: amount,
          publicKey: 'FLWPUBK_TEST-c4c8b96627b8fa2ca1bb01d58362e530-X',
        );
        if (success && mounted) ref.invalidate(profileNotifierProvider);
      } else {
        // Generate a reference we can use to verify later
        final txRef = 'tailorsync_${DateTime.now().millisecondsSinceEpoch}_${user.id}';
        final paymentUrl = await BillingService.getPaystackPaymentUrl(
          userEmail: user.email ?? '',
          amountInNaira: amount,
          planId: planId,
          userId: user.id,
          planName: plan.title,
        );
        if (paymentUrl != null) {
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            // Store reference so user can verify in-app after returning
            if (mounted) {
              setState(() {
                _pendingTxRef = txRef;
                _pendingUserId = user.id;
                _pendingPlanId = planId;
              });
            }
          }
        } else {
          throw Exception('Failed to generate payment link');
        }
      }
      ref.invalidate(profileNotifierProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Calls the verify-paystack-payment Edge Function to confirm payment
  /// and update subscription_tier without waiting for webhook.
  Future<void> _verifyPaystackPayment() async {
    if (_pendingTxRef == null || _pendingUserId == null || _pendingPlanId == null) return;
    setState(() => _isVerifying = true);
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'verify-paystack-payment',
        body: {
          'reference': _pendingTxRef,
          'user_id': _pendingUserId,
          'plan_id': _pendingPlanId,
        },
      );
      final data = res.data as Map?;
      if (data != null && data['success'] == true) {
        ref.invalidate(profileNotifierProvider);
        if (mounted) {
          setState(() {
            _pendingTxRef = null;
            _pendingUserId = null;
            _pendingPlanId = null;
            _pendingPlan = null;
            _pendingPaymentMethod = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 ${(data['tier']?.toString() ?? 'Subscription').toUpperCase().substring(0, 1)}${(data['tier']?.toString() ?? 'subscription').substring(1)} plan activated!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data?['error'] ?? 'Payment not found. Please wait a moment and try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  SubscriptionTier _currentTier() =>
      ref.watch(profileNotifierProvider).valueOrNull?.subscriptionTier ??
      SubscriptionTier.freemium;

  bool _isCurrent(PlanPricing plan) =>
      plan.title.toLowerCase() == _currentTier().name.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFreemium = _currentTier() == SubscriptionTier.freemium;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E78D2),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E78D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Upgrade TailorSync',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isFreemium
                              ? 'You\'re missing out on powerful tools!'
                              : 'Choose the plan that fits your business.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Billing Toggle ────────────────────────────
                  _BillingToggle(
                    isAnnual: _isAnnual,
                    onChanged: (v) => setState(() => _isAnnual = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Plan Cards ────────────────────────────────
                  ...kPlans.map((plan) => PlanCard(
                        plan: plan,
                        isAnnual: _isAnnual,
                        isCurrent: _isCurrent(plan),
                        isProcessing:
                            _isProcessing && _pendingPlan == plan,
                        onUpgrade: _isCurrent(plan) || plan.monthlyNaira == 0
                            ? null
                            : () => _showPaymentPicker(plan),
                      )),

                  // ── Post-payment verify card (shown after Paystack browser) ──
                  if (_pendingTxRef != null) ...[
                    _VerifyCard(
                      isVerifying: _isVerifying,
                      onVerify: _verifyPaystackPayment,
                      onDismiss: () => setState(() {
                        _pendingTxRef = null;
                        _pendingUserId = null;
                        _pendingPlanId = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Payment method (shown after selecting a plan) ─
                  if (_pendingPlan != null) ...[
                    _PaymentSection(
                      planName: _pendingPlan!.title,
                      selected: _pendingPaymentMethod,
                      onMethodSelected: (m) =>
                          setState(() => _pendingPaymentMethod = m),
                      onConfirm: () => _pay(_pendingPlan!),
                      isProcessing: _isProcessing,
                      onCancel: () => setState(() {
                        _pendingPlan = null;
                        _pendingPaymentMethod = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Full Feature Comparison ───────────────────
                  _ComparisonToggle(
                    expanded: _showComparison,
                    onToggle: () =>
                        setState(() => _showComparison = !_showComparison),
                  ),
                  if (_showComparison) ...[
                    const SizedBox(height: 12),
                    _ComparisonTable(),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentPicker(PlanPricing plan) {
    setState(() {
      _pendingPlan = plan;
      _pendingPaymentMethod = null;
    });
    // Scroll down a tiny bit so the payment section is visible
    Future.delayed(const Duration(milliseconds: 100));
  }
}

// ─────────────────────────────────────────────
// Billing Toggle (Monthly / Annual)
// ─────────────────────────────────────────────
class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.isAnnual, required this.onChanged});
  final bool isAnnual;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
              label: 'Monthly',
              selected: !isAnnual,
              onTap: () => onChanged(false)),
          _Tab(
            label: 'Annual',
            badge: 'SAVE 2 MONTHS',
            selected: isAnnual,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.badge});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1E78D2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.grey[600],
                ),
              ),
              if (badge != null && selected)
                Text(
                  badge!,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Payment Method Section
// ─────────────────────────────────────────────
class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.planName,
    required this.selected,
    required this.onMethodSelected,
    required this.onConfirm,
    required this.isProcessing,
    required this.onCancel,
  });

  final String planName;
  final String? selected;
  final ValueChanged<String> onMethodSelected;
  final VoidCallback onConfirm;
  final bool isProcessing;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: Color(0xFF1E78D2)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pay for $planName Plan',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onCancel,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Select payment method:',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MethodTile(
                  label: 'Flutterwave',
                  icon: Icons.bolt,
                  selected: selected == 'flutterwave',
                  onTap: () => onMethodSelected('flutterwave'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MethodTile(
                  label: 'Paystack',
                  icon: Icons.account_balance_wallet_outlined,
                  selected: selected == 'paystack',
                  onTap: () => onMethodSelected('paystack'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected != null && !isProcessing ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E78D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Proceed to Payment',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1E78D2).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF1E78D2) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? const Color(0xFF1E78D2) : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? const Color(0xFF1E78D2) : Colors.grey[700],
                )),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle,
                  size: 14, color: Color(0xFF1E78D2)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Feature Comparison Table
// ─────────────────────────────────────────────
class _ComparisonToggle extends StatelessWidget {
  const _ComparisonToggle(
      {required this.expanded, required this.onToggle});
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.table_chart_outlined, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Compare all features',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Icon(expanded
                ? Icons.expand_less
                : Icons.expand_more),
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  _ComparisonTable();

  final List<String> _headers = ['Feature', 'Free', 'Std', 'Pro'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: _headers.map((h) {
                final isFirst = h == 'Feature';
                return Expanded(
                  flex: isFirst ? 3 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 10),
                    child: Text(h,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign:
                            isFirst ? TextAlign.left : TextAlign.center),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Feature rows
          ...kPlanFeatures.asMap().entries.map((e) {
            final i = e.key;
            final f = e.value;
            return Column(
              children: [
                if (i > 0) const Divider(height: 1, indent: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 9),
                        child: Text(f.label,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    _Cell(has: f.freemium),
                    _Cell(has: f.standard),
                    _Cell(has: f.premium, isPremium: true),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.has, this.isPremium = false});
  final bool has;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Icon(
        has ? Icons.check_circle : Icons.remove,
        size: 18,
        color: has
            ? (isPremium ? const Color(0xFFF58220) : Colors.green)
            : Colors.grey.shade300,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Verify Payment Card (shown after Paystack browser)
// ─────────────────────────────────────────────
class _VerifyCard extends StatelessWidget {
  const _VerifyCard({
    required this.isVerifying,
    required this.onVerify,
    required this.onDismiss,
  });

  final bool isVerifying;
  final VoidCallback onVerify;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Payment completed?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap below to verify your payment and activate your plan instantly.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isVerifying ? null : onVerify,
              icon: isVerifying
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.verified, size: 18),
              label: Text(isVerifying ? 'Verifying...' : "I've Paid — Activate Plan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
