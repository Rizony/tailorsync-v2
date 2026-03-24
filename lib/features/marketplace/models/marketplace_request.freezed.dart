// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MarketplaceRequest _$MarketplaceRequestFromJson(Map<String, dynamic> json) {
  return _MarketplaceRequest.fromJson(json);
}

/// @nodoc
mixin _$MarketplaceRequest {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tailor_id')
  String get tailorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_email')
  String get customerEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_phone')
  String? get customerPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_whatsapp')
  String? get customerWhatsapp => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_quantity')
  int? get itemQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_urls')
  List<String> get imageUrls => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_links')
  List<String> get referenceLinks => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, accepted, rejected, completed
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'quote_amount')
  double? get quoteAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'quote_currency')
  String get quoteCurrency => throw _privateConstructorUsedError;
  @JsonKey(name: 'quote_message')
  String? get quoteMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'quote_status')
  String get quoteStatus =>
      throw _privateConstructorUsedError; // pending, accepted, declined, countered
  @JsonKey(name: 'counter_offer_amount')
  double? get counterOfferAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'counter_offer_message')
  String? get counterOfferMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'counter_offered_at')
  DateTime? get counterOfferedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readCustomerRating)
  double? get customerRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MarketplaceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketplaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketplaceRequestCopyWith<MarketplaceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceRequestCopyWith<$Res> {
  factory $MarketplaceRequestCopyWith(
          MarketplaceRequest value, $Res Function(MarketplaceRequest) then) =
      _$MarketplaceRequestCopyWithImpl<$Res, MarketplaceRequest>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tailor_id') String tailorId,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'customer_name') String customerName,
      @JsonKey(name: 'customer_email') String customerEmail,
      @JsonKey(name: 'customer_phone') String? customerPhone,
      @JsonKey(name: 'customer_whatsapp') String? customerWhatsapp,
      String description,
      @JsonKey(name: 'item_quantity') int? itemQuantity,
      @JsonKey(name: 'image_urls') List<String> imageUrls,
      @JsonKey(name: 'reference_links') List<String> referenceLinks,
      String status,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'quote_amount') double? quoteAmount,
      @JsonKey(name: 'quote_currency') String quoteCurrency,
      @JsonKey(name: 'quote_message') String? quoteMessage,
      @JsonKey(name: 'quote_status') String quoteStatus,
      @JsonKey(name: 'counter_offer_amount') double? counterOfferAmount,
      @JsonKey(name: 'counter_offer_message') String? counterOfferMessage,
      @JsonKey(name: 'counter_offered_at') DateTime? counterOfferedAt,
      @JsonKey(name: 'order_id') String? orderId,
      @JsonKey(readValue: _readCustomerRating) double? customerRating,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$MarketplaceRequestCopyWithImpl<$Res, $Val extends MarketplaceRequest>
    implements $MarketplaceRequestCopyWith<$Res> {
  _$MarketplaceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tailorId = null,
    Object? customerId = freezed,
    Object? customerName = null,
    Object? customerEmail = null,
    Object? customerPhone = freezed,
    Object? customerWhatsapp = freezed,
    Object? description = null,
    Object? itemQuantity = freezed,
    Object? imageUrls = null,
    Object? referenceLinks = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? quoteAmount = freezed,
    Object? quoteCurrency = null,
    Object? quoteMessage = freezed,
    Object? quoteStatus = null,
    Object? counterOfferAmount = freezed,
    Object? counterOfferMessage = freezed,
    Object? counterOfferedAt = freezed,
    Object? orderId = freezed,
    Object? customerRating = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tailorId: null == tailorId
          ? _value.tailorId
          : tailorId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerEmail: null == customerEmail
          ? _value.customerEmail
          : customerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      customerWhatsapp: freezed == customerWhatsapp
          ? _value.customerWhatsapp
          : customerWhatsapp // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      itemQuantity: freezed == itemQuantity
          ? _value.itemQuantity
          : itemQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      referenceLinks: null == referenceLinks
          ? _value.referenceLinks
          : referenceLinks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      quoteAmount: freezed == quoteAmount
          ? _value.quoteAmount
          : quoteAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      quoteCurrency: null == quoteCurrency
          ? _value.quoteCurrency
          : quoteCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      quoteMessage: freezed == quoteMessage
          ? _value.quoteMessage
          : quoteMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      quoteStatus: null == quoteStatus
          ? _value.quoteStatus
          : quoteStatus // ignore: cast_nullable_to_non_nullable
              as String,
      counterOfferAmount: freezed == counterOfferAmount
          ? _value.counterOfferAmount
          : counterOfferAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      counterOfferMessage: freezed == counterOfferMessage
          ? _value.counterOfferMessage
          : counterOfferMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      counterOfferedAt: freezed == counterOfferedAt
          ? _value.counterOfferedAt
          : counterOfferedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerRating: freezed == customerRating
          ? _value.customerRating
          : customerRating // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketplaceRequestImplCopyWith<$Res>
    implements $MarketplaceRequestCopyWith<$Res> {
  factory _$$MarketplaceRequestImplCopyWith(_$MarketplaceRequestImpl value,
          $Res Function(_$MarketplaceRequestImpl) then) =
      __$$MarketplaceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tailor_id') String tailorId,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'customer_name') String customerName,
      @JsonKey(name: 'customer_email') String customerEmail,
      @JsonKey(name: 'customer_phone') String? customerPhone,
      @JsonKey(name: 'customer_whatsapp') String? customerWhatsapp,
      String description,
      @JsonKey(name: 'item_quantity') int? itemQuantity,
      @JsonKey(name: 'image_urls') List<String> imageUrls,
      @JsonKey(name: 'reference_links') List<String> referenceLinks,
      String status,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'quote_amount') double? quoteAmount,
      @JsonKey(name: 'quote_currency') String quoteCurrency,
      @JsonKey(name: 'quote_message') String? quoteMessage,
      @JsonKey(name: 'quote_status') String quoteStatus,
      @JsonKey(name: 'counter_offer_amount') double? counterOfferAmount,
      @JsonKey(name: 'counter_offer_message') String? counterOfferMessage,
      @JsonKey(name: 'counter_offered_at') DateTime? counterOfferedAt,
      @JsonKey(name: 'order_id') String? orderId,
      @JsonKey(readValue: _readCustomerRating) double? customerRating,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$MarketplaceRequestImplCopyWithImpl<$Res>
    extends _$MarketplaceRequestCopyWithImpl<$Res, _$MarketplaceRequestImpl>
    implements _$$MarketplaceRequestImplCopyWith<$Res> {
  __$$MarketplaceRequestImplCopyWithImpl(_$MarketplaceRequestImpl _value,
      $Res Function(_$MarketplaceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tailorId = null,
    Object? customerId = freezed,
    Object? customerName = null,
    Object? customerEmail = null,
    Object? customerPhone = freezed,
    Object? customerWhatsapp = freezed,
    Object? description = null,
    Object? itemQuantity = freezed,
    Object? imageUrls = null,
    Object? referenceLinks = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? quoteAmount = freezed,
    Object? quoteCurrency = null,
    Object? quoteMessage = freezed,
    Object? quoteStatus = null,
    Object? counterOfferAmount = freezed,
    Object? counterOfferMessage = freezed,
    Object? counterOfferedAt = freezed,
    Object? orderId = freezed,
    Object? customerRating = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$MarketplaceRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tailorId: null == tailorId
          ? _value.tailorId
          : tailorId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerEmail: null == customerEmail
          ? _value.customerEmail
          : customerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      customerWhatsapp: freezed == customerWhatsapp
          ? _value.customerWhatsapp
          : customerWhatsapp // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      itemQuantity: freezed == itemQuantity
          ? _value.itemQuantity
          : itemQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      referenceLinks: null == referenceLinks
          ? _value._referenceLinks
          : referenceLinks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      quoteAmount: freezed == quoteAmount
          ? _value.quoteAmount
          : quoteAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      quoteCurrency: null == quoteCurrency
          ? _value.quoteCurrency
          : quoteCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      quoteMessage: freezed == quoteMessage
          ? _value.quoteMessage
          : quoteMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      quoteStatus: null == quoteStatus
          ? _value.quoteStatus
          : quoteStatus // ignore: cast_nullable_to_non_nullable
              as String,
      counterOfferAmount: freezed == counterOfferAmount
          ? _value.counterOfferAmount
          : counterOfferAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      counterOfferMessage: freezed == counterOfferMessage
          ? _value.counterOfferMessage
          : counterOfferMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      counterOfferedAt: freezed == counterOfferedAt
          ? _value.counterOfferedAt
          : counterOfferedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerRating: freezed == customerRating
          ? _value.customerRating
          : customerRating // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketplaceRequestImpl implements _MarketplaceRequest {
  const _$MarketplaceRequestImpl(
      {required this.id,
      @JsonKey(name: 'tailor_id') required this.tailorId,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'customer_name') required this.customerName,
      @JsonKey(name: 'customer_email') required this.customerEmail,
      @JsonKey(name: 'customer_phone') this.customerPhone,
      @JsonKey(name: 'customer_whatsapp') this.customerWhatsapp,
      required this.description,
      @JsonKey(name: 'item_quantity') this.itemQuantity,
      @JsonKey(name: 'image_urls')
      final List<String> imageUrls = const <String>[],
      @JsonKey(name: 'reference_links')
      final List<String> referenceLinks = const <String>[],
      required this.status,
      @JsonKey(name: 'payment_status') this.paymentStatus = 'unpaid',
      @JsonKey(name: 'quote_amount') this.quoteAmount,
      @JsonKey(name: 'quote_currency') this.quoteCurrency = 'NGN',
      @JsonKey(name: 'quote_message') this.quoteMessage,
      @JsonKey(name: 'quote_status') this.quoteStatus = 'pending',
      @JsonKey(name: 'counter_offer_amount') this.counterOfferAmount,
      @JsonKey(name: 'counter_offer_message') this.counterOfferMessage,
      @JsonKey(name: 'counter_offered_at') this.counterOfferedAt,
      @JsonKey(name: 'order_id') this.orderId,
      @JsonKey(readValue: _readCustomerRating) this.customerRating,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _imageUrls = imageUrls,
        _referenceLinks = referenceLinks;

  factory _$MarketplaceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketplaceRequestImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tailor_id')
  final String tailorId;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'customer_email')
  final String customerEmail;
  @override
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  @override
  @JsonKey(name: 'customer_whatsapp')
  final String? customerWhatsapp;
  @override
  final String description;
  @override
  @JsonKey(name: 'item_quantity')
  final int? itemQuantity;
  final List<String> _imageUrls;
  @override
  @JsonKey(name: 'image_urls')
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  final List<String> _referenceLinks;
  @override
  @JsonKey(name: 'reference_links')
  List<String> get referenceLinks {
    if (_referenceLinks is EqualUnmodifiableListView) return _referenceLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_referenceLinks);
  }

  @override
  final String status;
// pending, accepted, rejected, completed
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @override
  @JsonKey(name: 'quote_amount')
  final double? quoteAmount;
  @override
  @JsonKey(name: 'quote_currency')
  final String quoteCurrency;
  @override
  @JsonKey(name: 'quote_message')
  final String? quoteMessage;
  @override
  @JsonKey(name: 'quote_status')
  final String quoteStatus;
// pending, accepted, declined, countered
  @override
  @JsonKey(name: 'counter_offer_amount')
  final double? counterOfferAmount;
  @override
  @JsonKey(name: 'counter_offer_message')
  final String? counterOfferMessage;
  @override
  @JsonKey(name: 'counter_offered_at')
  final DateTime? counterOfferedAt;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(readValue: _readCustomerRating)
  final double? customerRating;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'MarketplaceRequest(id: $id, tailorId: $tailorId, customerId: $customerId, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, customerWhatsapp: $customerWhatsapp, description: $description, itemQuantity: $itemQuantity, imageUrls: $imageUrls, referenceLinks: $referenceLinks, status: $status, paymentStatus: $paymentStatus, quoteAmount: $quoteAmount, quoteCurrency: $quoteCurrency, quoteMessage: $quoteMessage, quoteStatus: $quoteStatus, counterOfferAmount: $counterOfferAmount, counterOfferMessage: $counterOfferMessage, counterOfferedAt: $counterOfferedAt, orderId: $orderId, customerRating: $customerRating, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tailorId, tailorId) ||
                other.tailorId == tailorId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerWhatsapp, customerWhatsapp) ||
                other.customerWhatsapp == customerWhatsapp) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.itemQuantity, itemQuantity) ||
                other.itemQuantity == itemQuantity) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality()
                .equals(other._referenceLinks, _referenceLinks) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.quoteAmount, quoteAmount) ||
                other.quoteAmount == quoteAmount) &&
            (identical(other.quoteCurrency, quoteCurrency) ||
                other.quoteCurrency == quoteCurrency) &&
            (identical(other.quoteMessage, quoteMessage) ||
                other.quoteMessage == quoteMessage) &&
            (identical(other.quoteStatus, quoteStatus) ||
                other.quoteStatus == quoteStatus) &&
            (identical(other.counterOfferAmount, counterOfferAmount) ||
                other.counterOfferAmount == counterOfferAmount) &&
            (identical(other.counterOfferMessage, counterOfferMessage) ||
                other.counterOfferMessage == counterOfferMessage) &&
            (identical(other.counterOfferedAt, counterOfferedAt) ||
                other.counterOfferedAt == counterOfferedAt) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.customerRating, customerRating) ||
                other.customerRating == customerRating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tailorId,
        customerId,
        customerName,
        customerEmail,
        customerPhone,
        customerWhatsapp,
        description,
        itemQuantity,
        const DeepCollectionEquality().hash(_imageUrls),
        const DeepCollectionEquality().hash(_referenceLinks),
        status,
        paymentStatus,
        quoteAmount,
        quoteCurrency,
        quoteMessage,
        quoteStatus,
        counterOfferAmount,
        counterOfferMessage,
        counterOfferedAt,
        orderId,
        customerRating,
        createdAt
      ]);

  /// Create a copy of MarketplaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceRequestImplCopyWith<_$MarketplaceRequestImpl> get copyWith =>
      __$$MarketplaceRequestImplCopyWithImpl<_$MarketplaceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketplaceRequestImplToJson(
      this,
    );
  }
}

