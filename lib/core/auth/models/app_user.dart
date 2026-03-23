import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:needlix/features/monetization/models/subscription_tier.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'shop_name') String? shopName,
    @JsonKey(name: 'subscription_tier') @Default(SubscriptionTier.freemium) SubscriptionTier subscriptionTier,
    @JsonKey(name: 'referral_code') String? referralCode,
    @JsonKey(name: 'referrer_id') String? referrerId,
    @Default(0.0) double walletBalance,
    @Default(0) int adCredits, // Used for the "Watch ad to add customer" logic
    
    // Shop Settings
    @JsonKey(name: 'brand_name') String? brandName,
    @JsonKey(name: 'logo_url', readValue: _readLogoUrl) String? logoUrl,
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
    
    // Withdrawal Settings
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'withdrawal_pin') String? withdrawalPin,
    
    // Marketplace Profile
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
    @JsonKey(name: 'bio') String? bio,
    @JsonKey(name: 'specialties') @Default([]) List<String> specialties,
    @JsonKey(name: 'rating') @Default(5.0) double rating,
    @JsonKey(name: 'public_profile_enabled') @Default(false) bool publicProfileEnabled,
    @JsonKey(name: 'years_of_experience') @Default(0) int yearsOfExperience,
    @JsonKey(name: 'portfolio_urls') @Default([]) List<String> portfolioUrls,
    
    // KYC
    @JsonKey(name: 'kyc_status') @Default('none') String kycStatus,
    @JsonKey(name: 'kyc_document_url') String? kycDocumentUrl,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

Object? _readLogoUrl(Map map, String key) {
  final logoUrl = map['logo_url'] as String?;
  if (logoUrl != null && logoUrl.isNotEmpty) return logoUrl;
  
  final photoUrl = map['photo_url'] as String?;
  if (photoUrl != null && photoUrl.isNotEmpty) return photoUrl;
  
  return map['avatar_url'];
}