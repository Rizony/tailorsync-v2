import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_v2/customers/customer_id.dart';
import '../../core_v2/customers/customer_measurement_controller.dart';
import '../../core_v2/measurements/garment_type.dart';
import 'measurement_edit_screen.dart';

class CustomerMeasurementsScreen extends ConsumerWidget {
  final CustomerId customerId;

  const CustomerMeasurementsScreen({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref
        .watch(customerMeasurementProvider.notifier)
        .bookFor(customerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
      ),
      body: ListView(
        children: [
          for (final profile in book.profiles)
            ListTile(
              title: Text(profile.garment.name.toUpperCase()),
              subtitle: Text(
                '${profile.measurements.length} measurements',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeasurementEditScreen(
                      customerId: customerId,
                      profile: profile,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addProfile(context, ref),
      ),
    );
  }

  void _addProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: GarmentType.values.map((garment) {
            return ListTile(
              title: Text(garment.name.toUpperCase()),
              onTap: () {
                ref
                    .read(customerMeasurementProvider.notifier)
                    .addProfile(
                      customerId: customerId,
                      garment: garment,
                    );

                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
