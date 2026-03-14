import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:tailorsync_v2/core/network/connectivity_provider.dart';
import 'package:tailorsync_v2/core/sync/models/sync_action.dart';

class OfflineWrapper extends ConsumerWidget {
  final Widget child;

  const OfflineWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    
    return ValueListenableBuilder(
      valueListenable: Hive.box<SyncAction>('sync_queue').listenable(),
      builder: (context, Box<SyncAction> box, _) {
        final hasPendingSync = box.isNotEmpty;
        
        return Stack(
          children: [
            child,
            if (isOffline || hasPendingSync)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Material(
                  color: isOffline 
                      ? Theme.of(context).colorScheme.errorContainer 
                      : Theme.of(context).colorScheme.primaryContainer,
                  elevation: 4,
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded,
                            color: isOffline 
                                ? Theme.of(context).colorScheme.onErrorContainer 
                                : Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isOffline 
                                  ? (hasPendingSync ? 'Offline. ${box.length} changes will sync later.' : 'You are offline. Showing cached data.')
                                  : 'Syncing ${box.length} changes...',
                              style: TextStyle(
                                color: isOffline 
                                    ? Theme.of(context).colorScheme.onErrorContainer 
                                    : Theme.of(context).colorScheme.onPrimaryContainer,
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
                              foregroundColor: isOffline 
                                  ? Theme.of(context).colorScheme.onErrorContainer 
                                  : Theme.of(context).colorScheme.onPrimaryContainer,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
                Icon(Icons.sync_rounded, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Offline Sync is Active',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Needlix now works fully offline! Here is what you can do:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(context, Icons.check_circle, 'Create new jobs and customers while offline.'),
            const SizedBox(height: 8),
            _buildFeatureRow(context, Icons.check_circle, 'Update measurements and order statuses.'),
            const SizedBox(height: 8),
            _buildFeatureRow(context, Icons.cloud_done, 'All changes automatically sync when you are back online.'),
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

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green),
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
