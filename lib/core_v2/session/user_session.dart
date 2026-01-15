import '../monetization/subscription_plan.dart';

class UserSession {
  final String userId;

  final SubscriptionPlan plan;

  // Partner stats
  final int referralCount;

  // UI preferences
  final bool isDarkMode;
  final bool isSeasonalThemeEnabled;

  const UserSession({
    required this.userId,
    required this.plan,
    required this.referralCount,
    required this.isDarkMode,
    required this.isSeasonalThemeEnabled,
  });

  bool get isPremium => plan == SubscriptionPlan.premium;
  bool get isStandard => plan == SubscriptionPlan.standard;
  bool get isFree => plan == SubscriptionPlan.free;

  Map<String, dynamic> toJson() => {
  'userId': userId,
  'plan': plan.name,
  'referralCount': referralCount,
  'isDarkMode': isDarkMode,
  'isSeasonalThemeEnabled': isSeasonalThemeEnabled,
};

factory UserSession.fromJson(Map<String, dynamic> json) {
  return UserSession(
    userId: json['userId'],
    plan: SubscriptionPlan.values
        .firstWhere((e) => e.name == json['plan']),
    referralCount: json['referralCount'],
    isDarkMode: json['isDarkMode'],
    isSeasonalThemeEnabled: json['isSeasonalThemeEnabled'],
  );
}
UserSession copyWith({
  String? userId,
  SubscriptionPlan? plan,
  int? referralCount,
  bool? isDarkMode,
  bool? isSeasonalThemeEnabled,
}) {
  return UserSession(
    userId: userId ?? this.userId,
    plan: plan ?? this.plan,
    referralCount: referralCount ?? this.referralCount,
    isDarkMode: isDarkMode ?? this.isDarkMode,
    isSeasonalThemeEnabled:
        isSeasonalThemeEnabled ?? this.isSeasonalThemeEnabled,
  );
}

}
