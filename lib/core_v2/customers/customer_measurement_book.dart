import 'customer_id.dart';
import 'measurement_profile.dart';
import '../measurements/garment_type.dart';

class CustomerMeasurementBook {
  final CustomerId customerId;
  final List<MeasurementProfile> profiles;

  const CustomerMeasurementBook({
    required this.customerId,
    required this.profiles,
  });

  MeasurementProfile? profileFor(GarmentType garment) {
    try {
      return profiles.firstWhere(
        (p) => p.garment == garment,
      );
    } catch (_) {
      return null;
    }
  }

  CustomerMeasurementBook addProfile(
    MeasurementProfile profile,
  ) {
    return CustomerMeasurementBook(
      customerId: customerId,
      profiles: [...profiles, profile],
    );
  }

  CustomerMeasurementBook replaceProfile(
    MeasurementProfile updated,
  ) {
    return CustomerMeasurementBook(
      customerId: customerId,
      profiles: profiles.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList(),
    );
  }
}
