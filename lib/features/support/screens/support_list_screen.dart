import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:needlix/core/widgets/premium_empty_state.dart';
import '../providers/support_provider.dart';
import '../models/support_ticket.dart';
import 'create_ticket_screen.dart';
import 'ticket_chat_screen.dart';

class SupportListScreen extends ConsumerWidget {
  const SupportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return PremiumEmptyState(
              icon: Icons.support_agent_outlined,
              title: 'Need Help?',
              message: 'Our support team is here for you. Create a ticket and we\'ll get back to you as soon as possible.',
              actionLabel: 'Create Ticket',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myTicketsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _TicketCard(ticket: ticket);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
        ),
        icon: const Icon(Icons.add_comment),
        label: const Text('New Ticket'),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TicketChatScreen(ticket: ticket)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(ticket.updatedAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.subject,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ticket ID: #${ticket.id.substring(0, 8).toUpperCase()}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case SupportTicket.statusOpen: return Colors.blue;
      case SupportTicket.statusInProgress: return Colors.orange;
      case SupportTicket.statusResolved: return Colors.green;
      case SupportTicket.statusClosed: return Colors.grey;
      default: return Colors.blue;
    }
  }
}
