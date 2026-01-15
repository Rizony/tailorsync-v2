import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailorsync_v2/core_v2/monetization/subscription_plan.dart';

import '../session/user_session.dart';
import '../referrals/referral.dart';
import '../monetization/earnings_ledger_entry.dart';
import '../monetization/payout_request.dart';

class SessionStorage {
  static const _sessionKey = 'user_session';
  static const _referralsKey = 'referrals';
  static const _ledgerKey = 'ledger';
  static const _payoutsKey = 'payouts';
  static const _invoicesKey = 'invoices';

  /// -------------------------------
  /// Session
  /// -------------------------------

  static Future<Map<String, dynamic>> loadMap(
  String key,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(key);
  if (raw == null) return {};
  return jsonDecode(raw) as Map<String, dynamic>;
}

static Future<void> saveMap(
  String key,
  Map<String, dynamic> value,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, jsonEncode(value));
}


  static Future<void> save(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _sessionKey,
      jsonEncode(session.toJson()),
    );
  }

  static Future<UserSession> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);

    if (raw == null) {
      return const UserSession(
        userId: 'local_user',
        plan: SubscriptionPlan.free,
        referralCount: 0,
        isDarkMode: false,
        isSeasonalThemeEnabled: false,
      );
    }

    return UserSession.fromJson(
      jsonDecode(raw),
    );
  }

  /// -------------------------------
  /// Referrals
  /// -------------------------------

  static Future<void> saveReferrals(
    List<Referral> referrals,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _referralsKey,
      jsonEncode(referrals.map((r) => r.toJson()).toList()),
    );
  }

  static Future<List<Referral>> loadReferrals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_referralsKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list.map((e) => Referral.fromJson(e)).toList();
  }

  /// -------------------------------
  /// Ledger
  /// -------------------------------

  static Future<void> saveLedger(
    List<EarningsLedgerEntry> ledger,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _ledgerKey,
      jsonEncode(ledger.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<EarningsLedgerEntry>> loadLedger() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ledgerKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => EarningsLedgerEntry.fromJson(e))
        .toList();
  }

  /// -------------------------------
  /// Payouts
  /// -------------------------------

  static Future<void> savePayoutRequests(
    List<PayoutRequest> payouts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _payoutsKey,
      jsonEncode(payouts.map((p) => p.toJson()).toList()),
    );
  }

  static Future<List<PayoutRequest>> loadPayoutRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_payoutsKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list.map((e) => PayoutRequest.fromJson(e)).toList();
  }

  /// -------------------------------
  /// ✅ INVOICES (THIS FIXES YOUR ERROR)
  /// -------------------------------

  static Future<void> saveInvoices(
    List<Map<String, dynamic>> invoices,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _invoicesKey,
      jsonEncode(invoices),
    );
  }

  static Future<List<Map<String, dynamic>>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_invoicesKey);

    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// -------------------------------
  /// Reset
  /// -------------------------------

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
