// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_rating.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommunityRating _$CommunityRatingFromJson(Map<String, dynamic> json) {
  return _CommunityRating.fromJson(json);
}

/// @nodoc
mixin _$CommunityRating {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'rater_id')
  String get raterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ratee_id')
  String get rateeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String? get postId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError; // 1 to 5
  String? get review => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Optional joined data
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get raterName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get raterLogoUrl => throw _privateConstructorUsedError;

  /// Serializes this CommunityRating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityRatingCopyWith<CommunityRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityRatingCopyWith<$Res> {
  factory $CommunityRatingCopyWith(
          CommunityRating value, $Res Function(CommunityRating) then) =
      _$CommunityRatingCopyWithImpl<$Res, CommunityRating>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'rater_id') String raterId,
      @JsonKey(name: 'ratee_id') String rateeId,
      @JsonKey(name: 'post_id') String? postId,
      int rating,
      String? review,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) String? raterName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? raterLogoUrl});
}

/// @nodoc
class _$CommunityRatingCopyWithImpl<$Res, $Val extends CommunityRating>
    implements $CommunityRatingCopyWith<$Res> {
  _$CommunityRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raterId = null,
    Object? rateeId = null,
    Object? postId = freezed,
    Object? rating = null,
    Object? review = freezed,
    Object? createdAt = null,
    Object? raterName = freezed,
    Object? raterLogoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      raterId: null == raterId
          ? _value.raterId
          : raterId // ignore: cast_nullable_to_non_nullable
              as String,
      rateeId: null == rateeId
          ? _value.rateeId
          : rateeId // ignore: cast_nullable_to_non_nullable
              as String,
      postId: freezed == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      raterName: freezed == raterName
          ? _value.raterName
          : raterName // ignore: cast_nullable_to_non_nullable
              as String?,
      raterLogoUrl: freezed == raterLogoUrl
          ? _value.raterLogoUrl
          : raterLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityRatingImplCopyWith<$Res>
    implements $CommunityRatingCopyWith<$Res> {
  factory _$$CommunityRatingImplCopyWith(_$CommunityRatingImpl value,
          $Res Function(_$CommunityRatingImpl) then) =
      __$$CommunityRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'rater_id') String raterId,
      @JsonKey(name: 'ratee_id') String rateeId,
      @JsonKey(name: 'post_id') String? postId,
      int rating,
      String? review,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) String? raterName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? raterLogoUrl});
}

/// @nodoc
class __$$CommunityRatingImplCopyWithImpl<$Res>
    extends _$CommunityRatingCopyWithImpl<$Res, _$CommunityRatingImpl>
    implements _$$CommunityRatingImplCopyWith<$Res> {
  __$$CommunityRatingImplCopyWithImpl(
      _$CommunityRatingImpl _value, $Res Function(_$CommunityRatingImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommunityRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raterId = null,
    Object? rateeId = null,
    Object? postId = freezed,
    Object? rating = null,
    Object? review = freezed,
    Object? createdAt = null,
    Object? raterName = freezed,
    Object? raterLogoUrl = freezed,
  }) {
    return _then(_$CommunityRatingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      raterId: null == raterId
          ? _value.raterId
          : raterId // ignore: cast_nullable_to_non_nullable
              as String,
      rateeId: null == rateeId
          ? _value.rateeId
          : rateeId // ignore: cast_nullable_to_non_nullable
              as String,
      postId: freezed == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      raterName: freezed == raterName
          ? _value.raterName
          : raterName // ignore: cast_nullable_to_non_nullable
              as String?,
      raterLogoUrl: freezed == raterLogoUrl
          ? _value.raterLogoUrl
          : raterLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityRatingImpl implements _CommunityRating {
  const _$CommunityRatingImpl(
      {required this.id,
      @JsonKey(name: 'rater_id') required this.raterId,
      @JsonKey(name: 'ratee_id') required this.rateeId,
      @JsonKey(name: 'post_id') this.postId,
      required this.rating,
      this.review,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) this.raterName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.raterLogoUrl});

  factory _$CommunityRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityRatingImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'rater_id')
  final String raterId;
  @override
  @JsonKey(name: 'ratee_id')
  final String rateeId;
  @override
  @JsonKey(name: 'post_id')
  final String? postId;
  @override
  final int rating;
// 1 to 5
  @override
  final String? review;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? raterName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? raterLogoUrl;

  @override
  String toString() {
    return 'CommunityRating(id: $id, raterId: $raterId, rateeId: $rateeId, postId: $postId, rating: $rating, review: $review, createdAt: $createdAt, raterName: $raterName, raterLogoUrl: $raterLogoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityRatingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.raterId, raterId) || other.raterId == raterId) &&
            (identical(other.rateeId, rateeId) || other.rateeId == rateeId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.review, review) || other.review == review) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.raterName, raterName) ||
                other.raterName == raterName) &&
            (identical(other.raterLogoUrl, raterLogoUrl) ||
                other.raterLogoUrl == raterLogoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, raterId, rateeId, postId,
      rating, review, createdAt, raterName, raterLogoUrl);

  /// Create a copy of CommunityRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityRatingImplCopyWith<_$CommunityRatingImpl> get copyWith =>
      __$$CommunityRatingImplCopyWithImpl<_$CommunityRatingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityRatingImplToJson(
      this,
    );
  }
}

abstract class _CommunityRating implements CommunityRating {
  const factory _CommunityRating(
      {required final String id,
      @JsonKey(name: 'rater_id') required final String raterId,
      @JsonKey(name: 'ratee_id') required final String rateeId,
      @JsonKey(name: 'post_id') final String? postId,
      required final int rating,
      final String? review,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? raterName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? raterLogoUrl}) = _$CommunityRatingImpl;

  factory _CommunityRating.fromJson(Map<String, dynamic> json) =
      _$CommunityRatingImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'rater_id')
  String get raterId;
  @override
  @JsonKey(name: 'ratee_id')
  String get rateeId;
  @override
  @JsonKey(name: 'post_id')
  String? get postId;
  @override
  int get rating; // 1 to 5
  @override
  String? get review;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get raterName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get raterLogoUrl;

  /// Create a copy of CommunityRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityRatingImplCopyWith<_$CommunityRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
