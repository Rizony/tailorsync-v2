import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/monetization/earnings_ledger_entry.dart';

class EarningsHistoryCard extends StatelessWidget {
  final EarningsLedgerEntry entry;

  const EarningsHistoryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(entry.label),
        subtitle: Text('${entry.referralCount} earning referrals'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
  label: Text(
    entry.isPayable ? 'Payable' : 'Below \$50',
    style: const TextStyle(color: Colors.white),
  ),
  backgroundColor: entry.isPayable ? Colors.green : Colors.grey,

),
if (!entry.isPayable)
  const Text(
    'Earnings will roll over until minimum payout is reached.',
    style: TextStyle(fontSize: 12, color: Colors.grey),
  ),

Text('This month: \$${entry.amountUsd.toStringAsFixed(2)}'),
Text(
  'Rollover balance: \$${entry.rolloverBalanceUsd.toStringAsFixed(2)}',
  style: const TextStyle(fontSize: 12, color: Colors.grey),
),


            Text(
              '\$${entry.amountUsd.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              entry.isSettled
                ? 'Paid' : 'Pending',
              style: TextStyle(
                color: entry.isSettled ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
