// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get shopName => throw _privateConstructorUsedError;
  SubscriptionTier get subscriptionTier => throw _privateConstructorUsedError;
  String? get referralCode => throw _privateConstructorUsedError;
  String? get referrerId => throw _privateConstructorUsedError;
  double get walletBalance => throw _privateConstructorUsedError;
  int get adCredits =>
      throw _privateConstructorUsedError; // Used for the "Watch ad to add customer" logic
// Shop Settings
  @JsonKey(name: 'brand_name')
  String? get brandName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'signature_url')
  String? get signatureUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'accent_color')
  String? get accentColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_tax_rate')
  double get defaultTaxRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_notes')
  String? get invoiceNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'terms_and_conditions')
  String? get termsAndConditions => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String? fullName,
      String? shopName,
      SubscriptionTier subscriptionTier,
      String? referralCode,
      String? referrerId,
      double walletBalance,
      int adCredits,
      @JsonKey(name: 'brand_name') String? brandName,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'signature_url') String? signatureUrl,
      @JsonKey(name: 'accent_color') String? accentColor,
      @JsonKey(name: 'default_tax_rate') double defaultTaxRate,
      @JsonKey(name: 'invoice_notes') String? invoiceNotes,
      @JsonKey(name: 'terms_and_conditions') String? termsAndConditions});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
    Object? shopName = freezed,
    Object? subscriptionTier = null,
    Object? referralCode = freezed,
    Object? referrerId = freezed,
    Object? walletBalance = null,
    Object? adCredits = null,
    Object? brandName = freezed,
    Object? logoUrl = freezed,
    Object? signatureUrl = freezed,
    Object? accentColor = freezed,
    Object? defaultTaxRate = null,
    Object? invoiceNotes = freezed,
    Object? termsAndConditions = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      shopName: freezed == shopName
          ? _value.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionTier: null == subscriptionTier
          ? _value.subscriptionTier
          : subscriptionTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      referrerId: freezed == referrerId
          ? _value.referrerId
          : referrerId // ignore: cast_nullable_to_non_nullable
              as String?,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      adCredits: null == adCredits
          ? _value.adCredits
          : adCredits // ignore: cast_nullable_to_non_nullable
              as int,
      brandName: freezed == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureUrl: freezed == signatureUrl
          ? _value.signatureUrl
          : signatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      accentColor: freezed == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultTaxRate: null == defaultTaxRate
          ? _value.defaultTaxRate
          : defaultTaxRate // ignore: cast_nullable_to_non_nullable
              as double,
      invoiceNotes: freezed == invoiceNotes
          ? _value.invoiceNotes
          : invoiceNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      termsAndConditions: freezed == termsAndConditions
          ? _value.termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? fullName,
      String? shopName,
      SubscriptionTier subscriptionTier,
      String? referralCode,
      String? referrerId,
      double walletBalance,
      int adCredits,
      @JsonKey(name: 'brand_name') String? brandName,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'signature_url') String? signatureUrl,
      @JsonKey(name: 'accent_color') String? accentColor,
      @JsonKey(name: 'default_tax_rate') double defaultTaxRate,
      @JsonKey(name: 'invoice_notes') String? invoiceNotes,
      @JsonKey(name: 'terms_and_conditions') String? termsAndConditions});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = freezed,
    Object? shopName = freezed,
    Object? subscriptionTier = null,
    Object? referralCode = freezed,
    Object? referrerId = freezed,
    Object? walletBalance = null,
    Object? adCredits = null,
    Object? brandName = freezed,
    Object? logoUrl = freezed,
    Object? signatureUrl = freezed,
    Object? accentColor = freezed,
    Object? defaultTaxRate = null,
    Object? invoiceNotes = freezed,
    Object? termsAndConditions = freezed,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      shopName: freezed == shopName
          ? _value.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionTier: null == subscriptionTier
          ? _value.subscriptionTier
          : subscriptionTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      referrerId: freezed == referrerId
          ? _value.referrerId
          : referrerId // ignore: cast_nullable_to_non_nullable
              as String?,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      adCredits: null == adCredits
          ? _value.adCredits
          : adCredits // ignore: cast_nullable_to_non_nullable
              as int,
      brandName: freezed == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureUrl: freezed == signatureUrl
          ? _value.signatureUrl
          : signatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      accentColor: freezed == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultTaxRate: null == defaultTaxRate
          ? _value.defaultTaxRate
          : defaultTaxRate // ignore: cast_nullable_to_non_nullable
              as double,
      invoiceNotes: freezed == invoiceNotes
          ? _value.invoiceNotes
          : invoiceNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      termsAndConditions: freezed == termsAndConditions
          ? _value.termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl(
      {required this.id,
      this.fullName,
      this.shopName,
      this.subscriptionTier = SubscriptionTier.freemium,
      this.referralCode,
      this.referrerId,
      this.walletBalance = 0.0,
      this.adCredits = 0,
      @JsonKey(name: 'brand_name') this.brandName,
      @JsonKey(name: 'logo_url') this.logoUrl,
      @JsonKey(name: 'signature_url') this.signatureUrl,
      @JsonKey(name: 'accent_color') this.accentColor,
      @JsonKey(name: 'default_tax_rate') this.defaultTaxRate = 0.0,
      @JsonKey(name: 'invoice_notes') this.invoiceNotes,
      @JsonKey(name: 'terms_and_conditions') this.termsAndConditions});

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String? fullName;
  @override
  final String? shopName;
  @override
  @JsonKey()
  final SubscriptionTier subscriptionTier;
  @override
  final String? referralCode;
  @override
  final String? referrerId;
  @override
  @JsonKey()
  final double walletBalance;
  @override
  @JsonKey()
  final int adCredits;
