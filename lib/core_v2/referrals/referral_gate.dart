import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import '../monetization/subscription_plan.dart';

class ReferralGate extends ConsumerWidget {
  final Widget child;

  const ReferralGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(sessionControllerProvider).session.plan;

    if (plan != SubscriptionPlan.premium) {
      return const Center(
        child: Text('Upgrade to Premium to unlock referrals'),
      );
    }

    return child;
  }
}
