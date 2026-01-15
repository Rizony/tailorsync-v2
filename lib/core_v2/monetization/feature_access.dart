import 'subscription_plan.dart';
import 'feature_gate.dart';

enum AppFeature {
  adsFree,
  partnerProgram,
  unlimitedJobs,
  customerManagement,
  invoicing,
}

class FeatureAccess {
  static bool canUse(
    AppFeature feature,
    SubscriptionPlan plan,
  ) {
    switch (feature) {
      case AppFeature.adsFree:
        return plan.isPaid;

      case AppFeature.partnerProgram:
        return FeatureGate.canAccess(
          plan,
          Feature.partnerBranding,
        );

      case AppFeature.unlimitedJobs:
        return FeatureGate.canAccess(
          plan,
          Feature.advancedOrders,
        );

      case AppFeature.customerManagement:
        return plan != SubscriptionPlan.free;

      case AppFeature.invoicing:
        return plan != SubscriptionPlan.free;
    }
  }
}
