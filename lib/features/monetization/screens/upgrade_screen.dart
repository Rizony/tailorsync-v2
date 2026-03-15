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

class _UpgradeScreenState extends ConsumerState<UpgradeScreen>
    with WidgetsBindingObserver {
  bool _isAnnual = false;
  bool _isProcessing = false;
  bool _showComparison = false;

  String? _pendingTxRef;
  String? _pendingUserId;
  String? _pendingPlanId;
  bool _isVerifying = false;
  bool _launchedPaystack = false; // true while browser is open

  PlanPricing? _pendingPlan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called automatically when the app comes back to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _launchedPaystack &&
        _pendingTxRef != null) {
      // Small delay to let the browser fully close first
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _verifyPaystackPayment();
      });
      setState(() => _launchedPaystack = false);
    }
  }

  Future<void> _pay(PlanPricing plan, String method) async {
    setState(() {
      _pendingPlan = plan;
      _isProcessing = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final planId = _isAnnual
          ? '${plan.title.toLowerCase()}_annual'
          : '${plan.title.toLowerCase()}_monthly';
      final amount =
          _isAnnual ? plan.yearlyNaira : plan.monthlyNaira;

      if (method == 'flutterwave') {
        final success = await FlutterwavePaymentWidget.processPayment(
          context: context,
          planId: planId,
          planName: plan.title,
          amountInNaira: amount,
          publicKey: 'FLWPUBK_TEST-c4c8b96627b8fa2ca1bb01d58362e530-X',
        );
        if (success && mounted) {
          await ref.read(profileNotifierProvider.notifier).fetchProfile();
          final newTier = SubscriptionTier.values.firstWhere(
            (t) => t.name.toLowerCase() == plan.title.toLowerCase(),
            orElse: () => SubscriptionTier.standard,
          );
          _showWelcomeDialog(newTier);
        }
      } else {
        // Generate a reference we can use to verify later
        final txRef = 'NEEDLIX_${DateTime.now().millisecondsSinceEpoch}_${user.id}';
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
            setState(() {
              _pendingTxRef = txRef;
              _pendingUserId = user.id;
              _pendingPlanId = planId;
              _launchedPaystack = true; // app will auto-verify on resume
            });
            await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        await ref.read(profileNotifierProvider.notifier).fetchProfile();
        if (mounted) {
          setState(() {
            _pendingTxRef = null;
            _pendingUserId = null;
            _pendingPlanId = null;
            _pendingPlan = null;
          });
          final newTierStr = data['tier']?.toString().toLowerCase() ?? 'freemium';
          final newTier = SubscriptionTier.values.firstWhere(
            (t) => t.name == newTierStr, 
            orElse: () => SubscriptionTier.standard
          );
          _showWelcomeDialog(newTier);
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

  int _tierWeight(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.premium: return 2;
      case SubscriptionTier.standard: return 1;
      case SubscriptionTier.freemium: return 0;
    }
  }

  bool _canUpgradeTo(PlanPricing plan) {
    final currentWeight = _tierWeight(_currentTier());
    final planTier = SubscriptionTier.values.firstWhere(
      (t) => t.name.toLowerCase() == plan.title.toLowerCase(),
      orElse: () => SubscriptionTier.freemium,
    );
    return _tierWeight(planTier) > currentWeight;
  }

  bool _isCurrent(PlanPricing plan) =>
      plan.title.toLowerCase() == _currentTier().name.toLowerCase();

  void _showWelcomeDialog(SubscriptionTier newTier) {
    final features = kPlanFeatures.where((f) {
      if (newTier == SubscriptionTier.premium) return f.premium && !f.standard;
      if (newTier == SubscriptionTier.standard) return f.standard && !f.freemium;
      return false;
    }).map((f) => f.label).toList();

    var displayFeatures = features.isNotEmpty 
        ? features 
        : kPlanFeatures.where((f) => newTier == SubscriptionTier.premium ? f.premium : f.standard).map((f) => f.label).toList();
    if (displayFeatures.length > 5) {
      displayFeatures = displayFeatures.take(5).toList()..add('And much more...');
    }

    final tierName = newTier.label.toUpperCase();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.celebration, color: Colors.orange, size: 48),
            const SizedBox(height: 12),
            Text(
              'Welcome to $tierName!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account has been successfully upgraded. Here is what you just unlocked:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...displayFeatures.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Go back to original screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E78D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Start Exploring', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

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
                          'Upgrade NEEDLIX',
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
                        onUpgrade: _canUpgradeTo(plan)
                            ? () => _showPaymentPicker(plan)
                            : null,
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

                  // ── Payment method is now shown in a ModalBottomSheet ──

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentPickerSheet(
        plan: plan,
        isAnnual: _isAnnual,
        onPay: (method) {
          Navigator.pop(context);
          _pay(plan, method);
        },
      ),
    );
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

class _PaymentPickerSheet extends StatefulWidget {
  const _PaymentPickerSheet({
    required this.plan,
    required this.isAnnual,
    required this.onPay,
  });

  final PlanPricing plan;
  final bool isAnnual;
  final Function(String method) onPay;

  @override
  State<_PaymentPickerSheet> createState() => _PaymentPickerSheetState();
}

class _PaymentPickerSheetState extends State<_PaymentPickerSheet> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final amountLabel = widget.isAnnual ? widget.plan.yearlyLabel() : widget.plan.monthlyLabel();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Subscribe to ${widget.plan.title}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Total amount breakdown: $amountLabel',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 28),

          const Text(
            'SELECT PAYMENT METHOD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),

          _MethodTile(
            label: 'Paystack',
            subtitle: 'Secure card & bank transfer',
            icon: Icons.account_balance_wallet_outlined,
            selected: _selectedMethod == 'paystack',
            onTap: () => setState(() => _selectedMethod = 'paystack'),
          ),
          const SizedBox(height: 12),
          _MethodTile(
            label: 'Flutterwave',
            subtitle: 'Online payment gateway',
            icon: Icons.bolt,
            selected: _selectedMethod == 'flutterwave',
            onTap: () => setState(() => _selectedMethod = 'flutterwave'),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _selectedMethod != null ? () => widget.onPay(_selectedMethod!) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E78D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Confirm and Pay',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E78D2).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF1E78D2) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF1E78D2).withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? const Color(0xFF1E78D2) : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: selected ? const Color(0xFF1E78D2) : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF1E78D2), size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 24),
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
