import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/auth/screens/login_screen.dart';
import 'package:tailorsync_v2/core/terms/terms_gate.dart';
import 'package:tailorsync_v2/features/monetization/screens/daily_ad_gate_screen.dart';
import 'auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) {
          // TermsGate blocks the app until T&Cs are accepted,
          // then DailyAdGateScreen handles the ad logic.
          return TermsGate(
            child: DailyAdGateScreen(child: child),
          );
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
