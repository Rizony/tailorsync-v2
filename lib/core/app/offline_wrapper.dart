import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/network/connectivity_provider.dart';

class OfflineWrapper extends ConsumerWidget {
  final Widget child;

  const OfflineWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    return Stack(
      children: [
        child,
        if (isOffline)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Positioned at the bottom of the screen (above bottom nav bar if wrapped inside AppShell body)
            child: Material(
              color: Theme.of(context).colorScheme.errorContainer,
              elevation: 4,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are offline. Showing cached data.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) => const _OfflineDetailsSheet(),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('WHAT TO DO', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OfflineDetailsSheet extends StatelessWidget {
  const _OfflineDetailsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wifi_off_rounded, size: 28, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'No Internet Connection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your app is in limited offline mode. Here is what you can do right now:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(context, Icons.check_circle_outline, 'View all your previously loaded jobs & measurements.'),
            const SizedBox(height: 8),
            _buildFeatureRow(context, Icons.check_circle_outline, 'Browse customer profiles that you already opened.'),
            const SizedBox(height: 8),
            _buildFeatureRow(context, Icons.cancel_outlined, 'Cannot create new jobs, clients, or sync changes.', isNegative: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text, {bool isNegative = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isNegative ? Theme.of(context).colorScheme.error : Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
