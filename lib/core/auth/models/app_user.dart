import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'shop_name') String? shopName,
    @Default(SubscriptionTier.freemium) SubscriptionTier subscriptionTier,
    String? referralCode,
    String? referrerId,
    @Default(0.0) double walletBalance,
    @Default(0) int adCredits, // Used for the "Watch ad to add customer" logic
    
    // Shop Settings
    @JsonKey(name: 'brand_name') String? brandName,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'signature_url') String? signatureUrl,
    @JsonKey(name: 'accent_color') String? accentColor,
    @JsonKey(name: 'default_tax_rate') @Default(0.0) double defaultTaxRate,
    @JsonKey(name: 'invoice_notes') String? invoiceNotes,
    @JsonKey(name: 'terms_and_conditions') String? termsAndConditions,
    
    // Currency Settings
    @JsonKey(name: 'currency_code') @Default('NGN') String currencyCode,
    @JsonKey(name: 'currency_symbol') @Default('₦') String currencySymbol,
    
    // Branding Contact Info
    @JsonKey(name: 'shop_address') String? shopAddress,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'website') String? website,
    @JsonKey(name: 'social_media_handle') String? socialMediaHandle,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}