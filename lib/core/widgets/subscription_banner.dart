import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';
import 'package:tailorsync_v2/features/monetization/screens/upgrade_screen.dart';

/// A slim banner shown at the top of every app tab.
/// Displays the user's plan badge and (for non-Premium) an upgrade nudge.
class SubscriptionBanner extends ConsumerWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(profileNotifierProvider).valueOrNull?.subscriptionTier
        ?? SubscriptionTier.freemium;

    if (tier == SubscriptionTier.premium) return const SizedBox.shrink();

    final bool isStandard = tier == SubscriptionTier.standard;

    final (Color bannerColor, Color badgeColor, String badgeText, String ctaText) =
        isStandard
            ? (
                const Color(0xFFE3F2FD),
                const Color(0xFF1E78D2),
                'STANDARD',
                'Upgrade to Premium →',
              )
            : (
                Colors.amber.shade50,
                const Color(0xFF607D8B),
                'FREEMIUM',
                'Upgrade your plan →',
              );

    return Material(
      color: bannerColor,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              // Plan badge chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ctaText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}
