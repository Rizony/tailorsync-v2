import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/notifications/notification_service.dart';
import 'package:tailorsync_v2/features/marketplace/repositories/marketplace_repository.dart';

final marketplaceNotificationServiceProvider = Provider<MarketplaceNotificationService>((ref) {
  return MarketplaceNotificationService(ref);
});

class MarketplaceNotificationService {
  final Ref _ref;
  int _lastCount = 0;

  MarketplaceNotificationService(this._ref) {
    _init();
  }

  void _init() {
    // Listen to the pending count and trigger notifications
    _ref.listen<int>(pendingMarketplaceRequestsCountProvider, (previous, next) {
      _handleCountChange(next);
    });
  }

  void _handleCountChange(int count) {
    // 1. Update App Icon Badge
    _updateBadge(count);

    // 2. Trigger System Notification if count increased
    if (count > _lastCount) {
      _showSystemNotification(count - _lastCount);
    }
    
    _lastCount = count;
  }

  Future<void> _updateBadge(int count) async {
    try {
      if (await FlutterAppBadger.isAppBadgeSupported()) {
        if (count > 0) {
          FlutterAppBadger.updateBadgeCount(count);
        } else {
          FlutterAppBadger.removeBadge();
        }
      }
    } catch (e) {
      // Ignore badger errors in dev
    }
  }

  void _showSystemNotification(int newItems) {
    NotificationService.showNotification(
      id: 999,
      title: 'New Marketplace Inquiry! 🧵',
      body: newItems == 1 
          ? 'A new potential customer is reaching out from the website.' 
          : 'You have $newItems new order inquiries from the website.',
    );
  }
}
