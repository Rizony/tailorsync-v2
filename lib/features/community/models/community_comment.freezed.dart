// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommunityComment _$CommunityCommentFromJson(Map<String, dynamic> json) {
  return _CommunityComment.fromJson(json);
}

/// @nodoc
mixin _$CommunityComment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Optional joined data
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorLogoUrl => throw _privateConstructorUsedError;

  /// Serializes this CommunityComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityCommentCopyWith<CommunityComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCommentCopyWith<$Res> {
  factory $CommunityCommentCopyWith(
          CommunityComment value, $Res Function(CommunityComment) then) =
      _$CommunityCommentCopyWithImpl<$Res, CommunityComment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) String? authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? authorLogoUrl});
}

/// @nodoc
class _$CommunityCommentCopyWithImpl<$Res, $Val extends CommunityComment>
    implements $CommunityCommentCopyWith<$Res> {
  _$CommunityCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? authorName = freezed,
    Object? authorLogoUrl = freezed,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityCommentImplCopyWith<$Res>
    implements $CommunityCommentCopyWith<$Res> {
  factory _$$CommunityCommentImplCopyWith(_$CommunityCommentImpl value,
          $Res Function(_$CommunityCommentImpl) then) =
      __$$CommunityCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) String? authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      String? authorLogoUrl});
}

/// @nodoc
class __$$CommunityCommentImplCopyWithImpl<$Res>
    extends _$CommunityCommentCopyWithImpl<$Res, _$CommunityCommentImpl>
    implements _$$CommunityCommentImplCopyWith<$Res> {
  __$$CommunityCommentImplCopyWithImpl(_$CommunityCommentImpl _value,
      $Res Function(_$CommunityCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommunityComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? authorName = freezed,
    Object? authorLogoUrl = freezed,
  }) {
    return _then(_$CommunityCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityCommentImpl implements _CommunityComment {
  const _$CommunityCommentImpl(
      {required this.id,
      @JsonKey(name: 'post_id') required this.postId,
      @JsonKey(name: 'user_id') required this.userId,
      required this.content,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false) this.authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.authorLogoUrl});

  factory _$CommunityCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityCommentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String content;
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
  String toString() {
    return 'CommunityComment(id: $id, postId: $postId, userId: $userId, content: $content, createdAt: $createdAt, authorName: $authorName, authorLogoUrl: $authorLogoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorLogoUrl, authorLogoUrl) ||
                other.authorLogoUrl == authorLogoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, postId, userId, content,
      createdAt, authorName, authorLogoUrl);

  /// Create a copy of CommunityComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityCommentImplCopyWith<_$CommunityCommentImpl> get copyWith =>
      __$$CommunityCommentImplCopyWithImpl<_$CommunityCommentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityCommentImplToJson(
      this,
    );
  }
}

abstract class _CommunityComment implements CommunityComment {
  const factory _CommunityComment(
      {required final String id,
      @JsonKey(name: 'post_id') required final String postId,
      @JsonKey(name: 'user_id') required final String userId,
      required final String content,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? authorName,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final String? authorLogoUrl}) = _$CommunityCommentImpl;

  factory _CommunityComment.fromJson(Map<String, dynamic> json) =
      _$CommunityCommentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get content;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Optional joined data
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorName;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get authorLogoUrl;

  /// Create a copy of CommunityComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityCommentImplCopyWith<_$CommunityCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
