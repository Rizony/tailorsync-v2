import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:needlix/features/orders/models/order_model.dart';

part 'dashboard_data.freezed.dart';

@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required int activeOrders,
    required int completedOrders,
    required int totalCustomers,
    required double weeklyRevenue,
    required double lifetimeRevenue,
    required int newCustomers,
    required int inquiryCount,
    required List<OrderModel> recentOrders,
    required List<OrderModel> urgentOrders,
    required String userName,
  }) = _DashboardData;
}
