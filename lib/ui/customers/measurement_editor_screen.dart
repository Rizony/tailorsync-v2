import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_field.dart';
import 'package:tailorsync_v2/core_v2/measurements/measurement_unit.dart';

import '../../core_v2/customers/customer_id.dart';
import '../../core_v2/customers/customer_measurements_controller.dart';
import '../../core_v2/measurements/measurement_profile.dart';
import '../../core_v2/measurements/measurement_value.dart';
import '../../core_v2/measurements/garment_type.dart';

class MeasurementEditorScreen extends ConsumerWidget {
  final CustomerId customerId;
  final GarmentType garment;
  final MeasurementProfile? existing;

  const MeasurementEditorScreen({
    super.key,
    required this.customerId,
    required this.garment,
    required this.existing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = existing;

    return Scaffold(
      appBar: AppBar(
        title: Text('${garment.name} Measurements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: profile == null
            ? [
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(customerMeasurementsProvider.notifier)
                        .addProfile(
                          customerId: customerId,
                          garment: garment,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Create Measurements'),
                ),
              ]
            : profile.measurements
                .map(
                  (m) => _MeasurementField(
                    value: m,
                    onChanged: (updated) {
                      ref
                          .read(
                              customerMeasurementsProvider.notifier)
                          .updateProfile(
                            customerId,
                            profile.updateMeasurement(updated),
                          );
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  final MeasurementValue value;
  final ValueChanged<MeasurementValue> onChanged;

  const _MeasurementField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: value.value.toString(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          label: Text(value.field.label),
          suffixText: value.unit.symbol,
        ),
        onSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) { 
            onChanged(value.copyWith(value: parsed));
          }
        },
      ),
    );
  }
}
