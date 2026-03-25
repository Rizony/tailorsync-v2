class CurrencyFormatter {
  static const String defaultSymbol = '₦';

  static String format(double amount, {String? customSymbol}) {
    final symbol = customSymbol ?? defaultSymbol;
    // Remove decimal if it's .00 for cleaner UI, or just keep it simple.
    // Keeping it simple as per original implementation:
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String getSymbol(String? customSymbol) {
    return customSymbol ?? defaultSymbol;
  }
}
