import 'package:shared_preferences/shared_preferences.dart';
import 'terms_content.dart';

class TermsService {
  static String _key(String userId) => 'terms_v${kTermsVersion}_accepted_$userId';

  /// Returns true if the user has accepted the current version of the T&Cs.
  static Future<bool> hasAcceptedTerms(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  /// Saves acceptance for the current T&C version against this user.
  static Future<void> markTermsAccepted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}
