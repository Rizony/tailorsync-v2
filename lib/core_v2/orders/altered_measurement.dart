import '../measurements/measurement_field.dart';

class AlteredMeasurement {
  final MeasurementField field;
  final double originalValue;
  final double newValue;
  final DateTime changedAt;

  const AlteredMeasurement({
    required this.field,
    required this.originalValue,
    required this.newValue,
    required this.changedAt,
  });
}
