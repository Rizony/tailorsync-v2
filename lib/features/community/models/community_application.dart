import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_application.freezed.dart';
part 'community_application.g.dart';

@freezed
class CommunityApplication with _$CommunityApplication {
  const factory CommunityApplication({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'applicant_id') required String applicantId,
    @JsonKey(name: 'cover_letter') required String coverLetter,
    @Default('pending') String status, // 'pending', 'accepted', 'rejected'
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    // Optional joined data
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? applicantName,
    @JsonKey(includeFromJson: false, includeToJson: false)
    double? applicantRating,
  }) = _CommunityApplication;

  factory CommunityApplication.fromJson(Map<String, dynamic> json) => _$CommunityApplicationFromJson(json);
}
