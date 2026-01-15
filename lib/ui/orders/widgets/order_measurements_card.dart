import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_field.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_unit.dart';

import '../../../core_v2/orders/order_measurement_snapshot.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 12),
            ...measurements.map(_row),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.lock, size: 18),
        const SizedBox(width: 8),
        Text(
          'Measurements (Locked)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _row(MeasurementValue m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(m.field.label),
          Text(
            '${m.value} ${m.unit.symbol}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
