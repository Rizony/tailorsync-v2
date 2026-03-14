import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/network/connectivity_provider.dart';
import 'package:tailorsync_v2/core/sync/models/sync_action.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(ref);
  // Start monitoring
  ref.listen(isOfflineProvider, (previous, next) {
    if (!next) {
      // Transitioned to online
      manager.processQueue();
    }
  });
  return manager;
});

class SyncManager {
  final Ref _ref;
  final _supabase = Supabase.instance.client;
  bool _isProcessing = false;

  SyncManager(this._ref);

  Future<void> processQueue() async {
    if (_isProcessing) return;
    
    final isOffline = _ref.read(isOfflineProvider);
    if (isOffline) return;

    final syncBox = Hive.box<SyncAction>('sync_queue');
    if (syncBox.isEmpty) return;

    _isProcessing = true;
    debugPrint('🔄 Starting background sync... ${syncBox.length} items pending.');

    try {
      final keys = syncBox.keys.toList();
      for (final key in keys) {
        final action = syncBox.get(key);
        if (action == null) continue;

        final success = await _executeAction(action);
        if (success) {
          await syncBox.delete(key);
          debugPrint('✅ Sync successful: ${action.actionType} ${action.endpoint}');
        } else {
          // Update retry count or handle error
          final updatedAction = action.copyWith(
            retryCount: action.retryCount + 1,
            error: 'Failed to sync. Will retry.',
          );
          await syncBox.put(key, updatedAction);
          
          // Stop processing queue if we hit a persistent error or network drop
          if (action.retryCount > 5) {
             debugPrint('⚠️ Action failed after 5 retries. Skipping for now.');
          } else {
            break; 
          }
        }
      }
    } finally {
      _isProcessing = false;
      debugPrint('🏁 Background sync finished.');
    }
  }

  Future<bool> _executeAction(SyncAction action) async {
    try {
      final payload = Map<String, dynamic>.from(action.payload);
      
      switch (action.actionType) {
        case SyncAction.actionCreate:
          await _supabase.from(action.endpoint).insert(payload);
          return true;
        
        case SyncAction.actionUpdate:
          // Assume ID is in the payload for updates
          final id = payload['id'];
          if (id == null) return false;
          await _supabase
              .from(action.endpoint)
              .update(payload..remove('id'))
              .eq('id', id);
          return true;
        
        case SyncAction.actionDelete:
          final id = payload['id'];
          if (id == null) return false;
          await _supabase
              .from(action.endpoint)
              .delete()
              .eq('id', id);
          return true;
        
        default:
          return false;
      }
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      return false;
    }
  }
}
