import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_ticket.freezed.dart';
part 'support_ticket.g.dart';

@freezed
class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String subject,
    required String status,
    @JsonKey(name: 'priority') @Default('medium') String priority,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, dynamic> json) => _$SupportTicketFromJson(json);
  
  static const statusOpen = 'open';
  static const statusInProgress = 'in_progress';
  static const statusResolved = 'resolved';
  static const statusClosed = 'closed';
}

@freezed
class SupportMessage with _$SupportMessage {
  const factory SupportMessage({
    required String id,
    @JsonKey(name: 'ticket_id') required String ticketId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String message,
    @JsonKey(name: 'is_admin_reply') required bool isAdminReply,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SupportMessage;

  factory SupportMessage.fromJson(Map<String, dynamic> json) => _$SupportMessageFromJson(json);
}
