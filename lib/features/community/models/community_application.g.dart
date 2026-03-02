// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityApplicationImpl _$$CommunityApplicationImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityApplicationImpl(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      applicantId: json['applicant_id'] as String,
      coverLetter: json['cover_letter'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CommunityApplicationImplToJson(
        _$CommunityApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'applicant_id': instance.applicantId,
      'cover_letter': instance.coverLetter,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