// Used for the "Watch ad to add customer" logic
// Shop Settings
  @override
  @JsonKey(name: 'brand_name')
  final String? brandName;
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @override
  @JsonKey(name: 'signature_url')
  final String? signatureUrl;
  @override
  @JsonKey(name: 'accent_color')
  final String? accentColor;
  @override
  @JsonKey(name: 'default_tax_rate')
  final double defaultTaxRate;
  @override
  @JsonKey(name: 'invoice_notes')
  final String? invoiceNotes;
  @override
  @JsonKey(name: 'terms_and_conditions')
  final String? termsAndConditions;

  @override
  String toString() {
    return 'AppUser(id: $id, fullName: $fullName, shopName: $shopName, subscriptionTier: $subscriptionTier, referralCode: $referralCode, referrerId: $referrerId, walletBalance: $walletBalance, adCredits: $adCredits, brandName: $brandName, logoUrl: $logoUrl, signatureUrl: $signatureUrl, accentColor: $accentColor, defaultTaxRate: $defaultTaxRate, invoiceNotes: $invoiceNotes, termsAndConditions: $termsAndConditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.subscriptionTier, subscriptionTier) ||
                other.subscriptionTier == subscriptionTier) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.referrerId, referrerId) ||
                other.referrerId == referrerId) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            (identical(other.adCredits, adCredits) ||
                other.adCredits == adCredits) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.signatureUrl, signatureUrl) ||
                other.signatureUrl == signatureUrl) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            (identical(other.defaultTaxRate, defaultTaxRate) ||
                other.defaultTaxRate == defaultTaxRate) &&
            (identical(other.invoiceNotes, invoiceNotes) ||
                other.invoiceNotes == invoiceNotes) &&
            (identical(other.termsAndConditions, termsAndConditions) ||
                other.termsAndConditions == termsAndConditions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fullName,
      shopName,
      subscriptionTier,
      referralCode,
      referrerId,
      walletBalance,
      adCredits,
      brandName,
      logoUrl,
      signatureUrl,
      accentColor,
      defaultTaxRate,
      invoiceNotes,
      termsAndConditions);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser(
      {required final String id,
      final String? fullName,
      final String? shopName,
      final SubscriptionTier subscriptionTier,
      final String? referralCode,
      final String? referrerId,
      final double walletBalance,
      final int adCredits,
      @JsonKey(name: 'brand_name') final String? brandName,
      @JsonKey(name: 'logo_url') final String? logoUrl,
      @JsonKey(name: 'signature_url') final String? signatureUrl,
      @JsonKey(name: 'accent_color') final String? accentColor,
      @JsonKey(name: 'default_tax_rate') final double defaultTaxRate,
      @JsonKey(name: 'invoice_notes') final String? invoiceNotes,
      @JsonKey(name: 'terms_and_conditions')
      final String? termsAndConditions}) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String? get fullName;
  @override
  String? get shopName;
  @override
  SubscriptionTier get subscriptionTier;
  @override
  String? get referralCode;
  @override
  String? get referrerId;
  @override
  double get walletBalance;
  @override
  int get adCredits; // Used for the "Watch ad to add customer" logic
// Shop Settings
  @override
  @JsonKey(name: 'brand_name')
  String? get brandName;
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;
  @override
  @JsonKey(name: 'signature_url')
  String? get signatureUrl;
  @override
  @JsonKey(name: 'accent_color')
  String? get accentColor;
  @override
  @JsonKey(name: 'default_tax_rate')
  double get defaultTaxRate;
  @override
  @JsonKey(name: 'invoice_notes')
  String? get invoiceNotes;
  @override
  @JsonKey(name: 'terms_and_conditions')
  String? get termsAndConditions;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
