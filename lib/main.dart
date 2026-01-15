import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_v2/app/app_config.dart';
import 'core_v2/app/app_shell.dart';
import 'core_v2/app/splash_screen.dart';
import 'core_v2/auth/auth_controller.dart';
import 'core_v2/auth/auth_state.dart';
import 'core_v2/invoicing/invoices_controller.dart';
import 'core_v2/session/session_controller.dart';
import 'core_v2/theme/theme_resolver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        /// SESSION
        sessionControllerProvider.overrideWith(
          (ref) => throw UnimplementedError(),
        ),

        /// INVOICES
        invoicesControllerProvider.overrideWith(
          (ref) => throw UnimplementedError(),
        ),
      ],
      child: const TailorSyncBootstrap(),
    ),
  );
}

/// ------------------------------------------------------------
/// Bootstrap Gate
/// ------------------------------------------------------------
class TailorSyncBootstrap extends ConsumerWidget {
  const TailorSyncBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionBootstrapProvider);
    final invoicesAsync = ref.watch(invoicesBootstrapProvider);

    return sessionAsync.when(
      loading: () => const SplashScreen(),
      error: (_, __) => const SplashScreen(),
      data: (sessionController) {
        return invoicesAsync.when(
          loading: () => const SplashScreen(),
          error: (_, __) => const SplashScreen(),
          data: (invoicesController) {
            return ProviderScope(
              overrides: [
                sessionControllerProvider.overrideWith(
                  (ref) => sessionController,
                ),
                invoicesControllerProvider.overrideWith(
                  (ref) => invoicesController,
                ),
              ],
              child: const TailorSyncApp(),
            );
          },
        );
      },
    );
  }
}

/// ------------------------------------------------------------
/// App
/// ------------------------------------------------------------
class TailorSyncApp extends ConsumerWidget {
  const TailorSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AppConfig.defaultConfig();
    final session = ref.watch(sessionControllerProvider).session;
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TailorSync',
      theme: ThemeResolver.resolve(
        brand: config.brand,
        session: session,
      ),
      home: switch (authState.status) {
        AuthStatus.loading => const SplashScreen(),
        AuthStatus.unauthenticated => const SplashScreen(),
        AuthStatus.authenticated => const AppShell(),
      },
    );
  }
}
