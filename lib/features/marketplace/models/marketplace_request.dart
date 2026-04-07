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
    @JsonKey(name: 'customer_whatsapp') String? customerWhatsapp,
    @JsonKey(readValue: _readCustomerPhoto) String? customerPhotoUrl,
    required String description,
    @JsonKey(name: 'item_quantity') int? itemQuantity,
    @JsonKey(name: 'image_urls') @Default(<String>[]) List<String> imageUrls,
    @JsonKey(name: 'reference_links') @Default(<String>[]) List<String> referenceLinks,
    required String status, // pending, accepted, rejected, completed
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'quote_amount') double? quoteAmount,
    @JsonKey(name: 'quote_currency') @Default('NGN') String quoteCurrency,
    @JsonKey(name: 'quote_message') String? quoteMessage,
    @JsonKey(name: 'quote_status') @Default('pending') String quoteStatus, // pending, accepted, declined, countered
    @JsonKey(name: 'counter_offer_amount') double? counterOfferAmount,
    @JsonKey(name: 'counter_offer_message') String? counterOfferMessage,
    @JsonKey(name: 'counter_offered_at') DateTime? counterOfferedAt,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(readValue: _readCustomerRating) double? customerRating,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MarketplaceRequest;

  factory MarketplaceRequest.fromJson(Map<String, dynamic> json) => _$MarketplaceRequestFromJson(json);
}

Object? _readCustomerRating(Map map, String key) {
  if (map['customer_profile'] is Map) {
    return map['customer_profile']['customer_rating'];
  }
  return null;
}

Object? _readCustomerPhoto(Map map, String key) {
  if (map['customer_profile'] is Map) {
    return map['customer_profile']['photo_url'];
  }
  return null;
}
