import 'package:tailorsync_v2/core_v2/measurements/garment_type.dart';
import 'package:tailorsync_v2/core_v2/orders/order_measurement_snapshot.dart';

class OrderItem {
  final String description;
  final GarmentType garment;
  final int quantity;
  /// 🔒 Locked measurements
  final OrderMeasurementSnapshot measurements;

  const OrderItem({
    required this.description,
    required this.garment,
    required this.quantity,
    required this.measurements,
  });
}
