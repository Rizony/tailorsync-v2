import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_field.dart';
import '../../../core_v2/orders/order_alteration.dart';

class OrderAlterationsCard extends StatelessWidget {
  final List<OrderAlteration> alterations;

  const OrderAlterationsCard({
    super.key,
    required this.alterations,
  });

  @override
  Widget build(BuildContext context) {
    if (alterations.isEmpty) {
      return const Text(
        'No alterations recorded.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alterations.map(_alteration).toList(),
    );
  }

  Widget _alteration(OrderAlteration alteration) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alteration.reason,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...alteration.changes.map(
              (c) => Text(
                '${c.field.label}: ${c.originalValue} → ${c.newValue}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
