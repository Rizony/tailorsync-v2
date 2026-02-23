import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';
import 'package:tailorsync_v2/features/monetization/screens/upgrade_screen.dart';

/// A compact bottom-sheet that nudges freemium users to upgrade.
/// Call [UpgradeNudge.show] from anywhere in the app.
class UpgradeNudge {
  static Future<void> show(
    BuildContext context, {
    required String reason,
    String? featureName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NudgeSheet(reason: reason, featureName: featureName),
    );
  }
}

class _NudgeSheet extends ConsumerWidget {
  const _NudgeSheet({required this.reason, this.featureName});
  final String reason;
  final String? featureName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(profileNotifierProvider).valueOrNull?.subscriptionTier
        ?? SubscriptionTier.freemium;
    final isStandard = tier == SubscriptionTier.standard;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isStandard
                    ? [const Color(0xFFF58220), const Color(0xFFFF8C42)]
                    : [const Color(0xFF1E78D2), const Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStandard ? 'Unlock Premium' : 'Unlock Standard',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (featureName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    '"$featureName" requires ${isStandard ? 'Premium' : 'Standard or higher'}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UpgradeScreen()));
              },
              icon: const Icon(Icons.star),
              label: Text(isStandard ? 'Upgrade to Premium' : 'See Plans'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: isStandard
                    ? const Color(0xFFF58220)
                    : const Color(0xFF1E78D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe later',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
