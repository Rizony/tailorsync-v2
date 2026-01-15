import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../monetization/ui/subscription_badge.dart';
import '../monetization/ui/earnings_card.dart';
import '../session/session_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).session;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// 🔹 ALWAYS visible
          const SubscriptionBadge(),

          const SizedBox(height: 16),

          /// 🔹 Only visible for paid users
          if (session.plan.isPaid) const EarningsCard(),
        ],
      ),
    );
  }
}
