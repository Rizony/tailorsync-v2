import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/support_ticket.dart';

final supportRepositoryProvider = Provider((ref) => SupportRepository());

class SupportRepository {
  final _supabase = Supabase.instance.client;

  Future<List<SupportTicket>> fetchMyTickets() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final response = await _supabase
        .from('support_tickets')
        .select()
        .eq('user_id', uid)
        .order('updated_at', ascending: false);
    
    return (response as List).map((json) => SupportTicket.fromJson(json)).toList();
  }

  Future<SupportTicket> createTicket(String subject, String initialMessage) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    // 1. Create ticket
    final ticketResponse = await _supabase.from('support_tickets').insert({
      'user_id': uid,
      'subject': subject,
      'status': SupportTicket.statusOpen,
    }).select().single();

    final ticket = SupportTicket.fromJson(ticketResponse);

    // 2. Create initial message
    await _supabase.from('support_messages').insert({
      'ticket_id': ticket.id,
      'sender_id': uid,
      'message': initialMessage,
      'is_admin_reply': false,
    });

    return ticket;
  }

  Future<List<SupportMessage>> fetchMessages(String ticketId) async {
    final response = await _supabase
        .from('support_messages')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    
    return (response as List).map((json) => SupportMessage.fromJson(json)).toList();
  }

  Future<void> sendMessage(String ticketId, String message) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    await _supabase.from('support_messages').insert({
      'ticket_id': ticketId,
      'sender_id': uid,
      'message': message,
      'is_admin_reply': false,
    });

    // Update ticket updated_at
    await _supabase.from('support_tickets').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // Admin and Real-time methods can be added here
  Stream<List<SupportMessage>> subscribeToMessages(String ticketId) {
    return _supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true)
        .map((list) => list.map((json) => SupportMessage.fromJson(json)).toList());
  }
}
