import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:needlix/core/ads/ad_service.dart';
import 'package:needlix/core/auth/auth_provider.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/utils/error_handler_util.dart';
import 'package:needlix/features/monetization/models/subscription_tier.dart';
import 'package:needlix/core/sync/models/sync_action.dart';
import 'package:needlix/core/sync/sync_manager.dart';
import 'package:flutter/material.dart';
import '../models/customer.dart';

part 'customer_repository.g.dart';

@riverpod
class CustomerRepository extends _$CustomerRepository {
  final _supabase = Supabase.instance.client;
  late Box<Customer> _customerBox;
  late Box<SyncAction> _syncBox;

  @override
  Future<List<Customer>> build() async {
    // SECURITY: Watch AuthState so this provider recalculates on login/logout
    ref.watch(authControllerProvider);
    
    _customerBox = Hive.box<Customer>('customers');
    _syncBox = Hive.box<SyncAction>('sync_queue');
    
    // Return cached data immediately
    final cached = _customerBox.values.toList();
    if (cached.isNotEmpty) {
      // SECURITY: Validate cache belongs to current user
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null && cached.first.userId != currentUserId) {
        // Cache poisoning detected!
        await _customerBox.clear();
        return _fetchRemote();
      }

      // Trigger a background fetch to sync with remote
      _fetchRemote();
      return cached;
    }

    return _fetchRemote();
  }

  Future<List<Customer>> _fetchRemote() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('created_at', ascending: false);
      
      final customers = (response as List).map((e) => Customer.fromJson(e)).toList();
      
      // Update cache
      await _customerBox.clear();
      await _customerBox.addAll(customers);
      
      state = AsyncValue.data(customers);
      return customers;
    } catch (e, stack) {
      // If we have cached data, don't throw error, just keep showing cache
      if (_customerBox.isNotEmpty) return _customerBox.values.toList();
      throw ErrorHandler.handle(e, stack);
    }
  }

  Future<Customer> addCustomer(Customer customer) async {
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    final currentCount = state.valueOrNull?.length ?? 0;

    // 🛡️ THE GATEKEEPER LOGIC
    if (profile?.subscriptionTier == SubscriptionTier.freemium) {
      if (currentCount >= SubscriptionTier.freemium.baseCustomerLimit) {
        final adCredits = profile?.adCredits ?? 0;
        final totalPossible = SubscriptionTier.freemium.baseCustomerLimit + adCredits;
        if (currentCount >= SubscriptionTier.freemium.customerLimit) {
          throw Exception("MAX_LIMIT_REACHED");
        }
        if (currentCount >= totalPossible) {
          throw Exception("LIMIT_REACHED");
        }
      }
    }

    final id = const Uuid().v4();
    final newCustomer = customer.copyWith(
      id: id,
      userId: _supabase.auth.currentUser!.id,
      createdAt: DateTime.now(),
    );

    // 1. Save to local cache
    await _customerBox.put(id, newCustomer);
    
    // 2. Push to sync outbox
    await _pushSyncAction(
      SyncAction.actionCreate,
      'customers',
      newCustomer.toJson(),
      id,
    );

    ref.invalidateSelf(); // Update UI
    return newCustomer;
  }
  
  Future<void> updateCustomer(Customer customer) async {
    // 1. Save to local cache
    await _customerBox.put(customer.id!, customer);
    
    // 2. Push to sync outbox
    await _pushSyncAction(
      SyncAction.actionUpdate,
      'customers',
      customer.toJson(),
      customer.id!,
    );
    
    ref.invalidateSelf();
  }

  Future<void> deleteCustomer(String id) async {
    // 1. Remove from local cache
    await _customerBox.delete(id);
    
    // 2. Push to sync outbox
    await _pushSyncAction(
      SyncAction.actionDelete,
      'customers',
      {'id': id},
      id,
    );
    
    ref.invalidateSelf();
  }

  Future<void> _pushSyncAction(String type, String endpoint, Map<String, dynamic> payload, String targetId) async {
    final action = SyncAction(
      id: const Uuid().v4(),
      actionType: type,
      endpoint: endpoint,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await _syncBox.add(action);
    
    // Trigger SyncManager
    ref.read(syncManagerProvider).processQueue();
  }

  /// Keep existing ad-related logic for now
  void handleLimitWithAd(BuildContext context) {
    AdService.showRewardedAd(onRewardEarned: () async {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final profile = await _supabase
            .from('profiles')
            .select('ad_credits')
            .eq('id', user.id)
            .single();
        
        final currentCredits = profile['ad_credits'] ?? 0;
        const maxCredits = 30;
        
        if (currentCredits < maxCredits) {
          await _supabase
              .from('profiles')
              .update({'ad_credits': (currentCredits + 1).clamp(0, maxCredits)})
              .eq('id', user.id);
        }
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ad watched! You can now add 1 more customer.")),
        );
      }
    });
  }

  Future<Customer?> getCustomer(String id) async {
    // Check cache first
    final cached = _customerBox.get(id);
    if (cached != null) return cached;

    // Fallback to state
    final currentList = state.valueOrNull;
    if (currentList != null) {
      try {
        return currentList.firstWhere((c) => c.id == id);
      } catch (_) {}
    }

    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
          .single();
      final customer = Customer.fromJson(response);
      await _customerBox.put(id, customer); // Cache it
      return customer;
    } catch (e) {
       return null;
    }
  }
}