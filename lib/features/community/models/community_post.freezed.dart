// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommunityPost _$CommunityPostFromJson(Map<String, dynamic> json) {
  return _CommunityPost.fromJson(json);
}

/// @nodoc
mixin _$CommunityPost {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_type')
  String get postType =>
      throw _privateConstructorUsedError; // 'discussion', 'job_offer', 'collaboration'
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  double get budget => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'open', 'completed', 'closed'
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Optional joined data
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorLogoUrl => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? get authorRating => throw _privateConstructorUsedError;

  /// Serializes this CommunityPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostCopyWith<CommunityPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostCopyWith<$Res> {
  factory $CommunityPostCopyWith(
          CommunityPost value, $Res Function(CommunityPost) then) =
      _$CommunityPostCopyWithImpl<$Res, CommunityPost>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'post_type') String postType,
      String title,
      String content,
      double budget,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) String? authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? authorLogoUrl,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double? authorRating});
}

/// @nodoc
class _$CommunityPostCopyWithImpl<$Res, $Val extends CommunityPost>
    implements $CommunityPostCopyWith<$Res> {
  _$CommunityPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? postType = null,
    Object? title = null,
    Object? content = null,
    Object? budget = null,
    Object? status = null,
    Object? createdAt = null,
    Object? authorName = freezed,
    Object? authorLogoUrl = freezed,
    Object? authorRating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      postType: null == postType
          ? _value.postType
          : postType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorLogoUrl: freezed == authorLogoUrl
          ? _value.authorLogoUrl
          : authorLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorRating: freezed == authorRating
          ? _value.authorRating
          : authorRating // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityPostImplCopyWith<$Res>
    implements $CommunityPostCopyWith<$Res> {
  factory _$$CommunityPostImplCopyWith(
          _$CommunityPostImpl value, $Res Function(_$CommunityPostImpl) then) =
      __$$CommunityPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'post_type') String postType,
      String title,
      String content,
      double budget,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) String? authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? authorLogoUrl,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double? authorRating});
}

/// @nodoc
class __$$CommunityPostImplCopyWithImpl<$Res>
    extends _$CommunityPostCopyWithImpl<$Res, _$CommunityPostImpl>
    implements _$$CommunityPostImplCopyWith<$Res> {
  __$$CommunityPostImplCopyWithImpl(
      _$CommunityPostImpl _value, $Res Function(_$CommunityPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommunityPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? postType = null,
    Object? title = null,
    Object? content = null,
    Object? budget = null,
    Object? status = null,
    Object? createdAt = null,
    Object? authorName = freezed,
    Object? authorLogoUrl = freezed,
    Object? authorRating = freezed,
  }) {
    return _then(_$CommunityPostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      postType: null == postType
          ? _value.postType
          : postType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorLogoUrl: freezed == authorLogoUrl
          ? _value.authorLogoUrl
          : authorLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorRating: freezed == authorRating
          ? _value.authorRating
          : authorRating // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostImpl implements _CommunityPost {
  const _$CommunityPostImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'post_type') required this.postType,
      required this.title,
      required this.content,
      this.budget = 0.0,
      this.status = 'open',
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) this.authorName,
      @JsonKey(includeFromJson: false, includeToJson: false) this.authorLogoUrl,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.authorRating});

  factory _$CommunityPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityPostImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'post_type')
  final String postType;
// 'discussion', 'job_offer', 'collaboration'
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey()
  final double budget;
  @override
  @JsonKey()
  final String status;
// 'open', 'completed', 'closed'
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorLogoUrl;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? authorRating;

  @override
  String toString() {
    return 'CommunityPost(id: $id, userId: $userId, postType: $postType, title: $title, content: $content, budget: $budget, status: $status, createdAt: $createdAt, authorName: $authorName, authorLogoUrl: $authorLogoUrl, authorRating: $authorRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.postType, postType) ||
                other.postType == postType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorLogoUrl, authorLogoUrl) ||
                other.authorLogoUrl == authorLogoUrl) &&
            (identical(other.authorRating, authorRating) ||
                other.authorRating == authorRating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      postType,
      title,
      content,
      budget,
      status,
      createdAt,
      authorName,
      authorLogoUrl,
      authorRating);

  /// Create a copy of CommunityPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostImplCopyWith<_$CommunityPostImpl> get copyWith =>
      __$$CommunityPostImplCopyWithImpl<_$CommunityPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostImplToJson(
      this,
    );
  }
}

abstract class _CommunityPost implements CommunityPost {
  const factory _CommunityPost(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'post_type') required final String postType,
      required final String title,
      required final String content,
      final double budget,
      final String status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? authorLogoUrl,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final double? authorRating}) = _$CommunityPostImpl;

  factory _CommunityPost.fromJson(Map<String, dynamic> json) =
      _$CommunityPostImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'post_type')
  String get postType; // 'discussion', 'job_offer', 'collaboration'
  @override
  String get title;
  @override
  String get content;
  @override
  double get budget;
  @override
  String get status; // 'open', 'completed', 'closed'
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorLogoUrl;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? get authorRating;

  /// Create a copy of CommunityPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostImplCopyWith<_$CommunityPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
