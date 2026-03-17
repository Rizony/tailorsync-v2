import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_request.freezed.dart';
part 'marketplace_request.g.dart';

@freezed
class MarketplaceRequest with _$MarketplaceRequest {
  const factory MarketplaceRequest({
    required String id,
    @JsonKey(name: 'tailor_id') required String tailorId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_email') required String customerEmail,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    required String description,
    @JsonKey(name: 'item_quantity') int? itemQuantity,
    @JsonKey(name: 'image_urls') @Default(<String>[]) List<String> imageUrls,
    @JsonKey(name: 'reference_links') @Default(<String>[]) List<String> referenceLinks,
    required String status, // pending, accepted, rejected, completed
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'quote_amount') double? quoteAmount,
    @JsonKey(name: 'quote_currency') @Default('NGN') String quoteCurrency,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MarketplaceRequest;

  factory MarketplaceRequest.fromJson(Map<String, dynamic> json) => _$MarketplaceRequestFromJson(json);
}
