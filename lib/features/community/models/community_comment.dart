import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment.freezed.dart';
part 'community_comment.g.dart';

@freezed
class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    // Optional joined data
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? authorName,
  }) = _CommunityComment;

  factory CommunityComment.fromJson(Map<String, dynamic> json) => _$CommunityCommentFromJson(json);
}
