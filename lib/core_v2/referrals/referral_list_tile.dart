import 'package:flutter/material.dart';
import '../referrals/referral.dart';

class ReferralListTile extends StatelessWidget {
  final Referral referral;
  final double monthlyEarning;

  const ReferralListTile({
    super.key,
    required this.referral,
    required this.monthlyEarning,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person_outline),

      title: Text('User ${referral.referredUserId}'),

      subtitle: Text(
        referral.isActive
            ? (referral.isFirstMonth
                ? 'First month (40%)'
                : 'Recurring (10%)')
            : 'Cancelled',
        style: TextStyle(
          color: referral.isActive ? null : Colors.red,
        ),
      ),

      trailing: referral.isActive
          ? Text(
              '\$${monthlyEarning.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          : const Text(
              '\$0.00',
              style: TextStyle(color: Colors.grey),
            ),
    );
  }
}
