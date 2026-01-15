import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/referrals/referral_limits.dart';

import '../session/session_controller.dart';
import '../monetization/subscription_plan.dart';

class ReferralDebugPanel extends ConsumerWidget {
  const ReferralDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 Debug only
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final controller = ref.read(sessionControllerProvider);
    final count = ref.watch(sessionControllerProvider).session.referralCount;
    final atCap = count >= maxActiveReferrals;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Referral Debug',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Wrap(
  spacing: 8,
  children: [
    ElevatedButton(
      onPressed: atCap
          ? null
          : () => controller.addReferral(
                userId: DateTime.now().millisecondsSinceEpoch.toString(),
                plan: SubscriptionPlan.standard,
              ),
      child: const Text('Add Standard Referral'),
    ),

    ElevatedButton(
      onPressed: atCap
          ? null
          : () => controller.addReferral(
                userId: DateTime.now().millisecondsSinceEpoch.toString(),
                plan: SubscriptionPlan.premium,
              ),
      child: const Text('Add Premium Referral'),
    ),

    ElevatedButton.icon(
      icon: const Icon(Icons.refresh),
      label: const Text('Recompute Ledger'),
      onPressed: controller.rebuildLedger,
    ),

    ElevatedButton(
      onPressed: controller.canRequestPayout
          ? controller.requestPayout
          : null,
      child: const Text('Request Payout'),
      
    ),

    ElevatedButton(
      onPressed: controller.approveLatestPayout,
      child: const Text('Admin: Approve Payout'),
    ),
  ],
)

      ],
    );
  }
}