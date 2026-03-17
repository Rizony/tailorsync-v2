import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/marketplace_repository.dart';
import '../models/marketplace_request.dart';
import '../../customers/repositories/customer_repository.dart';
import '../../customers/models/customer.dart';
import '../../jobs/repositories/job_repository.dart';
import '../../jobs/models/job_model.dart';
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
            return const Center(child: Text('No job requests from the marketplace yet.'));
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
                  child: Text(
                    request.customerName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(request.createdAt),
              style: theme.textTheme.bodySmall,
            ),
            if (hasQuote) ...[
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Icon(Icons.price_change_outlined, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quote: ₦${request.quoteAmount?.toStringAsFixed(0)} • ${isPaid ? "PAID" : "UNPAID"}',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
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
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16.0),
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
                      onPressed: () => _updateStatus(context, ref, 'accepted'),
                      child: const Text('Accept Request'),
                    ),
                  ),
                ],
              ),
            ],
            if (!isPending && !isAccepted && hasQuote && !isPaid) ...[
              const SizedBox(height: 12),
              Text(
                'Waiting for client payment on website.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
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

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    if (status == 'accepted') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Accept Request?'),
          content: Text('This will create a new job for ${request.customerName}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Accept & Create Job'),
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

      // 2. Create the job
      final job = JobModel(
        id: const Uuid().v4(),
        userId: '', // Repository handles this
        customerId: customerId,
        title: request.description.length > 30 
            ? '${request.description.substring(0, 27)}...' 
            : request.description,
        price: request.quoteAmount ?? 0,
        balanceDue: request.quoteAmount ?? 0,
        dueDate: DateTime.now().add(const Duration(days: 7)), // Default 1 week
        createdAt: DateTime.now(),
        notes: 'Marketplace Request: ${request.description}',
      );

      await ref.read(jobRepositoryProvider).createJob(job);
      
      // 3. Update request status
      await ref.read(marketplaceRepositoryProvider).acceptAndCreateJob(
        request: request,
        customerId: customerId,
        title: job.title,
        dueDate: job.dueDate,
        price: 0,
      );
    } else {
      await ref.read(marketplaceRepositoryProvider).updateRequestStatus(request.id, status);
    }
    
    ref.invalidate(marketplaceRequestsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${status == 'accepted' ? 'accepted and job created' : 'rejected'}.')),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
