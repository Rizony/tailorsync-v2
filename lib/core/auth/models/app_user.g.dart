// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      shopName: json['shop_name'] as String?,
      subscriptionTier: $enumDecodeNullable(
              _$SubscriptionTierEnumMap, json['subscription_tier']) ??
          SubscriptionTier.freemium,
      referralCode: json['referral_code'] as String?,
      referrerId: json['referrer_id'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      adCredits: (json['adCredits'] as num?)?.toInt() ?? 0,
      brandName: json['brand_name'] as String?,
      logoUrl: _readLogoUrl(json, 'logo_url') as String?,
      signatureUrl: json['signature_url'] as String?,
      accentColor: json['accent_color'] as String?,
      defaultTaxRate: (json['default_tax_rate'] as num?)?.toDouble() ?? 0.0,
      invoiceNotes: json['invoice_notes'] as String?,
      termsAndConditions: json['terms_and_conditions'] as String?,
      currencyCode: json['currency_code'] as String? ?? 'NGN',
      currencySymbol: json['currency_symbol'] as String? ?? '₦',
      shopAddress: json['shop_address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      socialMediaHandle: json['social_media_handle'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      withdrawalPin: json['withdrawal_pin'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      tailorType: json['tailor_type'] as String? ?? 'Unisex',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bio: json['bio'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      publicProfileEnabled: json['public_profile_enabled'] as bool? ?? false,
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
      portfolioUrls: (json['portfolio_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      kycStatus: json['kyc_status'] as String? ?? 'none',
      kycDocumentUrl: json['kyc_document_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'shop_name': instance.shopName,
      'subscription_tier':
          _$SubscriptionTierEnumMap[instance.subscriptionTier]!,
      'referral_code': instance.referralCode,
      'referrer_id': instance.referrerId,
      'walletBalance': instance.walletBalance,
      'adCredits': instance.adCredits,
      'brand_name': instance.brandName,
      'logo_url': instance.logoUrl,
      'signature_url': instance.signatureUrl,
      'accent_color': instance.accentColor,
      'default_tax_rate': instance.defaultTaxRate,
      'invoice_notes': instance.invoiceNotes,
      'terms_and_conditions': instance.termsAndConditions,
      'currency_code': instance.currencyCode,
      'currency_symbol': instance.currencySymbol,
      'shop_address': instance.shopAddress,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'social_media_handle': instance.socialMediaHandle,
      'bank_name': instance.bankName,
      'account_number': instance.accountNumber,
      'account_name': instance.accountName,
      'withdrawal_pin': instance.withdrawalPin,
      'is_available': instance.isAvailable,
      'tailor_type': instance.tailorType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'bio': instance.bio,
      'specialties': instance.specialties,
      'rating': instance.rating,
      'public_profile_enabled': instance.publicProfileEnabled,
      'years_of_experience': instance.yearsOfExperience,
      'portfolio_urls': instance.portfolioUrls,
      'kyc_status': instance.kycStatus,
      'kyc_document_url': instance.kycDocumentUrl,
      'is_admin': instance.isAdmin,
      'isEmailVerified': instance.isEmailVerified,
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.freemium: 'freemium',
  SubscriptionTier.standard: 'standard',
  SubscriptionTier.premium: 'premium',
};
