import '../customers/customer_id.dart';
import '../measurements/garment_type.dart';
import 'quotation_line_item.dart';
import 'quotation_status.dart';

class Quotation {
  final String id;
  final CustomerId customerId;
  final GarmentType garment;

  /// Pricing breakdown
  final List<QuotationLineItem> items;
  final double subtotal;
  final double discount;
  final double total;

  /// Lifecycle
  final QuotationStatus status;

  final DateTime createdAt;
  final DateTime? finalizedAt;

  const Quotation({
    required this.id,
    required this.customerId,
    required this.garment,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.createdAt,
    this.finalizedAt,
  })  : assert(items.length > 0, 'Quotation must contain at least one line item'),
        assert(total >= 0, 'Quotation total cannot be negative');

  /// Canonical price accessor
  double get totalPrice => total;

  /// Whether this quotation can produce an Order
  bool get isFinalized => status == QuotationStatus.finalized;

  /// Controlled mutation
  Quotation copyWith({
    List<QuotationLineItem>? items,
    double? subtotal,
    double? discount,
    double? total,
    QuotationStatus? status,
    DateTime? finalizedAt,
  }) {
    return Quotation(
      id: id,
      customerId: customerId,
      garment: garment,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
    );
  }
}
