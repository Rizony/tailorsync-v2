import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:needlix/core/auth/models/app_user.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/features/customers/repositories/customer_repository.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/orders/repositories/order_repository.dart';
import '../models/dashboard_data.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> dashboardStats(Ref ref) async {
  // Fetch data in parallel
  final ordersFuture = ref.watch(recentOrdersProvider.future);
  final customersFuture = ref.watch(customerRepositoryProvider.future);
  final profileFuture = ref.watch(profileNotifierProvider.future);

  final results = await Future.wait([
    ordersFuture,
    customersFuture,
    profileFuture,
  ]);
  
  final orders = results[0] as List; // List<OrderModel>
  final customers = results[1] as List; // List<Customer>
  final profile = results[2] as AppUser?;

  // Calculate stats
  final activeOrders = orders.where((order) => order.status == 'pending').length;
  final completedOrders = orders.where((order) => order.status == 'completed').length;
  final totalRevenue = orders
      .where((order) => order.status == 'completed') 
      .fold(0.0, (sum, order) => sum + (order.price));

  // Calculate urgent orders (due in less than 48 hours, active status check)
  final now = DateTime.now();
  final fortyEightHoursFromNow = now.add(const Duration(hours: 48));

  final urgentOrders = (orders as List<OrderModel>).where((order) {
    if (order.status == OrderModel.statusCompleted || order.status == OrderModel.statusDelivered || order.status == OrderModel.statusCanceled) {
      return false;
    }
    return order.dueDate.isBefore(fortyEightHoursFromNow) && order.dueDate.isAfter(now.subtract(const Duration(days: 30)));
  }).toList();
  
  // Sort urgent orders by due date
  urgentOrders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

  // Get recent 5
  final recentOrders = orders.take(5).toList();

  return DashboardData(
    activeOrders: activeOrders,
    completedOrders: completedOrders,
    totalCustomers: customers.length,
    totalRevenue: totalRevenue,
    recentOrders: List.from(recentOrders), 
    urgentOrders: List.from(urgentOrders),
    userName: profile?.fullName ?? 'Tailor',
  );
}
