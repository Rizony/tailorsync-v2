import 'quotation_line_item.dart';

class QuotationCalculator {
  static double subtotal(List<QuotationLineItem> items) {
    final raw = items.fold(0.0, (sum, i) => sum + i.amount);
    return _round(raw);
  }

  static double applyDiscount({
    required double subtotal,
    required double discount,
  }) {
    final raw = subtotal - discount;
    return _round(raw.clamp(0, double.infinity));
  }

  /// Centralized rounding for all monetary values.
  static double _round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
