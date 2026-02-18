import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tailorsync_v2/features/settings/screens/shop_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Shop Settings'),
            subtitle: const Text('Branding, Invoice config, Tax'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopSettingsScreen()),
              );
            },
          ),
          const Divider(),

          _buildSectionHeader('Subscription'),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('My Subscription'),
            subtitle: const Text('Manage plan and billing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Subscription Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription management coming soon')),
              );
            },
          ),
          const Divider(),

          _buildSectionHeader('Support'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               // TODO: Launch URL to help docs
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help center coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Version $_appVersion'),
          ),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement Logout
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout functionality pending')),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log Out', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
