import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_unit.dart';

import '../../core_v2/customers/customer_id.dart';
import '../../core_v2/customers/customer_measurement_controller.dart';
import '../../core_v2/customers/measurement_profile.dart';
import '../../core_v2/measurements/measurement_value.dart';

class MeasurementEditScreen extends ConsumerWidget {
  final CustomerId customerId;
  final MeasurementProfile profile;

  const MeasurementEditScreen({
    super.key,
    required this.customerId,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${profile.garment.name.toUpperCase()} Measurements',
        ),
      ),
      body: ListView(
        children: profile.measurements.map((m) {
          return ListTile(
            title: Text(m.field.name),
            subtitle: Text(
              '${m.value} ${m.unit.symbol}',
            ),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final updated = await _editValue(context, m);
              if (updated != null) {
                ref
                    .read(customerMeasurementProvider.notifier)
                    .updateProfile(
                      customerId: customerId,
                      updated:
                          profile.updateMeasurement(updated),
                    );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Future<MeasurementValue?> _editValue(
    BuildContext context,
    MeasurementValue value,
  ) async {
    final controller = TextEditingController(
      text: value.value.toString(),
    );

    return showDialog<MeasurementValue>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(value.field.name),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed =
                  double.tryParse(controller.text);
              if (parsed != null) {
                Navigator.pop(
                  context,
                  value.copyWith(value: parsed),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
