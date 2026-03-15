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
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_email')
  String get customerEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_phone')
  String? get customerPhone => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, accepted, rejected, completed
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
      @JsonKey(name: 'customer_name') String customerName,
      @JsonKey(name: 'customer_email') String customerEmail,
      @JsonKey(name: 'customer_phone') String? customerPhone,
      String description,
      String status,
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
    Object? customerName = null,
    Object? customerEmail = null,
    Object? customerPhone = freezed,
    Object? description = null,
    Object? status = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
      @JsonKey(name: 'customer_name') String customerName,
      @JsonKey(name: 'customer_email') String customerEmail,
      @JsonKey(name: 'customer_phone') String? customerPhone,
      String description,
      String status,
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
    Object? customerName = null,
    Object? customerEmail = null,
    Object? customerPhone = freezed,
    Object? description = null,
    Object? status = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
      @JsonKey(name: 'customer_name') required this.customerName,
      @JsonKey(name: 'customer_email') required this.customerEmail,
      @JsonKey(name: 'customer_phone') this.customerPhone,
      required this.description,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$MarketplaceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketplaceRequestImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tailor_id')
  final String tailorId;
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
  final String description;
  @override
  final String status;
// pending, accepted, rejected, completed
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'MarketplaceRequest(id: $id, tailorId: $tailorId, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, description: $description, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tailorId, tailorId) ||
                other.tailorId == tailorId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tailorId, customerName,
      customerEmail, customerPhone, description, status, createdAt);

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
          @JsonKey(name: 'customer_name') required final String customerName,
          @JsonKey(name: 'customer_email') required final String customerEmail,
          @JsonKey(name: 'customer_phone') final String? customerPhone,
          required final String description,
          required final String status,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$MarketplaceRequestImpl;

  factory _MarketplaceRequest.fromJson(Map<String, dynamic> json) =
      _$MarketplaceRequestImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tailor_id')
  String get tailorId;
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
  String get description;
  @override
  String get status; // pending, accepted, rejected, completed
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
