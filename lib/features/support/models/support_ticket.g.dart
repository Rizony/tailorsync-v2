// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupportTicketImpl _$$SupportTicketImplFromJson(Map<String, dynamic> json) =>
    _$SupportTicketImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SupportTicketImplToJson(_$SupportTicketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'subject': instance.subject,
      'status': instance.status,
      'priority': instance.priority,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$SupportMessageImpl _$$SupportMessageImplFromJson(Map<String, dynamic> json) =>
    _$SupportMessageImpl(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      isAdminReply: json['is_admin_reply'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SupportMessageImplToJson(
        _$SupportMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_id': instance.ticketId,
      'sender_id': instance.senderId,
      'message': instance.message,
      'is_admin_reply': instance.isAdminReply,
      'created_at': instance.createdAt.toIso8601String(),
    };
