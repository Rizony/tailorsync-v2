
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tailorsync_v2/features/orders/models/order_model.dart';
import 'package:tailorsync_v2/features/orders/repositories/order_repository.dart';

part 'order_controller.g.dart';

@riverpod
class OrderController extends _$OrderController {
  @override
  Future<OrderModel?> build(String orderId) async {
    // Fetch the specific order by ID
    final result = await ref.read(orderRepositoryProvider).getOrder(orderId);
    return result.fold(
      (failure) => throw failure,
      (order) => order,
    );
  }

  Future<void> updateStatus(String newStatus) async {
    final currentOrder = state.valueOrNull;
    if (currentOrder == null) return;

    // Optimistic update or waiting?
    // Let's set loading state
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedOrder = currentOrder.copyWith(status: newStatus);
      final result = await ref.read(orderRepositoryProvider).updateOrder(updatedOrder);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedOrder,
      );
    });
  }

  Future<void> recordPayment(double amount, {String? note, String? paymentMethod}) async {
    final currentOrder = state.valueOrNull;
    if (currentOrder == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newPayment = Payment(
        amount: amount,
        date: DateTime.now(),
        note: note,
        paymentMethod: paymentMethod,
      );

      final updatedOrder = currentOrder.copyWith(
        payments: [...currentOrder.payments, newPayment],
        balanceDue: (currentOrder.balanceDue - amount).clamp(0, double.infinity),
      );

      final result = await ref.read(orderRepositoryProvider).updateOrder(updatedOrder);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedOrder,
      );
    });
  }

  Future<void> updateFabricStatus(String status, {String? source}) async {
    final currentOrder = state.valueOrNull;
    if (currentOrder == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedOrder = currentOrder.copyWith(
        fabricStatus: status,
        fabricSource: source ?? currentOrder.fabricSource,
      );
      final result = await ref.read(orderRepositoryProvider).updateOrder(updatedOrder);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedOrder,
      );
    });
  }

  Future<void> convertQuoteToOrder(double deposit, double total) async {
    final currentOrder = state.valueOrNull;
    if (currentOrder == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final initialPayment = Payment(
        amount: deposit,
        date: DateTime.now(),
        note: 'Initial Deposit (Converted from Quote)',
      );

      final updatedOrder = currentOrder.copyWith(
        status: OrderModel.statusPending,
        price: total,
        balanceDue: (total - deposit).clamp(0, double.infinity),
        payments: [...currentOrder.payments, initialPayment],
      );
      final result = await ref.read(orderRepositoryProvider).updateOrder(updatedOrder);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedOrder,
      );
    });
  }
}
