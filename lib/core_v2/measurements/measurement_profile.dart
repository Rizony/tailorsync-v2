import 'garment_type.dart';
import 'measurement_value.dart';

class MeasurementProfile {
  final String id;
  final GarmentType garment;
  final List<MeasurementValue> measurements;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeasurementProfile({
    required this.id,
    required this.garment,
    required this.measurements,
    required this.createdAt,
    required this.updatedAt,
  });

  MeasurementProfile updateMeasurement(
    MeasurementValue updated,
  ) {
    return MeasurementProfile(
      id: id,
      garment: garment,
      measurements: measurements.map((m) {
        return m.field == updated.field ? updated : m;
      }).toList(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
