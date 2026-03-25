import 'package:flutter_test/flutter_test.dart';
import 'package:needlix/core/utils/phone_formatter.dart';

void main() {
  group('PhoneFormatter', () {
    test('formatForExternalApi replaces local 0 with default country code', () {
      expect(PhoneFormatter.formatForExternalApi('08012345678'), '2348012345678');
    });

    test('formatForExternalApi strips non-digit characters', () {
      expect(PhoneFormatter.formatForExternalApi('080-1234-5678'), '2348012345678');
      expect(PhoneFormatter.formatForExternalApi('(080) 1234 5678'), '2348012345678');
    });

    test('formatForExternalApi leaves numbers starting with country code unchanged', () {
      expect(PhoneFormatter.formatForExternalApi('2348012345678'), '2348012345678');
      expect(PhoneFormatter.formatForExternalApi('+2348012345678'), '2348012345678');
    });
    
    test('formatForExternalApi handles empty string gracefully', () {
      expect(PhoneFormatter.formatForExternalApi(''), '');
    });
  });
}
