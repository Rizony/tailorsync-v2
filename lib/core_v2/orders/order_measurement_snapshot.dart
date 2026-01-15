import '../measurements/garment_type.dart';
import '../measurements/measurement_value.dart';

class OrderMeasurementSnapshot {
  final GarmentType garment;
  final List<MeasurementValue> measurements;
  final DateTime capturedAt;

  const OrderMeasurementSnapshot({
    required this.garment,
    required this.measurements,
    required this.capturedAt,
  });
}