abstract class _MarketplaceRequest implements MarketplaceRequest {
  const factory _MarketplaceRequest(
      {required final String id,
      @JsonKey(name: 'tailor_id') required final String tailorId,
      @JsonKey(name: 'customer_id') final String? customerId,
      @JsonKey(name: 'customer_name') required final String customerName,
      @JsonKey(name: 'customer_email') required final String customerEmail,
      @JsonKey(name: 'customer_phone') final String? customerPhone,
      @JsonKey(name: 'customer_whatsapp') final String? customerWhatsapp,
      required final String description,
      @JsonKey(name: 'item_quantity') final int? itemQuantity,
      @JsonKey(name: 'image_urls') final List<String> imageUrls,
      @JsonKey(name: 'reference_links') final List<String> referenceLinks,
      required final String status,
      @JsonKey(name: 'payment_status') final String paymentStatus,
      @JsonKey(name: 'quote_amount') final double? quoteAmount,
      @JsonKey(name: 'quote_currency') final String quoteCurrency,
      @JsonKey(name: 'quote_message') final String? quoteMessage,
      @JsonKey(name: 'quote_status') final String quoteStatus,
      @JsonKey(name: 'counter_offer_amount') final double? counterOfferAmount,
      @JsonKey(name: 'counter_offer_message') final String? counterOfferMessage,
      @JsonKey(name: 'counter_offered_at') final DateTime? counterOfferedAt,
      @JsonKey(name: 'order_id') final String? orderId,
      @JsonKey(readValue: _readCustomerRating) final double? customerRating,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$MarketplaceRequestImpl;

  factory _MarketplaceRequest.fromJson(Map<String, dynamic> json) =
      _$MarketplaceRequestImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tailor_id')
  String get tailorId;
  @override
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'customer_email')
  String get customerEmail;
  @override
  @JsonKey(name: 'customer_phone')
  String? get customerPhone;
  @override
  @JsonKey(name: 'customer_whatsapp')
  String? get customerWhatsapp;
  @override
  String get description;
  @override
  @JsonKey(name: 'item_quantity')
  int? get itemQuantity;
  @override
  @JsonKey(name: 'image_urls')
  List<String> get imageUrls;
  @override
  @JsonKey(name: 'reference_links')
  List<String> get referenceLinks;
  @override
  String get status; // pending, accepted, rejected, completed
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override
  @JsonKey(name: 'quote_amount')
  double? get quoteAmount;
  @override
  @JsonKey(name: 'quote_currency')
  String get quoteCurrency;
  @override
  @JsonKey(name: 'quote_message')
  String? get quoteMessage;
  @override
  @JsonKey(name: 'quote_status')
  String get quoteStatus; // pending, accepted, declined, countered
  @override
  @JsonKey(name: 'counter_offer_amount')
  double? get counterOfferAmount;
  @override
  @JsonKey(name: 'counter_offer_message')
  String? get counterOfferMessage;
  @override
  @JsonKey(name: 'counter_offered_at')
  DateTime? get counterOfferedAt;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(readValue: _readCustomerRating)
  double? get customerRating;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of MarketplaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceRequestImplCopyWith<_$MarketplaceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
