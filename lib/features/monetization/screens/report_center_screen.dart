import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/dashboard/providers/dashboard_provider.dart';
import 'package:needlix/features/dashboard/models/dashboard_data.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/utils/business_advisor.dart';

class ReportCenterScreen extends ConsumerWidget {
  const ReportCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardStatsProvider);
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final currencySymbol = profile?.currencySymbol ?? '₦';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: dashboardAsync.when(
        data: (data) => _buildBody(context, data, currencySymbol),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardData data, String currency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, data, currency),
          const SizedBox(height: 24),
          _buildSectionHeader('Business Performance'),
          const SizedBox(height: 16),
          _buildPerformanceGrid(context, data, currency),
          const SizedBox(height: 24),
          _buildSectionHeader('TailorSync Insights (AI Advise)'),
          const SizedBox(height: 16),
          _buildAdviceList(context, data),
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Community Inquiries'),
          const SizedBox(height: 16),
          _buildRecentTransactions(context, data.recentOrders, currency),
        ],
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
          const Text(
            'Total Business Revenue',
            style: TextStyle(color: Colors.white70, fontSize: 16),
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
              _buildSummaryMiniStat('Orders', '${data.completedOrders}', Icons.shopping_bag),
              const SizedBox(width: 24),
              _buildSummaryMiniStat('Weekly', '$currency${data.weeklyRevenue.toStringAsFixed(0)}', Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
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
        _buildMetricCard(context, 'Avg Order', '$currency${(data.lifetimeRevenue / (data.completedOrders > 0 ? data.completedOrders : 1)).toStringAsFixed(0)}', Icons.analytics, Colors.orange),
        _buildMetricCard(context, 'Inquiries', '${data.inquiryCount}', Icons.forum_outlined, Colors.purple),
        _buildMetricCard(context, 'Completed', '${data.completedOrders}', Icons.task_alt, Colors.green),
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
      itemCount: earningOrders.length,
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
