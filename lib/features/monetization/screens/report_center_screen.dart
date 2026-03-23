import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/dashboard/providers/dashboard_provider.dart';
import 'package:needlix/features/dashboard/models/dashboard_data.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/orders/repositories/order_repository.dart';
import 'package:needlix/features/customers/repositories/customer_repository.dart';
import 'package:needlix/features/customers/models/customer.dart';
import 'package:needlix/features/marketplace/repositories/marketplace_repository.dart';
import 'package:needlix/features/marketplace/models/marketplace_request.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/utils/business_advisor.dart';

enum ReportFilter { sevenDays, thirtyDays, thisMonth, allTime }

class ReportCenterScreen extends ConsumerStatefulWidget {
  const ReportCenterScreen({super.key});

  @override
  ConsumerState<ReportCenterScreen> createState() => _ReportCenterScreenState();
}

class _ReportCenterScreenState extends ConsumerState<ReportCenterScreen> {
  ReportFilter _selectedFilter = ReportFilter.allTime;

  @override
  Widget build(BuildContext context) {
    final allOrdersAsync = ref.watch(allOrdersProvider);
    final customersAsync = ref.watch(customerRepositoryProvider);
    final inquiriesAsync = ref.watch(marketplaceRequestsProvider);
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final currencySymbol = profile?.currencySymbol ?? '₦';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: allOrdersAsync.when(
        data: (orders) {
          return customersAsync.when(
            data: (customers) {
              return inquiriesAsync.when(
                data: (inquiries) {
                  final filteredData = _calculateFilteredData(
                    orders, 
                    customers.cast<Customer>(), 
                    inquiries, 
                    profile?.fullName ?? 'Tailor'
                  );
                  return _buildBody(context, filteredData, currencySymbol);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error inquiries: $err')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error customers: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error orders: $err')),
      ),
    );
  }

  DashboardData _calculateFilteredData(
    List<OrderModel> allOrders, 
    List<Customer> allCustomers, 
    List<MarketplaceRequest> allInquiries,
    String userName
  ) {
    final now = DateTime.now();
    DateTime? startDate;

    switch (_selectedFilter) {
      case ReportFilter.sevenDays:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ReportFilter.thirtyDays:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case ReportFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case ReportFilter.allTime:
        startDate = null;
        break;
    }

    double revenue = 0;
    int newCustCount = 0;
    int inquiryCount = 0;

    // Filter Revenue
    for (var order in allOrders) {
      for (var payment in order.payments) {
        if (startDate == null || payment.date.isAfter(startDate)) {
          revenue += payment.amount;
        }
      }
    }

    // Filter Customers
    newCustCount = allCustomers.where((c) {
      if (c.createdAt == null) return false;
      return startDate == null || c.createdAt!.isAfter(startDate);
    }).length;

    // Filter Inquiries
    inquiryCount = allInquiries.where((i) {
      return startDate == null || i.createdAt.isAfter(startDate);
    }).length;

    final completedOrders = allOrders.where((o) => 
      (startDate == null || o.createdAt.isAfter(startDate)) && 
      [OrderModel.statusCompleted, OrderModel.statusDelivered].contains(o.status)
    ).length;

    final activeOrders = allOrders.where((o) => 
      (startDate == null || o.createdAt.isAfter(startDate)) && 
      OrderModel.activeStatuses.contains(o.status)
    ).length;

    return DashboardData(
      activeOrders: activeOrders,
      completedOrders: completedOrders,
      totalCustomers: allCustomers.length,
      weeklyRevenue: revenue, // We reuse this field for "Filtered Revenue"
      lifetimeRevenue: revenue, // We reuse this for display in the main card
      newCustomers: newCustCount,
      inquiryCount: inquiryCount,
      recentOrders: allOrders.take(10).toList(),
      urgentOrders: [], // Not needed for reports
      userName: userName,
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Time Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFilterOption(ReportFilter.sevenDays, 'Last 7 Days'),
              _buildFilterOption(ReportFilter.thirtyDays, 'Last 30 Days'),
              _buildFilterOption(ReportFilter.thisMonth, 'This Month'),
              _buildFilterOption(ReportFilter.allTime, 'All Time'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(ReportFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ListTile(
      title: Text(label, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      )),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        setState(() => _selectedFilter = filter);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody(BuildContext context, DashboardData data, String currency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, data, currency),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 24),
          _buildSectionHeader('Performance Details'),
          const SizedBox(height: 16),
          _buildPerformanceGrid(context, data, currency),
          const SizedBox(height: 24),
          _buildSectionHeader('TailorSync Insights (AI Advise)'),
          const SizedBox(height: 16),
          _buildAdviceList(context, data),
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Orders/Inquiries'),
          const SizedBox(height: 16),
          _buildRecentTransactions(context, data.recentOrders, currency),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMiniChip(ReportFilter.sevenDays, '7D'),
          const SizedBox(width: 8),
          _buildMiniChip(ReportFilter.thirtyDays, '30D'),
          const SizedBox(width: 8),
          _buildMiniChip(ReportFilter.thisMonth, '1M'),
          const SizedBox(width: 8),
          _buildMiniChip(ReportFilter.allTime, 'All'),
        ],
      ),
    );
  }

  Widget _buildMiniChip(ReportFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = filter);
      },
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryCard(BuildContext context, DashboardData data, String currency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedFilter == ReportFilter.allTime ? 'Total Business Revenue' : '${_getFilterLabel()} Revenue',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '$currency${NumberFormat('#,###').format(data.lifetimeRevenue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryMiniStat('Completed', '${data.completedOrders}', Icons.shopping_bag),
              const SizedBox(width: 24),
              _buildSummaryMiniStat('Avg Order', '$currency${(data.lifetimeRevenue / (data.completedOrders > 0 ? data.completedOrders : 1)).toStringAsFixed(0)}', Icons.analytics),
            ],
          ),
        ],
      ),
    );
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case ReportFilter.sevenDays: return 'Last 7 Days';
      case ReportFilter.thirtyDays: return 'Last 30 Days';
      case ReportFilter.thisMonth: return 'Monthly';
      case ReportFilter.allTime: return 'All Time';
    }
  }

  Widget _buildSummaryMiniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid(BuildContext context, DashboardData data, String currency) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(context, 'New Clients', '${data.newCustomers}', Icons.person_add, Colors.blue),
        _buildMetricCard(context, 'Inquiries', '${data.inquiryCount}', Icons.forum_outlined, Colors.purple),
        _buildMetricCard(context, 'Active Deals', '${data.activeOrders}', Icons.trending_up, Colors.orange),
        _buildMetricCard(context, 'Success Rate', '${(data.completedOrders / (data.completedOrders + data.activeOrders > 0 ? data.completedOrders + data.activeOrders : 1) * 100).toStringAsFixed(0)}%', Icons.emoji_events_outlined, Colors.green),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceList(BuildContext context, DashboardData data) {
    final adviceList = BusinessAdvisor.getAdvice(data);
    
    return Column(
      children: adviceList.map((advice) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: advice.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: advice.color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(advice.icon, color: advice.color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advice.title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: advice.color.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advice.message,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<OrderModel> orders, String currency) {
    final earningOrders = orders.where((o) => o.payments.isNotEmpty).toList();
    if (earningOrders.isEmpty) {
      return const Center(child: Text('No recent inquiries to show'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: earningOrders.length > 5 ? 5 : earningOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = earningOrders[index];
        final totalPaid = order.payments.fold(0.0, (sum, p) => sum + p.amount);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_chart, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat.yMMMd().format(order.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Text('+$currency${totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
