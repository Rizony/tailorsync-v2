import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:needlix/features/dashboard/screens/dashboard_screen.dart';
import 'package:needlix/features/settings/screens/settings_screen.dart';
import 'package:needlix/features/orders/screens/orders_list_screen.dart';
import 'package:needlix/features/customers/screens/customers_screen.dart';
import 'package:needlix/features/community/screens/community_screen.dart';
import 'package:needlix/core/app/offline_wrapper.dart';
import 'package:needlix/core/utils/tutorial_service.dart';
import 'package:needlix/core/widgets/subscription_banner.dart';
import 'package:needlix/core/providers/navigation_provider.dart';
import 'package:needlix/features/marketplace/services/marketplace_notification_service.dart';
import 'package:needlix/features/marketplace/repositories/marketplace_repository.dart';
import 'package:needlix/core/sync/sync_manager.dart';
import 'package:needlix/core/network/connectivity_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // The index of these screens must match the BottomNavigationBar items exactly
  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrdersListScreen(),
    const CustomersScreen(),
    const CommunityScreen(), // The new Community tab
    const SettingsScreen(), // Settings
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    
    // Initialize marketplace alerts
    ref.watch(marketplaceNotificationServiceProvider);

    // Ensure offline sync manager is initialized and starts processing when online.
    ref.watch(syncManagerProvider);
    final isOffline = ref.watch(isOfflineProvider);
    if (!isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(syncManagerProvider).processQueue();
      });
    }

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
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.dashboard_outlined),
                ), 
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.dashboard),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(key: TutorialService.ordersTabKey, Icons.style_outlined),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.style),
                ),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.people_outline),
                ), 
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.people),
                ),
                label: 'Customers',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Badge(
                    label: ref.watch(pendingMarketplaceRequestsCountProvider) > 0 
                        ? Text(ref.watch(pendingMarketplaceRequestsCountProvider).toString()) 
                        : null,
                    isLabelVisible: ref.watch(pendingMarketplaceRequestsCountProvider) > 0,
                    child: const Icon(Icons.forum_outlined),
                  ),
                ), 
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Badge(
                    label: ref.watch(pendingMarketplaceRequestsCountProvider) > 0 
                        ? Text(ref.watch(pendingMarketplaceRequestsCountProvider).toString()) 
                        : null,
                    isLabelVisible: ref.watch(pendingMarketplaceRequestsCountProvider) > 0,
                    child: const Icon(Icons.forum),
                  ),
                ), 
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(key: TutorialService.settingsTabKey, Icons.settings_outlined),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.settings),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}