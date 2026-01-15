import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/monetization/earnings_history_card.dart';
import 'package:tailorsync_v2/core_v2/referrals/referral_limits.dart';
import 'package:tailorsync_v2/core_v2/referrals/referral_list_tile.dart';

import '../session/session_controller.dart';
import '../monetization/earnings_resolver.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final controller = ref.watch(sessionControllerProvider);
    final session = controller.session;
    
    final plan = session.plan;
    

if (!plan.canViewEarnings) {
  return Scaffold(
    appBar: AppBar(title: const Text('Earnings')),
    body: const Center(
      child: Text(
        'Upgrade to unlock referral earnings.',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

    final breakdown = EarningsResolver.breakdown(
      referrerPlan: session.plan,
      referralCount: session.referralCount,
      price: session.plan.monthlyPriceUsd,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Plan', session.plan.displayName),
            _infoTile('Referrals', '${session.referralCount}'),

            const SizedBox(height: 24),

            _earningsTile(
              label: 'First Month Commission (40%)',
              value: breakdown.firstMonth,
            ),
            _earningsTile(
              label: 'Recurring Monthly (10%)',
              value: breakdown.recurring,
            ),

            const Divider(height: 32),

            _earningsTile(
              label: 'Total Monthly Earnings',
              value: breakdown.total,
              highlight: true,
            ),
            if (controller.canRequestPayout)
  Padding(
    padding: const EdgeInsets.only(top: 16),
    child: ElevatedButton.icon(
      icon: const Icon(Icons.account_balance_wallet),
      label: const Text('Request Payout'),
      onPressed: controller.requestPayout,
    ),
  ),

            const SizedBox(height: 24),
const Divider(),
const SizedBox(height: 12),
const Text(
  'Referral Breakdown',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),

if (session.referralCount >= maxActiveReferrals)
  Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange),
    ),
    child: const Text(
      'You’ve reached the maximum of 100 earning referrals.',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.referrals.length,
                itemBuilder: (context, index) {
                  final referral = controller.referrals[index];
                  final earning = controller.earningForReferral(referral);

                  return ReferralListTile(
                    
                    referral: referral,
                    monthlyEarning: earning,
                    
                  );

                  
                },
              ),
            ),
const SizedBox(height: 24),
const Text(
  'Earnings History',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),

if (controller.ledger.isEmpty)
  const Text('No payout history yet.'),

for (final entry in controller.ledger)
  EarningsHistoryCard(entry: entry),
  

          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  

  Widget _earningsTile({
    required String label,
    required double value,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: highlight ? 20 : 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
