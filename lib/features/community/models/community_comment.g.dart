// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityCommentImpl _$$CommunityCommentImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityCommentImpl(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CommunityCommentImplToJson(
        _$CommunityCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
    };
