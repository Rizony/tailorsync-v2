// ignore_for_file: deprecated_member_use, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/settings/screens/shop_settings_screen.dart';
import 'package:tailorsync_v2/core/theme/app_theme.dart';
import 'package:tailorsync_v2/core/theme/theme_provider.dart';
import 'package:tailorsync_v2/core/auth/auth_provider.dart';
import 'package:tailorsync_v2/features/monetization/screens/upgrade_screen.dart';
import 'package:tailorsync_v2/features/auth/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
    final userProfile = ref.watch(profileNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Profile Header ---
          if (userProfile != null) ...[
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: userProfile.logoUrl != null 
                        ? NetworkImage(userProfile.logoUrl!) 
                        : null,
                    child: userProfile.logoUrl == null 
                        ? Icon(Icons.store, size: 40, color: Theme.of(context).colorScheme.primary) 
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userProfile.shopName ?? 'My Tailor Shop',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userProfile.fullName ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // --- General Section ---
          _buildSectionHeader('General'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Shop Settings', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Branding, Invoices, Bank Details'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShopSettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined, color: AppTheme.brandBlue),
                  title: const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(_getThemeString(ref.watch(themeModeProvider))),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showThemePicker(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Subscription Section ---
          _buildSectionHeader('Account & Billing'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.star_rounded, color: Colors.amber),
                  title: const Text('My Subscription', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Current Plan: ${userProfile?.subscriptionTier.name.toUpperCase() ?? 'FREEMIUM'}'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Support Section ---
          _buildSectionHeader('Support & About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help center coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  trailing: Text(_appVersion, style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // --- Logout Button ---
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // --- Danger Zone ---
          _buildSectionHeader('Danger Zone'),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Permanently delete your account and all data',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
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

  String _getThemeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light Mode';
      case ThemeMode.dark: return 'Dark Mode';
      case ThemeMode.system: return 'System Default';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text('Choose Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                // ignore: deprecated_member_use
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: currentMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode!);
                    Navigator.pop(context);
                  },
                ),
                // ignore: deprecated_member_use
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: currentMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode!);
                    Navigator.pop(context);
                  },
                ),
                // ignore: deprecated_member_use
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: currentMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    // Single dialog: warning + password entry
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will permanently delete your account and ALL data (jobs, customers, invoices). This CANNOT be undone.\n\nEnter your password to confirm:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final pwd = passwordController.text.trim();
                if (pwd.isNotEmpty) Navigator.pop(ctx, pwd);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete My Account'),
            ),
          ],
        ),
      ),
    );

    passwordController.dispose();
    if (password == null || password.isEmpty || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Re-authenticate with the provided password before deleting
      final email = ref.read(profileNotifierProvider).valueOrNull?.email
          ?? Supabase.instance.client.auth.currentUser?.email ?? '';
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Password verified — proceed with deletion
      await ref.read(authRepositoryProvider.notifier).deleteAccount();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your account has been permanently deleted.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password. Account was not deleted.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
