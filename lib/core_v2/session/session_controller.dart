import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../monetization/earnings_ledger_entry.dart';
import '../monetization/earnings_ledger_service.dart';
import '../monetization/payout_request.dart';
import '../monetization/subscription_plan.dart';
import '../persistence/session_storage.dart';
import '../referrals/referral.dart';
import '../referrals/referral_engine.dart';
import '../referrals/referral_limits.dart';
import 'user_session.dart';

/// ------------------------------------------------------------
/// Providers
/// ------------------------------------------------------------

final sessionBootstrapProvider =
    FutureProvider<SessionController>((ref) async {
  return SessionController.bootstrap();
});

final sessionControllerProvider =
    ChangeNotifierProvider<SessionController>((ref) {
  throw UnimplementedError(
    'SessionController must be provided from sessionBootstrapProvider',
  );
});

/// ------------------------------------------------------------
/// Controller
/// ------------------------------------------------------------

class SessionController extends ChangeNotifier {
  UserSession _session;

  /// Internal state (never expose mutable lists)
  final List<Referral> _referrals = [];
  final List<EarningsLedgerEntry> _ledger = [];
  final List<PayoutRequest> _payoutRequests = [];

  SessionController(this._session);

  /// ------------------------------------------------------------
  /// Bootstrap (used once at app start)
  /// ------------------------------------------------------------

  static Future<SessionController> bootstrap() async {
    final session = await SessionStorage.load();
    final controller = SessionController(session);

    controller._referrals.addAll(
      await SessionStorage.loadReferrals(),
    );

    controller._ledger.addAll(
      await SessionStorage.loadLedger(),
    );

    controller._payoutRequests.addAll(
      await SessionStorage.loadPayoutRequests(),
    );

    return controller;
  }

  /// ------------------------------------------------------------
  /// Public getters (safe)
  /// ------------------------------------------------------------

  UserSession get session => _session;

  List<Referral> get referrals =>
      List.unmodifiable(_referrals);

  List<EarningsLedgerEntry> get ledger =>
      List.unmodifiable(_ledger);

  List<PayoutRequest> get payoutRequests =>
      List.unmodifiable(_payoutRequests);

  /// ------------------------------------------------------------
  /// Earnings & Ledger
  /// ------------------------------------------------------------

  void rebuildLedger() {
    final now = DateTime.now();

    final months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - i),
    ).reversed.toList();

    _ledger
      ..clear()
      ..addAll(
        EarningsLedgerService.generateLedger(
          months: months,
          referrals: _referrals,
          referrerPlan: _session.plan,
        ),
      );

    SessionStorage.saveLedger(_ledger);
    notifyListeners();
  }

  double get monthlyReferralEarnings {
    return ReferralEngine.totalMonthlyEarnings(
      referrerPlan: _session.plan,
      referrals: _referrals,
      priceResolver: (plan) => plan.monthlyPriceUsd,
    );
  }

  double earningForReferral(Referral referral) {
    if (!_session.plan.canEarnReferrals) return 0;
    if (!referral.isActive) return 0;
    if (!referral.plan.isPaid) return 0;

    final rate = referral.isFirstMonth ? 0.40 : 0.10;
    return referral.plan.monthlyPriceUsd * rate;
  }

  bool get canRequestPayout {
    return _ledger.any((e) => e.isPayable && !e.isSettled);
  }

  double get payableBalance {
    return _ledger
        .where((e) => e.isPayable && !e.isSettled)
        .fold(0.0, (sum, e) => sum + e.amountUsd);
  }

  void requestPayout() {
    if (!canRequestPayout) return;

    _payoutRequests.add(
      PayoutRequest(
        requestedAt: DateTime.now(),
        amountUsd: payableBalance,
      ),
    );

    SessionStorage.savePayoutRequests(_payoutRequests);
    notifyListeners();
  }

  void approveLatestPayout() {
    final index =
        _payoutRequests.indexWhere((p) => !p.isPaid);
    if (index == -1) return;

    final now = DateTime.now();

    _payoutRequests[index] =
        _payoutRequests[index].markPaid(now);

    for (int i = 0; i < _ledger.length; i++) {
      if (_ledger[i].isPayable && !_ledger[i].isSettled) {
        _ledger[i] = _ledger[i].settle(now);
      }
    }

    SessionStorage.saveLedger(_ledger);
    SessionStorage.savePayoutRequests(_payoutRequests);
    notifyListeners();
  }

  /// ------------------------------------------------------------
  /// Referrals
  /// ------------------------------------------------------------

  void addReferral({
    required String userId,
    required SubscriptionPlan plan,
  }) {
    final activeCount =
        _referrals.where((r) => r.isActive).length;

    if (activeCount >= maxActiveReferrals) return;

    _referrals.add(
      Referral(
        referredUserId: userId,
        plan: plan,
        subscribedAt: DateTime.now(),
      ),
    );

    _commit(
      _session.copyWith(
        referralCount:
            _referrals.where((r) => r.isActive).length,
      ),
    );

    SessionStorage.saveReferrals(_referrals);
  }

  void cancelLastReferral() {
    if (_referrals.isEmpty) return;

    final last = _referrals.removeLast();
    _referrals.add(last.cancel());

    _commit(
      _session.copyWith(
        referralCount:
            _referrals.where((r) => r.isActive).length,
      ),
    );

    SessionStorage.saveReferrals(_referrals);
  }

  /// ------------------------------------------------------------
  /// Subscription
  /// ------------------------------------------------------------

  void updatePlan(SubscriptionPlan newPlan) {
    _commit(
      _session.copyWith(plan: newPlan),
    );
  }

  /// ------------------------------------------------------------
  /// UI Preferences
  /// ------------------------------------------------------------

  void toggleDarkMode(bool enabled) {
    _commit(
      _session.copyWith(isDarkMode: enabled),
    );
  }

  void toggleSeasonalTheme(bool enabled) {
    _commit(
      _session.copyWith(
        isSeasonalThemeEnabled: enabled,
      ),
    );
  }

  /// ------------------------------------------------------------
  /// Reset / Persistence
  /// ------------------------------------------------------------

  Future<void> resetSession() async {
    await SessionStorage.clear();

    _referrals.clear();
    _ledger.clear();
    _payoutRequests.clear();

    _commit(
      const UserSession(
        userId: 'local_user',
        plan: SubscriptionPlan.free,
        referralCount: 0,
        isDarkMode: false,
        isSeasonalThemeEnabled: false,
      ),
    );
  }

  void _commit(UserSession updated) {
    _session = updated;
    SessionStorage.save(updated);
    notifyListeners();
  }
}
