
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/orders/repositories/order_repository.dart';
import 'package:needlix/features/community/repositories/community_repository.dart';
import 'package:needlix/features/community/models/community_post.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/notifications/whatsapp_service.dart';

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

  Future<void> deleteOrder(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(orderRepositoryProvider).deleteOrder(id);
      return result.fold(
        (failure) => throw failure,
        (_) => null,
      );
    });
  }

  Future<void> shareToShowroom() async {
    final currentOrder = state.valueOrNull;
    if (currentOrder == null) return;
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    if (profile == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final post = CommunityPost(
        id: '', // Handled by repository
        userId: profile.id,
        postType: 'showroom',
        title: 'Showcase: ${currentOrder.title}',
        content: 'Check out my latest completed work! 🧵✨\n\n'
                '${currentOrder.notes ?? "Just finished this beautiful piece."}',
        imageUrls: currentOrder.images,
        createdAt: DateTime.now(),
      );
      
      await ref.read(communityRepositoryProvider).createPost(post);

      if (currentOrder.images.isNotEmpty) {
        final newPortfolio = List<String>.from(profile.portfolioUrls);
        bool modified = false;
        for (final img in currentOrder.images) {
          if (!newPortfolio.contains(img)) {
            newPortfolio.add(img);
            modified = true;
          }
        }
        if (modified) {
          await ref.read(profileNotifierProvider.notifier).updateProfile(
            profile.copyWith(portfolioUrls: newPortfolio)
          );
        }
      }
      return currentOrder;
    });
  }

  Future<void> sendStatusUpdate(String customerPhone, String customerName, String notifyMethod) async {
    final currentOrder = state.valueOrNull;
    if (currentOrder == null || customerPhone.isEmpty) return;
    final profile = ref.read(profileNotifierProvider).valueOrNull;

    if (notifyMethod == 'whatsapp') {
      await WhatsAppService.sendStatusUpdate(
        phoneNumber: customerPhone,
        customerName: customerName,
        orderTitle: currentOrder.title,
        status: currentOrder.status,
        shopName: profile?.shopName,
        balanceDue: currentOrder.balanceDue.toStringAsFixed(2),
        currency: profile?.currencySymbol,
        dueDate: currentOrder.dueDate,
      );
    } else if (notifyMethod == 'sms') {
      await WhatsAppService.sendSMSUpdate(
        phoneNumber: customerPhone,
        customerName: customerName,
        orderTitle: currentOrder.title,
        status: currentOrder.status,
        shopName: profile?.shopName,
        balanceDue: currentOrder.balanceDue.toStringAsFixed(2),
        currency: profile?.currencySymbol,
        dueDate: currentOrder.dueDate,
      );
    }
  }
}
