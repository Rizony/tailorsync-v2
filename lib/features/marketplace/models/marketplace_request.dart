import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_request.freezed.dart';
part 'marketplace_request.g.dart';

@freezed
class MarketplaceRequest with _$MarketplaceRequest {
  const factory MarketplaceRequest({
    required String id,
    @JsonKey(name: 'tailor_id') required String tailorId,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_email') required String customerEmail,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    required String description,
    required String status, // pending, accepted, rejected, completed
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MarketplaceRequest;

  factory MarketplaceRequest.fromJson(Map<String, dynamic> json) => _$MarketplaceRequestFromJson(json);
}
