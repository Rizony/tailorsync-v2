import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/auth/screens/login_screen.dart';
import 'package:needlix/core/terms/terms_gate.dart';
import 'package:needlix/features/monetization/screens/daily_ad_gate_screen.dart';
import 'package:needlix/core/auth/email_verification_gate.dart';
import 'package:needlix/core/auth/screens/reset_password_screen.dart';
import 'package:needlix/core/auth/app_lock_gate.dart';
import 'auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordScreen();
        }

        if (state.session != null) {
          // then DailyAdGateScreen handles the ad logic.
          return AppLockGate(
            child: EmailVerificationGate(
              child: TermsGate(
                child: DailyAdGateScreen(child: child),
              ),
            ),
          );
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
