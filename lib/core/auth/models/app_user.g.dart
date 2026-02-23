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
              _$SubscriptionTierEnumMap, json['subscriptionTier']) ??
          SubscriptionTier.freemium,
      referralCode: json['referralCode'] as String?,
      referrerId: json['referrerId'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      adCredits: (json['adCredits'] as num?)?.toInt() ?? 0,
      brandName: json['brand_name'] as String?,
      logoUrl: json['logo_url'] as String?,
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
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'shop_name': instance.shopName,
      'subscriptionTier': _$SubscriptionTierEnumMap[instance.subscriptionTier]!,
      'referralCode': instance.referralCode,
      'referrerId': instance.referrerId,
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
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.freemium: 'freemium',
  SubscriptionTier.standard: 'standard',
  SubscriptionTier.premium: 'premium',
};
