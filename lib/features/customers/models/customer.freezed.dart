// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  @HiveField(0)
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  @HiveField(1)
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  @HiveField(2)
  String? get phoneNumber => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  @HiveField(4)
  String? get photoUrl => throw _privateConstructorUsedError;
  @HiveField(5)
  Map<String, dynamic> get measurements => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @HiveField(6)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  @HiveField(7)
  String? get userId => throw _privateConstructorUsedError;

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call(
      {@HiveField(0) String? id,
      @JsonKey(name: 'full_name') @HiveField(1) String fullName,
      @JsonKey(name: 'phone_number') @HiveField(2) String? phoneNumber,
      @HiveField(3) String? email,
      @JsonKey(name: 'photo_url') @HiveField(4) String? photoUrl,
      @HiveField(5) Map<String, dynamic> measurements,
      @JsonKey(name: 'created_at') @HiveField(6) DateTime? createdAt,
      @JsonKey(name: 'user_id') @HiveField(7) String? userId});
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? fullName = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? photoUrl = freezed,
    Object? measurements = null,
    Object? createdAt = freezed,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      measurements: null == measurements
          ? _value.measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
          _$CustomerImpl value, $Res Function(_$CustomerImpl) then) =
      __$$CustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String? id,
      @JsonKey(name: 'full_name') @HiveField(1) String fullName,
      @JsonKey(name: 'phone_number') @HiveField(2) String? phoneNumber,
      @HiveField(3) String? email,
      @JsonKey(name: 'photo_url') @HiveField(4) String? photoUrl,
      @HiveField(5) Map<String, dynamic> measurements,
      @JsonKey(name: 'created_at') @HiveField(6) DateTime? createdAt,
      @JsonKey(name: 'user_id') @HiveField(7) String? userId});
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
      _$CustomerImpl _value, $Res Function(_$CustomerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? fullName = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? photoUrl = freezed,
    Object? measurements = null,
    Object? createdAt = freezed,
    Object? userId = freezed,
  }) {
    return _then(_$CustomerImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      measurements: null == measurements
          ? _value._measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl(
      {@HiveField(0) this.id,
      @JsonKey(name: 'full_name') @HiveField(1) required this.fullName,
      @JsonKey(name: 'phone_number') @HiveField(2) this.phoneNumber,
      @HiveField(3) this.email,
      @JsonKey(name: 'photo_url') @HiveField(4) this.photoUrl,
      @HiveField(5) final Map<String, dynamic> measurements = const {},
      @JsonKey(name: 'created_at') @HiveField(6) this.createdAt,
      @JsonKey(name: 'user_id') @HiveField(7) this.userId})
      : _measurements = measurements;

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

  @override
  @HiveField(0)
  final String? id;
  @override
  @JsonKey(name: 'full_name')
  @HiveField(1)
  final String fullName;
  @override
  @JsonKey(name: 'phone_number')
  @HiveField(2)
  final String? phoneNumber;
  @override
  @HiveField(3)
  final String? email;
  @override
  @JsonKey(name: 'photo_url')
  @HiveField(4)
  final String? photoUrl;
  final Map<String, dynamic> _measurements;
  @override
  @JsonKey()
  @HiveField(5)
  Map<String, dynamic> get measurements {
    if (_measurements is EqualUnmodifiableMapView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_measurements);
  }

  @override
  @JsonKey(name: 'created_at')
  @HiveField(6)
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'user_id')
  @HiveField(7)
  final String? userId;

  @override
  String toString() {
    return 'Customer(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, email: $email, photoUrl: $photoUrl, measurements: $measurements, createdAt: $createdAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            const DeepCollectionEquality()
                .equals(other._measurements, _measurements) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fullName,
      phoneNumber,
      email,
      photoUrl,
      const DeepCollectionEquality().hash(_measurements),
      createdAt,
      userId);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(
      this,
    );
  }
}

abstract class _Customer implements Customer {
  const factory _Customer(
      {@HiveField(0) final String? id,
      @JsonKey(name: 'full_name') @HiveField(1) required final String fullName,
      @JsonKey(name: 'phone_number') @HiveField(2) final String? phoneNumber,
      @HiveField(3) final String? email,
      @JsonKey(name: 'photo_url') @HiveField(4) final String? photoUrl,
      @HiveField(5) final Map<String, dynamic> measurements,
      @JsonKey(name: 'created_at') @HiveField(6) final DateTime? createdAt,
      @JsonKey(name: 'user_id')
      @HiveField(7)
      final String? userId}) = _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

  @override
  @HiveField(0)
  String? get id;
  @override
  @JsonKey(name: 'full_name')
  @HiveField(1)
  String get fullName;
  @override
  @JsonKey(name: 'phone_number')
  @HiveField(2)
  String? get phoneNumber;
  @override
  @HiveField(3)
  String? get email;
  @override
  @JsonKey(name: 'photo_url')
  @HiveField(4)
  String? get photoUrl;
  @override
  @HiveField(5)
  Map<String, dynamic> get measurements;
  @override
  @JsonKey(name: 'created_at')
  @HiveField(6)
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'user_id')
  @HiveField(7)
  String? get userId;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
