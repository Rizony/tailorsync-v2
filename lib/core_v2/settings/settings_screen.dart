import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/monetization/plan_selector_sheet.dart';
import 'package:tailorsync_v2/core_v2/screens/payouts_screen.dart';

import '../session/session_controller.dart';
import '../monetization/subscription_plan.dart';
import '../monetization/referral_debug_panel.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(sessionControllerProvider);
    final session = controller.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {
              Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PayoutsScreen()),
);

            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- Account ----------------
          _sectionTitle('Account'),

          _infoTile('User ID', session.userId),
          _infoTile('Plan', _planLabel(session.plan)),
          _infoTile('Referrals', session.referralCount.toString()),
          _infoTile(
            'Monthly Earnings',
            '\$${controller.monthlyReferralEarnings.toStringAsFixed(2)}',
          ),
const SizedBox(height: 24),
          ListTile(
  title: const Text('Change Subscription Plan'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    showModalBottomSheet(
      context: context,
      builder: (_) => const PlanSelectorSheet(),
    );
  },
),


const SizedBox(height: 24),
const ReferralDebugPanel(),
          

          // ---------------- Preferences ----------------
          _sectionTitle('Preferences'),

          SwitchListTile(
            title: const Text('Dark Mode'),
            value: session.isDarkMode,
            onChanged: controller.toggleDarkMode,
          ),

          SwitchListTile(
            title: const Text('Seasonal Theme'),
            value: session.isSeasonalThemeEnabled,
            onChanged: controller.toggleSeasonalTheme,
          ),

          const SizedBox(height: 24),

          // ---------------- Debug / Logout ----------------
          _sectionTitle('Session'),

          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset Session'),
            subtitle: const Text('Clears local session & preferences'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset session?'),
                  content: const Text(
                      'This will clear all locally stored session data.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await controller.resetSession();
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------- UI helpers ----------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  String _planLabel(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.standard:
        return 'Standard';
      case SubscriptionPlan.premium:
        return 'Premium';
    }
  }
}
