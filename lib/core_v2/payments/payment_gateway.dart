import '../monetization/subscription_plan.dart';

abstract class PaymentGateway {
  Future<bool> subscribe(SubscriptionPlan plan);
  Future<void> restore();
}
