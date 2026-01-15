import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/monetization/ui/upgrade_screen.dart';

import '../../session/session_controller.dart';
import '../subscription_plan.dart';

class SubscriptionBadge extends ConsumerWidget {
  const SubscriptionBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(sessionControllerProvider);
    final plan = controller.session.plan;

    final color = switch (plan) {
      SubscriptionPlan.free => Colors.grey,
      SubscriptionPlan.standard => Colors.blue,
      SubscriptionPlan.premium => Colors.amber,
    };

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Chip(
              label: Text(
                plan.displayName,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: color,
            ),
            const Spacer(),
            if (plan == SubscriptionPlan.free)
              ElevatedButton(
                onPressed: () {
                  _showUpgradeDialog(context);
                },
                child: const Text('Upgrade'),
              ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upgrade your plan'),
        content: const Text(
          'Upgrade to Standard or Premium to unlock referral earnings and advanced features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
  Navigator.pop(context); // close dialog first

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const UpgradeScreen(),
    ),
  );
},

            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }
}
