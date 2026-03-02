// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityPostImpl _$$CommunityPostImplFromJson(Map<String, dynamic> json) =>
    _$CommunityPostImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postType: json['post_type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CommunityPostImplToJson(_$CommunityPostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'post_type': instance.postType,
      'title': instance.title,
      'content': instance.content,
      'budget': instance.budget,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
