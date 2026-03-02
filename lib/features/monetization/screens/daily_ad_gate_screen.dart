import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/auth/providers/profile_provider.dart';
import '../models/subscription_tier.dart';

class DailyAdGateScreen extends ConsumerStatefulWidget {
  final Widget child;
  const DailyAdGateScreen({super.key, required this.child});

  @override
  ConsumerState<DailyAdGateScreen> createState() => _DailyAdGateScreenState();
}

class _DailyAdGateScreenState extends ConsumerState<DailyAdGateScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAdStatus();
  }

  void _checkAdStatus() {
    final box = Hive.box('settings');
    final String? lastAdDate = box.get('last_ad_date');
    final String today = DateTime.now().toIso8601String().split('T')[0];

    if (lastAdDate == today) {
      // User already watched an ad today, just show the app immediately without checking 
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _unlockApp() {
    AdService.showRewardedAd(onRewardEarned: () {
      final box = Hive.box('settings');
      final String today = DateTime.now().toIso8601String().split('T')[0];
      box.put('last_ad_date', today);
      if (mounted) {
        setState(() {}); // trigger rebuild to show child
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Check tier. If not freemium, bypass ads altogether.
    final tier = ref.watch(profileNotifierProvider).valueOrNull?.subscriptionTier ?? SubscriptionTier.freemium;
    if (tier != SubscriptionTier.freemium) {
      return widget.child;
    }

    final box = Hive.box('settings');
    final String? lastAdDate = box.get('last_ad_date');
    final String today = DateTime.now().toIso8601String().split('T')[0];
    
    // If ad is already watched, return the actual application shell
    if (lastAdDate == today) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock, size: 80, color: Color(0xFF0076B6)),
            const SizedBox(height: 24),
            const Text(
              "Ready to Work?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Watch one short video to unlock NEEDLIX for the next 24 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _unlockApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0076B6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text("Watch Ad & Unlock"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}