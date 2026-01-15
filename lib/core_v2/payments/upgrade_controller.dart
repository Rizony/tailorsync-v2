import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import '../monetization/subscription_plan.dart';
import 'payment_gateway.dart';
import 'mock_gateway.dart';

final paymentGatewayProvider =
    Provider<PaymentGateway>((_) => MockPaymentGateway());

final upgradeControllerProvider =
    Provider((ref) => UpgradeController(ref));

class UpgradeController {
  final Ref ref;
  UpgradeController(this.ref);

  Future<void> upgrade(SubscriptionPlan plan) async {
    final gateway = ref.read(paymentGatewayProvider);
    final success = await gateway.subscribe(plan);

    if (success) {
      ref.read(sessionControllerProvider).updatePlan(plan);
    }
  }
}
