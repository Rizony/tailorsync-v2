import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/app/app_shell.dart';

class DailyAdGateScreen extends StatefulWidget {
  const DailyAdGateScreen({super.key});

  @override
  State<DailyAdGateScreen> createState() => _DailyAdGateScreenState();
}

class _DailyAdGateScreenState extends State<DailyAdGateScreen> {
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
      // User already watched an ad today, go straight to the app
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigateToApp();
      });
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _unlockApp() {
    AdService.showRewardedAd(onRewardEarned: () {
      final box = Hive.box('settings');
      final String today = DateTime.now().toIso8601String().split('T')[0];
      box.put('last_ad_date', today);
      _navigateToApp();
    });
  }

  void _navigateToApp() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock, size: 80, color: Color(0xFF5D3FD3)),
            const SizedBox(height: 24),
            const Text(
              "Ready to Work?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Watch one short video to unlock TailorSync for the next 24 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _unlockApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3FD3),
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