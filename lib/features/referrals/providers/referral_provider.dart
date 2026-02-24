import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Summary stats for the referral dashboard
class ReferralStats {
  final int totalReferrals;
  final double totalEarned;
  final double thisMonthEarned;
  final List<Map<String, dynamic>> transactions;

  const ReferralStats({
    required this.totalReferrals,
    required this.totalEarned,
    required this.thisMonthEarned,
    required this.transactions,
  });
}

/// Fetches referral stats for the current user from Supabase.
final referralStatsProvider = FutureProvider<ReferralStats>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) {
    return const ReferralStats(
        totalReferrals: 0, totalEarned: 0, thisMonthEarned: 0, transactions: []);
  }

  final txRows = await Supabase.instance.client
      .from('referral_transactions')
      .select()
      .eq('referrer_id', uid)
      .order('created_at', ascending: false);

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  double totalEarned = 0;
  double thisMonthEarned = 0;
  final Set<String> uniqueReferred = {};

  for (final row in txRows) {
    final amount = (row['commission_amount'] as num?)?.toDouble() ?? 0.0;
    totalEarned += amount;

    final createdAt = row['created_at'] != null
        ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime(2000)
        : DateTime(2000);
    if (createdAt.isAfter(startOfMonth)) thisMonthEarned += amount;

    final referredId = row['referred_user_id']?.toString();
    if (referredId != null) uniqueReferred.add(referredId);
  }

  return ReferralStats(
    totalReferrals: uniqueReferred.length,
    totalEarned: totalEarned,
    thisMonthEarned: thisMonthEarned,
    transactions: List<Map<String, dynamic>>.from(txRows),
  );
});
