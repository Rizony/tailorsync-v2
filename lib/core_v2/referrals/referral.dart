import 'package:tailorsync_v2/core_v2/monetization/subscription_plan.dart';

class Referral {
  final String referredUserId;
  final SubscriptionPlan plan;
  final DateTime subscribedAt;
  final DateTime? cancelledAt;

  const Referral({
    required this.referredUserId,
    required this.plan,
    required this.subscribedAt,
    this.cancelledAt,
  });

  bool get isActive => cancelledAt == null;

  bool get isFirstMonth {
    final now = DateTime.now();
    return now.difference(subscribedAt).inDays <= 30;
  }

  Referral cancel() {
    return Referral(
      referredUserId: referredUserId,
      plan: plan,
      subscribedAt: subscribedAt,
      cancelledAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'referredUserId': referredUserId,
        'plan': plan.name,
        'subscribedAt': subscribedAt.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
      };

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      referredUserId: json['referredUserId'],
      plan: SubscriptionPlan.values
          .firstWhere((e) => e.name == json['plan']),
      subscribedAt: DateTime.parse(json['subscribedAt']),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
    );
  }
}
