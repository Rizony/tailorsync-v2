import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_unit.dart';

import '../../../core_v2/orders/order_measurement_snapshot.dart';
import '../../../core_v2/measurements/measurement_field.dart';
import '../../../core_v2/measurements/measurement_value.dart';

class OrderMeasurementsCard extends StatelessWidget {
  final OrderMeasurementSnapshot snapshot;

  const OrderMeasurementsCard({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final measurements = snapshot.measurements;

    if (measurements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const Divider(height: 24),
            ...measurements.map((m) => _row(context, m)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.lock, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Measurements (Locked)',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, MeasurementValue m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            m.field.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${m.value.toStringAsFixed(1)} ${m.field.unit.symbol}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
