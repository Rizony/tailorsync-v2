import '../measurements/measurement_profile.dart';
import 'order_measurement_snapshot.dart';

class OrderMeasurementSnapshotFactory {
  static OrderMeasurementSnapshot fromProfile(
    MeasurementProfile profile,
  ) {
    return OrderMeasurementSnapshot(
      garment: profile.garment,
      measurements: profile.measurements
          .map((m) => m.copy()) // defensive copy
          .toList(),
      capturedAt: DateTime.now(),
    );
  }
}
