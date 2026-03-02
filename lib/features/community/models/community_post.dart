import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

@freezed
class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'post_type') required String postType, // 'discussion', 'job_offer', 'collaboration'
    required String title,
    required String content,
    @Default(0.0) double budget,
    @Default('open') String status, // 'open', 'completed', 'closed'
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    // Optional joined data
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? authorName,
    @JsonKey(includeFromJson: false, includeToJson: false)
    double? authorRating,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) => _$CommunityPostFromJson(json);
}
