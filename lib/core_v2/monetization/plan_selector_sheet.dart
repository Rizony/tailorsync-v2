import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import 'subscription_plan.dart';

class PlanSelectorSheet extends ConsumerWidget {
  const PlanSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(sessionControllerProvider);
    final currentPlan = controller.session.plan;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            for (final plan in SubscriptionPlan.values)
              _planTile(
                context,
                controller,
                plan,
                isActive: plan == currentPlan,
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _planTile(
    BuildContext context,
    SessionController controller,
    SubscriptionPlan plan, {
    required bool isActive,
  }) {
    return Card(
      child: ListTile(
        title: Text(plan.displayName),
        subtitle: Text(
          plan.isPaid
              ? '\$${plan.monthlyPriceUsd.toStringAsFixed(2)} / month'
              : 'Free forever',
        ),
        trailing: isActive
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        enabled: !isActive,
        onTap: isActive
            ? null
            : () {
                controller.updatePlan(plan);
                Navigator.pop(context);
              },
      ),
    );
  }
}
