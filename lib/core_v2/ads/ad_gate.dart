import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import 'ad_policy.dart';

class AdGate extends ConsumerWidget {
  final Widget child;
  final Widget ad;

  const AdGate({
    super.key,
    required this.child,
    required this.ad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(sessionControllerProvider).session.plan;

    return Column(
      children: [
        Expanded(child: child),
        if (AdPolicy.shouldShowAds(plan)) ad,
      ],
    );
  }
}
