import 'package:flutter_test/flutter_test.dart';
import 'package:needlix/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('format properly uses default symbol when none provided', () {
      expect(CurrencyFormatter.format(1500), '₦1500.00');
    });

    test('format properly uses custom symbol', () {
      expect(CurrencyFormatter.format(1500, customSymbol: '\$'), '\$1500.00');
    });

    test('getSymbol returns default when null', () {
      expect(CurrencyFormatter.getSymbol(null), '₦');
    });

    test('getSymbol returns custom when provided', () {
      expect(CurrencyFormatter.getSymbol('€'), '€');
    });
  });
}
