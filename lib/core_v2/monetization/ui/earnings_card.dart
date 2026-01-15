import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../monetization_providers.dart';

class EarningsCard extends ConsumerWidget {
  const EarningsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEarn = ref.watch(canEarnReferralsProvider);
    final earnings = ref.watch(monthlyEarningsProvider);
    final referrals = ref.watch(referralCountProvider);

    if (!canEarn) {
      return const SizedBox.shrink();
    }
    

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Referral Earnings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${earnings.toStringAsFixed(2)} / month',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$referrals active referral${referrals == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
