// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketplaceRequestImpl _$$MarketplaceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$MarketplaceRequestImpl(
      id: json['id'] as String,
      tailorId: json['tailor_id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String?,
      description: json['description'] as String,
      itemQuantity: (json['item_quantity'] as num?)?.toInt(),
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      referenceLinks: (json['reference_links'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      quoteAmount: (json['quote_amount'] as num?)?.toDouble(),
      quoteCurrency: json['quote_currency'] as String? ?? 'NGN',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MarketplaceRequestImplToJson(
        _$MarketplaceRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tailor_id': instance.tailorId,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'customer_email': instance.customerEmail,
      'customer_phone': instance.customerPhone,
      'description': instance.description,
      'item_quantity': instance.itemQuantity,
      'image_urls': instance.imageUrls,
      'reference_links': instance.referenceLinks,
      'status': instance.status,
      'payment_status': instance.paymentStatus,
      'quote_amount': instance.quoteAmount,
      'quote_currency': instance.quoteCurrency,
      'created_at': instance.createdAt.toIso8601String(),
    };
