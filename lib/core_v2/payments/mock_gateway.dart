import 'payment_gateway.dart';
import '../monetization/subscription_plan.dart';

class MockPaymentGateway implements PaymentGateway {
  @override
  Future<bool> subscribe(SubscriptionPlan plan) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always succeed for now
  }

  @override
  Future<void> restore() async {}
}
