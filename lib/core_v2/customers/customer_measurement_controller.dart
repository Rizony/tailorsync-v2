import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_id.dart';
import 'customer_measurement_book.dart';
import '../measurements/measurement_profile_factory.dart';
import '../measurements/garment_type.dart';
import '../measurements/measurement_profile.dart';

final customerMeasurementProvider = StateNotifierProvider<
    CustomerMeasurementController,
    Map<CustomerId, CustomerMeasurementBook>>(
  (ref) => CustomerMeasurementController(),
);

class CustomerMeasurementController
    extends StateNotifier<Map<CustomerId, CustomerMeasurementBook>> {
  CustomerMeasurementController() : super({});

  CustomerMeasurementBook bookFor(CustomerId customerId) {
    return state[customerId] ??
        CustomerMeasurementBook(
          customerId: customerId,
          profiles: const [],
        );
  }

  void addProfile({
    required CustomerId customerId,
    required GarmentType garment,
  }) {
    final book = bookFor(customerId);

    final profile = MeasurementProfileFactory.create(
      garment: garment,
    );

    state = {
      ...state,
      customerId: book.addProfile(profile),
    };
  }

  void updateProfile({
    required CustomerId customerId,
    required MeasurementProfile updated,
  }) {
    final book = bookFor(customerId);

    state = {
      ...state,
      customerId: book.replaceProfile(updated),
    };
  }
}
