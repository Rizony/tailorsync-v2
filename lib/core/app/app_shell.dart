import 'package:flutter/material.dart';
import 'package:tailorsync_v2/features/dashboard/screens/dashboard_screen.dart';
// Note: Ensure your import matches your pubspec.yaml name (tailorsync_v2)
import 'package:tailorsync_v2/features/settings/screens/settings_screen.dart';
import 'package:tailorsync_v2/features/jobs/screens/jobs_list_screen.dart';
import 'package:tailorsync_v2/features/customers/screens/customers_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // The index of these screens must match the BottomNavigationBar items exactly
  final List<Widget> _screens = [
    const DashboardScreen(),
    const JobsListScreen(),
    const CustomersScreen(),
    const SettingsScreen(), // Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF5D3FD3),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}