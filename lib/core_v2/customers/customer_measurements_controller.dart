import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_id.dart';
import 'customer_measurement_book.dart';
import 'measurement_profile_factory.dart';
import '../measurements/garment_type.dart';
import 'measurement_profile.dart';

final customerMeasurementsProvider =
    StateNotifierProvider<CustomerMeasurementsController,
        Map<CustomerId, CustomerMeasurementBook>>(
  (ref) => CustomerMeasurementsController(),
);

class CustomerMeasurementsController
    extends StateNotifier<Map<CustomerId, CustomerMeasurementBook>> {
  CustomerMeasurementsController() : super({});

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

    final profile =
        MeasurementProfileFactory.create(garment: garment);

    state = {
      ...state,
      customerId: book.addProfile(profile),
    };
  }

  void updateProfile(
    CustomerId customerId,
    MeasurementProfile updated,
  ) {
    final book = bookFor(customerId);

    state = {
      ...state,
      customerId: book.replaceProfile(updated),
    };
  }
}
