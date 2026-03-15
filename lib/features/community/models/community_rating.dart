import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_rating.freezed.dart';
part 'community_rating.g.dart';

@freezed
class CommunityRating with _$CommunityRating {
  const factory CommunityRating({
    required String id,
    @JsonKey(name: 'rater_id') required String raterId,
    @JsonKey(name: 'ratee_id') required String rateeId,
    @JsonKey(name: 'post_id') String? postId,
    required int rating, // 1 to 5
    String? review,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    // Optional joined data
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? raterName,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? raterLogoUrl,
  }) = _CommunityRating;

  factory CommunityRating.fromJson(Map<String, dynamic> json) => _$CommunityRatingFromJson(json);
}
