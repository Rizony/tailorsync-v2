import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/auth/auth_state.dart';

import '../auth/auth_controller.dart';
import 'splash_screen.dart';
import 'app_shell.dart';

class TailorSyncApp extends ConsumerWidget {
  const TailorSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    switch (auth.status) {
      case AuthStatus.loading:
        return const SplashScreen();

      case AuthStatus.unauthenticated:
        return const SplashScreen(); // later: LoginScreen

      case AuthStatus.authenticated:
        return const AppShell();
    }
  }
}
