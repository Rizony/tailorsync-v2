// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommunityApplication _$CommunityApplicationFromJson(Map<String, dynamic> json) {
  return _CommunityApplication.fromJson(json);
}

/// @nodoc
mixin _$CommunityApplication {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'applicant_id')
  String get applicantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_letter')
  String get coverLetter => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'pending', 'accepted', 'rejected'
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Optional joined data
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get applicantName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? get applicantRating => throw _privateConstructorUsedError;

  /// Serializes this CommunityApplication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityApplicationCopyWith<CommunityApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityApplicationCopyWith<$Res> {
  factory $CommunityApplicationCopyWith(CommunityApplication value,
          $Res Function(CommunityApplication) then) =
      _$CommunityApplicationCopyWithImpl<$Res, CommunityApplication>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      @JsonKey(name: 'applicant_id') String applicantId,
      @JsonKey(name: 'cover_letter') String coverLetter,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? applicantName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double? applicantRating});
}

/// @nodoc
class _$CommunityApplicationCopyWithImpl<$Res,
        $Val extends CommunityApplication>
    implements $CommunityApplicationCopyWith<$Res> {
  _$CommunityApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? applicantId = null,
    Object? coverLetter = null,
    Object? status = null,
    Object? createdAt = null,
    Object? applicantName = freezed,
    Object? applicantRating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      applicantId: null == applicantId
          ? _value.applicantId
          : applicantId // ignore: cast_nullable_to_non_nullable
              as String,
      coverLetter: null == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      applicantName: freezed == applicantName
          ? _value.applicantName
          : applicantName // ignore: cast_nullable_to_non_nullable
              as String?,
      applicantRating: freezed == applicantRating
          ? _value.applicantRating
          : applicantRating // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityApplicationImplCopyWith<$Res>
    implements $CommunityApplicationCopyWith<$Res> {
  factory _$$CommunityApplicationImplCopyWith(_$CommunityApplicationImpl value,
          $Res Function(_$CommunityApplicationImpl) then) =
      __$$CommunityApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      @JsonKey(name: 'applicant_id') String applicantId,
      @JsonKey(name: 'cover_letter') String coverLetter,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? applicantName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double? applicantRating});
}

/// @nodoc
class __$$CommunityApplicationImplCopyWithImpl<$Res>
    extends _$CommunityApplicationCopyWithImpl<$Res, _$CommunityApplicationImpl>
    implements _$$CommunityApplicationImplCopyWith<$Res> {
  __$$CommunityApplicationImplCopyWithImpl(_$CommunityApplicationImpl _value,
      $Res Function(_$CommunityApplicationImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommunityApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? applicantId = null,
    Object? coverLetter = null,
    Object? status = null,
    Object? createdAt = null,
    Object? applicantName = freezed,
    Object? applicantRating = freezed,
  }) {
    return _then(_$CommunityApplicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      applicantId: null == applicantId
          ? _value.applicantId
          : applicantId // ignore: cast_nullable_to_non_nullable
              as String,
      coverLetter: null == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      applicantName: freezed == applicantName
          ? _value.applicantName
          : applicantName // ignore: cast_nullable_to_non_nullable
              as String?,
      applicantRating: freezed == applicantRating
          ? _value.applicantRating
          : applicantRating // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityApplicationImpl implements _CommunityApplication {
  const _$CommunityApplicationImpl(
      {required this.id,
      @JsonKey(name: 'post_id') required this.postId,
      @JsonKey(name: 'applicant_id') required this.applicantId,
      @JsonKey(name: 'cover_letter') required this.coverLetter,
      this.status = 'pending',
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) this.applicantName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.applicantRating});

  factory _$CommunityApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityApplicationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  @JsonKey(name: 'applicant_id')
  final String applicantId;
  @override
  @JsonKey(name: 'cover_letter')
  final String coverLetter;
  @override
  @JsonKey()
  final String status;
// 'pending', 'accepted', 'rejected'
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? applicantName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? applicantRating;

  @override
  String toString() {
    return 'CommunityApplication(id: $id, postId: $postId, applicantId: $applicantId, coverLetter: $coverLetter, status: $status, createdAt: $createdAt, applicantName: $applicantName, applicantRating: $applicantRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.applicantId, applicantId) ||
                other.applicantId == applicantId) &&
            (identical(other.coverLetter, coverLetter) ||
                other.coverLetter == coverLetter) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.applicantName, applicantName) ||
                other.applicantName == applicantName) &&
            (identical(other.applicantRating, applicantRating) ||
                other.applicantRating == applicantRating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, postId, applicantId,
      coverLetter, status, createdAt, applicantName, applicantRating);

  /// Create a copy of CommunityApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityApplicationImplCopyWith<_$CommunityApplicationImpl>
      get copyWith =>
          __$$CommunityApplicationImplCopyWithImpl<_$CommunityApplicationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityApplicationImplToJson(
      this,
    );
  }
}

abstract class _CommunityApplication implements CommunityApplication {
  const factory _CommunityApplication(
      {required final String id,
      @JsonKey(name: 'post_id') required final String postId,
      @JsonKey(name: 'applicant_id') required final String applicantId,
      @JsonKey(name: 'cover_letter') required final String coverLetter,
      final String status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? applicantName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final double? applicantRating}) = _$CommunityApplicationImpl;

  factory _CommunityApplication.fromJson(Map<String, dynamic> json) =
      _$CommunityApplicationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  @JsonKey(name: 'applicant_id')
  String get applicantId;
  @override
  @JsonKey(name: 'cover_letter')
  String get coverLetter;
  @override
  String get status; // 'pending', 'accepted', 'rejected'
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get applicantName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? get applicantRating;

  /// Create a copy of CommunityApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityApplicationImplCopyWith<_$CommunityApplicationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
