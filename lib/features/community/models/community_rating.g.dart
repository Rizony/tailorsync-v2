// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityRatingImpl _$$CommunityRatingImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityRatingImpl(
      id: json['id'] as String,
      raterId: json['rater_id'] as String,
      rateeId: json['ratee_id'] as String,
      postId: json['post_id'] as String?,
      rating: (json['rating'] as num).toInt(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CommunityRatingImplToJson(
        _$CommunityRatingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rater_id': instance.raterId,
      'ratee_id': instance.rateeId,
      'post_id': instance.postId,
      'rating': instance.rating,
      'review': instance.review,
      'created_at': instance.createdAt.toIso8601String(),
    };
