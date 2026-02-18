// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as String?,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      measurements: json['measurements'] as Map<String, dynamic>? ?? const {},
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'measurements': instance.measurements,
      'created_at': instance.createdAt?.toIso8601String(),
      'user_id': instance.userId,
    };
