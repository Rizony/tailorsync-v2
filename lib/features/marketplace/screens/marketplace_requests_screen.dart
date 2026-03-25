import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/marketplace_repository.dart';
import '../models/marketplace_request.dart';
import '../../customers/repositories/customer_repository.dart';
import '../../customers/models/customer.dart';
import '../../orders/repositories/order_repository.dart';
import '../../orders/models/order_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MarketplaceRequestsScreen extends ConsumerWidget {
  const MarketplaceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(marketplaceRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(marketplaceRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.map(
        data: (d) {
          final requests = d.value;
          if (requests.isEmpty) {
            return const Center(child: Text('No order requests from the marketplace yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _RequestCard(request: requests[index]);
            },
          );
        },
        loading: (_) => const Center(child: CircularProgressIndicator()),
        error: (e) => Center(child: Text('Error: ${e.error}')),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final MarketplaceRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPending = request.status == 'pending';
    final isAccepted = request.status == 'accepted';
    final quantity = request.itemQuantity;
    final hasImages = request.imageUrls.isNotEmpty;
    final hasLinks = request.referenceLinks.isNotEmpty;
    final hasQuote = (request.quoteAmount != null && (request.quoteAmount ?? 0) > 0);
    final isPaid = request.paymentStatus.toLowerCase() == 'paid';
    final quoteStatus = request.quoteStatus.toLowerCase();
    final hasCounter = (request.counterOfferAmount != null && (request.counterOfferAmount ?? 0) > 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        request.customerName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (request.customerRating != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                request.customerRating!.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(status: request.status, paymentStatus: request.paymentStatus, quoteStatus: request.quoteStatus),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(request.createdAt),
              style: theme.textTheme.bodySmall,
            ),
            
            // --- Quote & Payment Status Row ---
            if (hasQuote) ...[
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.withValues(alpha: 0.05) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPaid ? Colors.green.withValues(alpha: 0.2) : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle : Icons.payments_outlined, 
                          size: 16, 
                          color: isPaid ? Colors.green : theme.colorScheme.primary
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Quote: ₦${request.quoteAmount?.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : 'UNPAID',
                            style: TextStyle(
                              color: isPaid ? Colors.white : Colors.grey.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          'Client Status: ${quoteStatus.toUpperCase()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: quoteStatus == 'accepted' ? Colors.green : Colors.blueGrey.shade600,
                            fontWeight: quoteStatus == 'accepted' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (request.quoteMessage != null && request.quoteMessage!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Your note: ${request.quoteMessage}',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            if (hasCounter) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client counter-offer',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₦${request.counterOfferAmount?.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (request.counterOfferMessage != null && request.counterOfferMessage!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(request.counterOfferMessage!, style: theme.textTheme.bodySmall),
                    ],
                    if (request.counterOfferedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(request.counterOfferedAt!),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(marketplaceRepositoryProvider).acceptCounterOffer(request: request);
                              if (!context.mounted) return;
                              // Also convert to order immediately
                              await _updateStatus(context, ref, 'accepted', forceAmount: request.counterOfferAmount);
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Accept counter', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showQuoteDialog(context, ref),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Update quote'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 24.0),
            if (quantity != null && quantity > 0) ...[
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Quantity: $quantity', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10.0),
            ],
            Text(
              request.description,
              style: theme.textTheme.bodyMedium,
            ),
            if (hasImages) ...[
              const SizedBox(height: 12.0),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: request.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final url = request.imageUrls[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          width: 160,
                          height: 110,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 160,
                            height: 110,
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 160,
                            height: 110,
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            child: const Center(child: Icon(Icons.broken_image_outlined)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (hasLinks) ...[
              const SizedBox(height: 12.0),
              Text('Reference links', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6.0),
              ...request.referenceLinks.take(5).map((u) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: InkWell(
                    onTap: () => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            u,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (request.referenceLinks.length > 5)
                Text('+${request.referenceLinks.length - 5} more', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              children: [
                if (request.customerWhatsapp != null && request.customerWhatsapp!.trim().isNotEmpty)
                  ActionChip(
                    avatar: const Icon(Icons.chat, size: 16),
                    label: const Text('WhatsApp'),
                    onPressed: () {
                      final raw = request.customerWhatsapp!.trim();
                      final phone = raw.replaceAll(' ', '').replaceAll('+', '');
                      launchUrl(Uri.parse('https://wa.me/$phone'), mode: LaunchMode.externalApplication);
                    },
                  ),
                if (request.customerPhone != null)
                  ActionChip(
                    avatar: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    onPressed: () => launchUrl(Uri.parse('tel:${request.customerPhone}')),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.email, size: 16),
                  label: const Text('Email'),
                  onPressed: () => launchUrl(Uri.parse('mailto:${request.customerEmail}')),
                ),
                ActionChip(
                  avatar: const Icon(Icons.price_change_outlined, size: 16),
                  label: Text(hasQuote ? 'Update Quote' : 'Send Quote'),
                  onPressed: () => _showQuoteDialog(context, ref),
                ),
                if (hasQuote && !isPaid && quoteStatus != 'accepted')
                  ActionChip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark Accepted'),
                    onPressed: () async {
                      await ref.read(marketplaceRepositoryProvider).setQuoteStatus(
                            requestId: request.id,
                            quoteStatus: 'accepted',
                          );
                      ref.invalidate(marketplaceRequestsProvider);
                    },
                  ),
                if (request.status == 'completed' && request.customerId != null)
                  ActionChip(
                    avatar: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Rate Client'),
                    onPressed: () => _showRatingDialog(context, ref),
                  ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16.0),
              if (quoteStatus == 'accepted')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, ref, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Client Accepted Quote - Convert to Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else if (isPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, ref, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Client PAID - Start Order Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(context, ref, 'rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!hasQuote) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please send a quote first so the client can pay.')),
                            );
                            _showQuoteDialog(context, ref);
                            return;
                          }
                          _updateStatus(context, ref, 'accepted');
                        },
                        child: const Text('Accept Request'),
                      ),
                    ),
                  ],
                ),
            ],
            if (!isPending && !isAccepted && hasQuote && !isPaid && quoteStatus != 'accepted') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waiting for client to accept quote or pay on website.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showQuoteDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController(
      text: request.quoteAmount != null ? request.quoteAmount!.toStringAsFixed(0) : '',
    );
    final messageController = TextEditingController(text: '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₦)',
                hintText: 'e.g. 25000',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                hintText: 'Add delivery timeline, fitting notes, etc.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save Quote')),
        ],
      ),
    );

    if (ok != true) return;

    final amount = double.tryParse(amountController.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid quote amount.')));
      }
      return;
    }

    try {
      await ref.read(marketplaceRepositoryProvider).updateRequestQuote(
        requestId: request.id,
        quoteAmount: amount,
        quoteMessage: messageController.text.trim().isEmpty ? null : messageController.text.trim(),
      );
      ref.invalidate(marketplaceRequestsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote saved. Client can now pay on the website.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save quote: $e')));
      }
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status, {double? forceAmount}) async {
    if (status == 'accepted') {
      // Prevent duplicate orders
      if (request.orderId != null && request.orderId!.isNotEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An order has already been created for this request.')),
          );
        }
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Convert to Order?'),
          content: Text('This will create a new order and invoice for ${request.customerName}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create Order'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // 1. Check for existing customer
      final customers = ref.read(customerRepositoryProvider).value ?? [];
      Customer? existingCustomer = customers.cast<Customer?>().firstWhere(
        (c) => c?.email == request.customerEmail || (c?.phoneNumber != null && c?.phoneNumber == request.customerPhone),
        orElse: () => null,
      );

      String customerId;
      if (existingCustomer == null) {
        // Create new customer
        final newCustomer = await ref.read(customerRepositoryProvider.notifier).addCustomer(
          Customer(
            fullName: request.customerName,
            email: request.customerEmail,
            phoneNumber: request.customerPhone,
          ),
        );
        customerId = newCustomer.id!;
      } else {
        customerId = existingCustomer.id!;
      }

      // 2. Create the order
      final finalAmount = forceAmount ?? request.quoteAmount ?? 0;
      final order = OrderModel(
        id: const Uuid().v4(),
        userId: '', // Repository handles this
        customerId: customerId,
        title: request.description.length > 30 
            ? '${request.description.substring(0, 27)}...' 
            : request.description,
        price: finalAmount,
        balanceDue: finalAmount,
        dueDate: DateTime.now().add(const Duration(days: 7)), // Default 1 week
        createdAt: DateTime.now(),
        notes: 'Marketplace Request: ${request.description}',
      );

      await ref.read(orderRepositoryProvider).createOrder(order);
      
      // 3. Update request status
      await ref.read(marketplaceRepositoryProvider).acceptAndCreateOrder(
        request: request,
        orderId: order.id,
        customerId: customerId,
        title: order.title,
        dueDate: order.dueDate,
        price: 0,
      );
    } else {
      await ref.read(marketplaceRepositoryProvider).updateRequestStatus(request.id, status);
    }
    
    ref.invalidate(marketplaceRequestsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${status == 'accepted' ? 'accepted and order created' : 'rejected'}.')),
      );
    }
  }

  Future<void> _showRatingDialog(BuildContext context, WidgetRef ref) async {
    int rating = 5;
    final reviewController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate ${request.customerName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your experience with this client?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Review (optional)',
                  hintText: 'e.g. Great communication, clear requirements...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || request.customerId == null) return;

    try {
      await ref.read(marketplaceRepositoryProvider).submitClientRating(
            requestId: request.id,
            tailorId: request.tailorId,
            customerId: request.customerId!,
            rating: rating,
            review: reviewController.text.trim().isEmpty ? null : reviewController.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: $e')),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String paymentStatus;
  final String quoteStatus;

  const _StatusBadge({
    required this.status,
    required this.paymentStatus,
    required this.quoteStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status.toUpperCase();

    if (paymentStatus == 'paid') {
      color = Colors.green;
      label = 'PAID & ACCEPTED';
    } else if (quoteStatus == 'accepted') {
      color = Colors.blue;
      label = 'QUOTE ACCEPTED';
    } else {
      switch (status) {
        case 'accepted':
          color = Colors.green;
          break;
        case 'rejected':
          color = Colors.red;
          break;
        case 'completed':
          color = Colors.blue;
          break;
        default:
          color = Colors.orange;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
