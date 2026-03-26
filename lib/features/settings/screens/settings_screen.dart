// ignore_for_file: deprecated_member_use, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/features/settings/screens/shop_settings_screen.dart';

import 'package:needlix/core/theme/theme_provider.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/auth/auth_provider.dart';
import 'package:needlix/features/monetization/screens/upgrade_screen.dart';
import 'package:needlix/features/referrals/screens/referral_dashboard_screen.dart';
import 'package:needlix/features/auth/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/features/monetization/screens/wallet_dashboard_screen.dart';
import 'package:needlix/features/monetization/screens/kyc_verification_screen.dart';
import 'package:needlix/features/monetization/screens/report_center_screen.dart';
import 'package:needlix/features/support/screens/support_list_screen.dart';
import 'package:needlix/features/settings/screens/security_settings_screen.dart';

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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: userProfile.logoUrl != null 
                          ? NetworkImage(userProfile.logoUrl!) 
                          : null,
                      child: userProfile.logoUrl == null 
                          ? Icon(Icons.store, size: 40, color: Theme.of(context).colorScheme.primary) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userProfile.shopName ?? 'My Tailor Shop',
                    style: AppTypography.h3,
                  ),
                  Text(
                    userProfile.fullName ?? '',
                    style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // --- General Section ---
          _buildSectionHeader('General'),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.primary),
                  title: Text('Shop Settings', style: AppTypography.label),
                  subtitle: Text('Branding, Invoices, Bank Details', style: AppTypography.bodySmall),
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
                  leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                  title: Text('Appearance', style: AppTypography.label),
                  subtitle: Text(_getThemeString(ref.watch(themeModeProvider)), style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showThemePicker(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Subscription Section ---
          _buildSectionHeader('Account & Billing'),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.star_rounded, color: Colors.amber),
                  title: Text('My Subscription', style: AppTypography.label),
                  subtitle: Text('Plan: ${userProfile?.subscriptionTier.label.toUpperCase() ?? 'FREEMIUM'}', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.handshake_outlined, color: Colors.green),
                  title: Text('Partner Program', style: AppTypography.label),
                  subtitle: Text('Referrals, Wallet & Withdrawals', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReferralDashboardScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: Colors.blue),
                  title: Text('Report Center', style: AppTypography.label),
                  subtitle: Text('Business performance & AI insights', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportCenterScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
                  title: Text('Escrow Wallet', style: AppTypography.label),
                  subtitle: Text('Pending Escrow & Available Payouts', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletDashboardScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: Colors.green),
                  title: Text('KYC Verification', style: AppTypography.label),
                  subtitle: Text('Upload ID to enable full payouts', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KycVerificationScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_outlined, color: Colors.redAccent),
                  title: Text('Security & Account', style: AppTypography.label),
                  subtitle: Text('Password, Email & Verification Status', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Support Section ---
          _buildSectionHeader('Support & About'),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.primary),
                  title: Text('Help & Support', style: AppTypography.label),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportListScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('App Version', style: AppTypography.label),
                  trailing: Text(_appVersion, style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
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
        style: AppTypography.bodySmall.copyWith(
          color: Colors.grey[600],
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
