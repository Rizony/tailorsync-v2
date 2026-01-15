import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/monetization/ui/upgrade_screen.dart';
import 'package:tailorsync_v2/core_v2/session/session_controller.dart';
import 'package:tailorsync_v2/core_v2/settings/settings_screen.dart';
import 'package:tailorsync_v2/ui/customers/customers_list_screen.dart';

import 'app_destinations.dart';
import '../screens/earnings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppDestination _current = AppDestination.home;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final session = ref.watch(sessionControllerProvider).session;

        return Scaffold(
          body: IndexedStack(
            index: _current.index,
            children: const [
              CustomersListScreen(),
              EarningsScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _current.index,
            onTap: (index) {
              final destination = AppDestination.values[index];

              // 🔒 Gate Earnings tab
              if (destination == AppDestination.earnings &&
                  !session.plan.canViewEarnings) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const UpgradeScreen(),
                  ),
                );
                return;
              }

              setState(() {
                _current = destination;
              });
            },
            items: [
              for (final dest in AppDestination.values)
                BottomNavigationBarItem(
                  icon: Icon(dest.icon),
                  label: dest.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
