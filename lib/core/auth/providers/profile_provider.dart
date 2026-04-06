import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/features/monetization/models/subscription_tier.dart';
import 'package:needlix/core/auth/auth_provider.dart';
import '../models/app_user.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<AppUser?> build() async {
    // Watch AuthState so this provider recalculates on login/logout
    ref.watch(authControllerProvider);
    
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Fetch initial data
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
        
    // Listen for realtime updates to keep subscription & profile fully synced
    final subscription = _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .listen((payload) {
          if (payload.isNotEmpty) {
            state = AsyncValue.data(AppUser.fromJson(payload.first));
          }
        }, onError: (error) {
          print('Supabase Profile Stream error ignored: $error');
        });

    ref.onDispose(() {
      subscription.cancel();
    });

    final isVerified = user.emailConfirmedAt != null;
    return AppUser.fromJson(data).copyWith(isEmailVerified: isVerified);
  }

  Future<void> fetchProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
        
    final isVerified = user.emailConfirmedAt != null;
    state = AsyncValue.data(AppUser.fromJson(data).copyWith(isEmailVerified: isVerified));
  }

  Future<void> updateProfile(AppUser updatedUser) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('profiles').update({
      'shop_name': updatedUser.shopName,
      'brand_name': updatedUser.brandName,
      'logo_url': updatedUser.logoUrl,
      'signature_url': updatedUser.signatureUrl,
      'accent_color': updatedUser.accentColor,
      'default_tax_rate': updatedUser.defaultTaxRate,
      'invoice_notes': updatedUser.invoiceNotes,
      'terms_and_conditions': updatedUser.termsAndConditions,
      'shop_address': updatedUser.shopAddress,
      'phone_number': updatedUser.phoneNumber,
      'email': updatedUser.email,
      'website': updatedUser.website,
      'social_media_handle': updatedUser.socialMediaHandle,
      'currency_code': updatedUser.currencyCode,
      'currency_symbol': updatedUser.currencySymbol,
      // Withdrawal settings
      'bank_name': updatedUser.bankName,
      'account_number': updatedUser.accountNumber,
      'account_name': updatedUser.accountName,
      'withdrawal_pin': updatedUser.withdrawalPin,
      // Marketplace profile fields
      'is_available': updatedUser.isAvailable,
      'tailor_type': updatedUser.tailorType,
      'latitude': updatedUser.latitude,
      'longitude': updatedUser.longitude,
      'public_profile_enabled': updatedUser.publicProfileEnabled,
      'years_of_experience': updatedUser.yearsOfExperience,
      'bio': updatedUser.bio,
      'specialties': updatedUser.specialties,
      'portfolio_urls': updatedUser.portfolioUrls,
    }).eq('id', user.id);
    
    // Update local state
    state = AsyncValue.data(updatedUser);
  }

  // Helper to check if user can add a customer based on Tier
  bool canAddCustomer(int currentCount) {
    final user = state.valueOrNull;
    if (user == null) return false;
    if (user.subscriptionTier != SubscriptionTier.freemium) return true;
    
    // If freemium, check if they have count < 20 OR have ad credits
    return currentCount < 20 || user.adCredits > 0;
  }
}

@riverpod
Future<AppUser?> publicProfile(PublicProfileRef ref, String userId) async {
  final supabase = Supabase.instance.client;
  try {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return AppUser.fromJson(data);
  } catch (e) {
    return null;
  }
}