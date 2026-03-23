import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/support_ticket.dart';
import '../repositories/support_repository.dart';

final myTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  return ref.watch(supportRepositoryProvider).fetchMyTickets();
});

final ticketMessagesProvider = StreamProvider.family<List<SupportMessage>, String>((ref, ticketId) {
  return ref.watch(supportRepositoryProvider).subscribeToMessages(ticketId);
});
