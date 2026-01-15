import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import '../monetization/feature_gate.dart';

class LockedFeature extends ConsumerWidget {
  final Feature feature;
  final Widget child;

  const LockedFeature({
    super.key,
    required this.feature,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).session;
    final allowed = FeatureGate.canAccess(session.plan, feature);

    if (allowed) return child;

    return Stack(
      children: [
        Opacity(
          opacity: 0.4,
          child: child,
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => _showUpsell(context),
            child: Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: const Icon(
                Icons.lock,
                size: 48,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpsell(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _UpgradeSheet(),
    );
  }
}

class _UpgradeSheet extends StatelessWidget {
  const _UpgradeSheet();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 40),
          SizedBox(height: 16),
          Text(
            'Upgrade to unlock this feature',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Get analytics, exports, and partner benefits.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: null, // wired in Phase 5
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
