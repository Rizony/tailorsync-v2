import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/session_controller.dart';
import '../subscription_plan.dart';

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PlanTile(
              plan: SubscriptionPlan.standard,
              price: 3,
              onSelect: () {
                controller.updatePlan(SubscriptionPlan.standard);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _PlanTile(
              plan: SubscriptionPlan.premium,
              price: 5,
              onSelect: () {
                controller.updatePlan(SubscriptionPlan.premium);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final SubscriptionPlan plan;
  final double price;
  final VoidCallback onSelect;

  const _PlanTile({
    required this.plan,
    required this.price,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(plan.displayName)
,
        subtitle: Text('\$$price / month'),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: const Text('Select'),
        ),
      ),
    );
  }
}
