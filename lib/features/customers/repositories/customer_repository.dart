import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tailorsync_v2/core/ads/ad_service.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';
import '../models/customer.dart';

part 'customer_repository.g.dart';

@riverpod
class CustomerRepository extends _$CustomerRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Customer>> build() async {
    final response = await _supabase
        .from('customers')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<void> addCustomer(Customer customer) async {
    final profile = ref.read(profileNotifierProvider).value;
    final currentCount = state.value?.length ?? 0;

    // 🛡️ THE GATEKEEPER LOGIC
    // Updated: Freemium users can add up to 50 customers (20 base + 30 via ads)
    // Standard/Premium: Unlimited
    if (profile?.subscriptionTier == SubscriptionTier.freemium) {
      // Check base limit (20 customers without ads)
      if (currentCount >= SubscriptionTier.freemium.baseCustomerLimit) {
        // Check if user has ad credits to add more (up to 50 max)
        final adCredits = profile?.adCredits ?? 0;
        final totalPossible = SubscriptionTier.freemium.baseCustomerLimit + adCredits;
        
        if (currentCount >= SubscriptionTier.freemium.customerLimit) {
          throw Exception("MAX_LIMIT_REACHED"); // Hard limit of 50 reached
        }
        
        if (currentCount >= totalPossible) {
          throw Exception("LIMIT_REACHED"); // Need to watch ad to add more
        }
      }
    }

    final data = customer.toJson()
      ..remove('id')
      ..remove('created_at')
      ..['user_id'] = _supabase.auth.currentUser!.id; // Ensure user_id is set

    await _supabase.from('customers').insert(data);
    
    ref.invalidateSelf(); // Refresh the list
  }
  
  /// Handle adding customer after watching ad (grants 1 customer credit)
  Future<void> addCustomerAfterAd(Customer customer) async {
    final profile = ref.read(profileNotifierProvider).value;
    final currentCount = state.value?.length ?? 0;

    // Check if user can still add (max 50 for freemium)
    if (profile?.subscriptionTier == SubscriptionTier.freemium && 
        currentCount >= SubscriptionTier.freemium.customerLimit) {
      throw Exception("MAX_LIMIT_REACHED");
    }

    // Add customer
    final data = customer.toJson()
      ..remove('id')
      ..remove('created_at')
      ..['user_id'] = _supabase.auth.currentUser!.id;

    await _supabase.from('customers').insert(data);
    
    // Decrement ad credit (1 customer per ad)
    if (profile?.subscriptionTier == SubscriptionTier.freemium) {
      await _supabase
          .from('profiles')
          .update({'ad_credits': (profile!.adCredits - 1).clamp(0, 30)})
          .eq('id', profile.id);
    }
    
    ref.invalidateSelf(); // Refresh the list
  }
  
  void handleLimitWithAd(BuildContext context) {
    AdService.showRewardedAd(onRewardEarned: () async {
      // Grant 1 customer credit (1 customer per ad watch)
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final profile = await _supabase
            .from('profiles')
            .select('ad_credits')
            .eq('id', user.id)
            .single();
        
        final currentCredits = profile['ad_credits'] ?? 0;
        const maxCredits = 30; // Max 30 ad credits (20 base + 30 ads = 50 total)
        
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
    // Try to find in current state first
    final currentList = state.value;
    if (currentList != null) {
      try {
        return currentList.firstWhere((c) => c.id == id);
      } catch (_) {
        // Not found in list, fetch from DB
      }
    }

    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
          .single();
      return Customer.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    await _supabase
        .from('customers')
        .update(customer.toJson()..remove('id')..remove('created_at'))
        .eq('id', customer.id!);
    
    ref.invalidateSelf();
  }

  Future<void> deleteCustomer(String id) async {
    await _supabase.from('customers').delete().eq('id', id);
    ref.invalidateSelf();
  }
}