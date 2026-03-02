import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tailorsync_v2/core/app/app_shell.dart';
import 'package:tailorsync_v2/core/auth/auth_gate.dart';
import 'package:tailorsync_v2/core/notifications/notification_service.dart';
import 'package:tailorsync_v2/core/theme/app_theme.dart';
import 'package:tailorsync_v2/core/theme/theme_provider.dart';

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
      child: NeedlixApp(),
    ),
  );
}

class NeedlixApp extends ConsumerWidget {
  const NeedlixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the theme mode provider
    final currentThemeMode = ref.watch(themeModeProvider);
    // 2. Watch the tier color provider
    final currentThemeColor = ref.watch(themeColorProvider);

    return MaterialApp(
      title: 'NEEDLIX',
      theme: AppTheme.lightTheme(customPrimaryColor: currentThemeColor),
      darkTheme: AppTheme.darkTheme(customPrimaryColor: currentThemeColor),
      themeMode: currentThemeMode, // Apply it here
      // The AuthGate wraps everything
      home: const AuthGate(
        child: AppShell(), 
      ),
    );
  }
}