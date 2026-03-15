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
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String?,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MarketplaceRequestImplToJson(
        _$MarketplaceRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tailor_id': instance.tailorId,
      'customer_name': instance.customerName,
      'customer_email': instance.customerEmail,
      'customer_phone': instance.customerPhone,
      'description': instance.description,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
