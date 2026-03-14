import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/features/dashboard/screens/dashboard_screen.dart';
import 'package:tailorsync_v2/features/settings/screens/settings_screen.dart';
import 'package:tailorsync_v2/features/jobs/screens/jobs_list_screen.dart';
import 'package:tailorsync_v2/features/customers/screens/customers_screen.dart';
import 'package:tailorsync_v2/features/community/screens/community_screen.dart';
import 'package:tailorsync_v2/core/app/offline_wrapper.dart';
import 'package:tailorsync_v2/core/utils/tutorial_service.dart';
import 'package:tailorsync_v2/core/widgets/subscription_banner.dart';
import 'package:tailorsync_v2/core/providers/navigation_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // The index of these screens must match the BottomNavigationBar items exactly
  final List<Widget> _screens = [
    const DashboardScreen(),
    const JobsListScreen(),
    const CustomersScreen(),
    const CommunityScreen(), // The new Community tab
    const SettingsScreen(), // Settings
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: OfflineWrapper(child: _screens[currentIndex]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SubscriptionBanner(),
          BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(navigationProvider.notifier).state = index;
            },
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(key: TutorialService.ordersTabKey, Icons.style),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
              const BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Community'),
              BottomNavigationBarItem(
                icon: Icon(key: TutorialService.settingsTabKey, Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}