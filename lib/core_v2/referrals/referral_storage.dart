import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'referral.dart';
import '../monetization/subscription_plan.dart';

class ReferralStorage {
  static const _key = 'referrals';

  static Future<List<Referral>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;

    return decoded.map((e) {
      return Referral(
        referredUserId: e['userId'],
        plan: SubscriptionPlan.values
            .firstWhere((p) => p.name == e['plan']),
        subscribedAt: DateTime.parse(e['subscribedAt']),
      );
    }).toList();
  }

  static Future<void> save(List<Referral> referrals) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      referrals.map((r) {
        return {
          'userId': r.referredUserId,
          'plan': r.plan.name,
          'subscribedAt': r.subscribedAt.toIso8601String(),
        };
      }).toList(),
    );

    await prefs.setString(_key, encoded);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
