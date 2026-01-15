import 'subscription_plan.dart';

enum Feature {
  analytics,
  exports,
  partnerBranding,
  advancedOrders,
}

class FeatureGate {
  static const Map<SubscriptionPlan, Set<Feature>> _access = {
    SubscriptionPlan.free: {
      Feature.advancedOrders,
    },
    SubscriptionPlan.standard: {
      Feature.advancedOrders,
      Feature.analytics,
      Feature.exports,
    },
    SubscriptionPlan.premium: {
      Feature.advancedOrders,
      Feature.analytics,
      Feature.exports,
      Feature.partnerBranding,
    },
  };

  static bool canAccess(
    SubscriptionPlan plan,
    Feature feature,
  ) {
    final features = _access[plan];

    if (features == null) {
      throw StateError(
        'No feature configuration for plan: $plan',
      );
    }

    return features.contains(feature);
  }
}
