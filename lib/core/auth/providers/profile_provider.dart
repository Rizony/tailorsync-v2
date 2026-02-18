import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';
import '../models/app_user.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<AppUser?> build() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    return AppUser.fromJson(data);
  }

  Future<void> updateProfile(AppUser updatedUser) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('profiles').update({
      'shop_name': updatedUser.shopName,
      'brand_name': updatedUser.brandName,
      // 'logo_url' handled by separate storage upload logic usually, 
      // but here we just save the URL string if passed.
      'logo_url': updatedUser.logoUrl, 
      'signature_url': updatedUser.signatureUrl,
      'accent_color': updatedUser.accentColor,
      'default_tax_rate': updatedUser.defaultTaxRate,
      'invoice_notes': updatedUser.invoiceNotes,
      'terms_and_conditions': updatedUser.termsAndConditions,
      // Add other fields as needed
    }).eq('id', user.id);
    
    // Update local state
    state = AsyncValue.data(updatedUser);
  }

  // Helper to check if user can add a customer based on Tier
  bool canAddCustomer(int currentCount) {
    final user = state.value;
    if (user == null) return false;
    if (user.subscriptionTier != SubscriptionTier.freemium) return true;
    
    // If freemium, check if they have count < 20 OR have ad credits
    return currentCount < 20 || user.adCredits > 0;
  }
}