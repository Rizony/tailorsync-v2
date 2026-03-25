import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/core/auth/models/app_user.dart';
import 'package:needlix/core/utils/currency_formatter.dart';

class OrderPaymentHistory extends StatelessWidget {
  final OrderModel order;
  final AppUser? profile;

  const OrderPaymentHistory({
    super.key,
    required this.order,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (order.payments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: order.payments.reversed.map((p) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              title: Text(CurrencyFormatter.format(p.amount, customSymbol: profile?.currencySymbol)),
              subtitle: Text(p.note ?? 'Payment recorded'),
              trailing: Text(DateFormat.MMMd().format(p.date), style: const TextStyle(fontSize: 11)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
