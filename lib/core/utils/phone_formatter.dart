class PhoneFormatter {
  /// Formats a local phone number into an international format required by external APIs (like WhatsApp).
  /// Falls back to a provided default country code if the number starts with '0'.
  static String formatForExternalApi(String rawPhone, {String defaultCountryCode = '234'}) {
    if (rawPhone.isEmpty) return rawPhone;
    
    String phone = rawPhone.replaceAll(RegExp(r'\D'), '');
    
    if (phone.startsWith('0')) {
      return '$defaultCountryCode${phone.substring(1)}';
    }
    
    return phone;
  }
}
