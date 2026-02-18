import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/auth/screens/login_screen.dart';
import 'package:tailorsync_v2/features/monetization/screens/daily_ad_gate_screen.dart';
import 'auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      // Inside lib/core/auth/auth_gate.dart
data: (state) {
  if (state.session != null) {
    // Instead of going straight to AppShell, go to DailyAdGateScreen
    return const DailyAdGateScreen(); 
  }
  return const LoginScreen();
},
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}