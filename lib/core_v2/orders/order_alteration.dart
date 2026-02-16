import 'altered_measurement.dart';

class OrderAlteration {
  final String id;
  final String reason; // e.g. "First fitting"
  final List<AlteredMeasurement> changes;
  final DateTime createdAt;

  const OrderAlteration({
    required this.id,
    required this.reason,
    required this.changes,
    required this.createdAt,
  });
}
