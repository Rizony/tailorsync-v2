// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobItemImpl _$$JobItemImplFromJson(Map<String, dynamic> json) =>
    _$JobItemImpl(
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$JobItemImplToJson(_$JobItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
    };

_$JobModelImpl _$$JobModelImplFromJson(Map<String, dynamic> json) =>
    _$JobModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      customerId: json['customer_id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'pending',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => JobItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      assignedTo: json['assigned_to'] as String?,
      isOutsourced: json['is_outsourced'] as bool? ?? false,
      customerName: _readCustomerName(json, 'customerName') as String?,
    );

Map<String, dynamic> _$$JobModelImplToJson(_$JobModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'customer_id': instance.customerId,
      'title': instance.title,
      'price': instance.price,
      'balance_due': instance.balanceDue,
      'due_date': instance.dueDate.toIso8601String(),
      'status': instance.status,
      'images': instance.images,
      'items': instance.items,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'assigned_to': instance.assignedTo,
      'is_outsourced': instance.isOutsourced,
    };
