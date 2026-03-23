import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:needlix/core/errors/failures.dart';
import 'package:needlix/core/utils/error_handler_util.dart';
import 'package:needlix/core/sync/models/sync_action.dart';
import 'package:needlix/core/sync/sync_manager.dart';
import '../models/order_model.dart';

import 'package:needlix/core/auth/auth_provider.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) {
  // SECURITY: Watch AuthState so this provider recalculates on login/logout
  ref.watch(authControllerProvider);
  return OrderRepository(Supabase.instance.client, ref);
}

class OrderRepository {
  final SupabaseClient _supabase;
  final Ref _ref;
  late Box<OrderModel> _orderBox;
  late Box<SyncAction> _syncBox;

  OrderRepository(this._supabase, this._ref) {
    _orderBox = Hive.box<OrderModel>('orders');
    _syncBox = Hive.box<SyncAction>('sync_queue');
  }

  Future<Either<Failure, OrderModel?>> getOrder(String id) async {
    // 1. Check local cache
    final cached = _orderBox.get(id);
    if (cached != null) return Right(cached);

    try {
      final response = await _supabase
          .from('orders')
          .select('*, customers(full_name)')
          .eq('id', id)
          .single();
      
      final order = OrderModel.fromJson(response);
      await _orderBox.put(id, order); // Update cache
      return Right(order);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<OrderModel>>> getRecentOrders({int limit = 10}) async {
    // 1. Return cached data immediately if available
    final cached = _orderBox.values
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (cached.isNotEmpty) {
      // SECURITY: Validate cache belongs to current user
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null && cached.first.userId != currentUserId) {
        // Cache poisoning detected (user logged into multiple accounts rapidly)!
        await _orderBox.clear();
        return _fetchRecentRemote(limit);
      }

      // Background fetch
      _fetchRecentRemote(limit);
      return Right(cached.take(limit).toList());
    }

    return _fetchRecentRemote(limit);
  }

  Future<Either<Failure, List<OrderModel>>> _fetchRecentRemote(int limit) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, customers(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);
      
      final orders = (response as List).map((e) => OrderModel.fromJson(e)).toList();
      
      // Update cache
      for (var order in orders) {
        await _orderBox.put(order.id, order);
      }
      
      return Right(orders);
    } catch (e, stack) {
      // If we have any cache, return it
      if (_orderBox.isNotEmpty) {
        return Right(_orderBox.values.toList());
      }
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Map<String, int>>> getStats() async {
    // Local stats for offline use
    final activeCount = _orderBox.values
        .where((j) => OrderModel.activeStatuses.contains(j.status))
        .length;
    final completedCount = _orderBox.values
        .where((j) => [OrderModel.statusCompleted, OrderModel.statusDelivered].contains(j.status))
        .length;

    return Right({
      'active': activeCount,
      'completed': completedCount,
    });
  }

  Future<Either<Failure, Unit>> createOrder(OrderModel order) async {
    try {
      final id = const Uuid().v4();
      final newOrder = order.copyWith(
        id: id,
        userId: _supabase.auth.currentUser!.id,
        createdAt: DateTime.now(),
      );

      // 1. Save to local cache
      await _orderBox.put(id, newOrder);
      
      // 2. Push to sync outbox
      await _pushSyncAction(
        SyncAction.actionCreate,
        'orders',
        newOrder.toJson(),
        id,
      );

      return const Right(unit);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<OrderModel>>> getOrdersByStatuses(List<String> statuses) async {
    // 1. Check local cache
    final cached = _orderBox.values
        .where((j) => statuses.contains(j.status))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (cached.isNotEmpty) {
      // SECURITY: Validate cache belongs to current user
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null && cached.first.userId != currentUserId) {
        await _orderBox.clear();
        return _fetchByStatusesRemote(statuses);
      }

      _fetchByStatusesRemote(statuses);
      return Right(cached);
    }

    return _fetchByStatusesRemote(statuses);
  }

  Future<Either<Failure, List<OrderModel>>> _fetchByStatusesRemote(List<String> statuses) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, customers(full_name)')
          .inFilter('status', statuses)
          .order('created_at', ascending: false);
      
      final orders = (response as List).map((e) => OrderModel.fromJson(e)).toList();
      
      for (var order in orders) {
        await _orderBox.put(order.id, order);
      }
      
      return Right(orders);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<OrderModel>>> getOrdersByCustomerId(String customerId) async {
    final cached = _orderBox.values
        .where((j) => j.customerId == customerId)
        .toList();
    
    if (cached.isNotEmpty) return Right(cached);

    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      
      final orders = (response as List).map((e) => OrderModel.fromJson(e)).toList();
      return Right(orders);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Unit>> updateOrder(OrderModel order) async {
    try {
      // 1. Save to local cache
      await _orderBox.put(order.id, order);
      
      // 2. Push to sync outbox
      await _pushSyncAction(
        SyncAction.actionUpdate,
        'orders',
        order.toJson(),
        order.id,
      );

      return const Right(unit);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<void> _pushSyncAction(String type, String endpoint, Map<String, dynamic> payload, String targetId) async {
    final action = SyncAction(
      id: const Uuid().v4(),
      actionType: type,
      endpoint: endpoint,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await _syncBox.add(action);
    
    // Trigger SyncManager
    _ref.read(syncManagerProvider).processQueue();
  }
}

@riverpod
Future<List<OrderModel>> recentOrders(Ref ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getRecentOrders();
  return result.fold(
    (failure) => throw failure,
    (orders) => orders,
  );
}

@riverpod
Future<List<OrderModel>> ordersByStatuses(Ref ref, List<String> statuses) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getOrdersByStatuses(statuses);
  return result.fold(
    (failure) => throw failure,
    (orders) => orders,
  );
}

@riverpod
Future<List<OrderModel>> ordersByCustomer(Ref ref, String customerId) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getOrdersByCustomerId(customerId);
  return result.fold(
    (failure) => throw failure,
    (orders) => orders,
  );
}
