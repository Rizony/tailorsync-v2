import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tailorsync_v2/core/app/app_shell.dart';
import 'package:tailorsync_v2/core/auth/auth_gate.dart';
import 'package:tailorsync_v2/core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads
  MobileAds.instance.initialize();

  // Initialize Notifications
  await NotificationService.init();

  // 1. Initialize Supabase (Add your URL and Anon Key)
  await Supabase.initialize(
    url: 'https://uoesjxeleiluelbpnzie.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVvZXNqeGVsZWlsdWVsYnBuemllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDA4NjksImV4cCI6MjA4MTcxNjg2OX0.0nLT4ztjZqt5B7xaPQtO0HSeFIfjEiPy9D_kzC-jLic',
  );

  // 2. Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: TailorSyncApp(),
    ),
  );
}

class TailorSyncApp extends ConsumerWidget {
  const TailorSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TailorSync',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5D3FD3),
      ),
      // The AuthGate wraps everything
      home: const AuthGate(
        child: AppShell(), 
      ),
    );
  }
}