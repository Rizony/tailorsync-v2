import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/customers/repositories/customer_repository.dart';


import 'package:needlix/features/customers/models/customer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:needlix/features/orders/controllers/order_controller.dart';
import 'package:needlix/features/orders/screens/create_order_screen.dart';
import 'package:needlix/features/invoicing/screens/invoice_preview_screen.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/features/monetization/screens/upgrade_screen.dart' as needlix_upgrade;
import 'package:needlix/features/monetization/models/subscription_tier.dart';
import 'package:needlix/core/notifications/whatsapp_service.dart';
import 'package:needlix/features/community/repositories/community_repository.dart';
import 'package:needlix/features/community/models/community_post.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  late OrderModel _order;
  Customer? _customer;



  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchCustomer();
  }

  Future<void> _fetchCustomer() async {
    final customer = await ref.read(customerRepositoryProvider.notifier).getCustomer(_order.customerId);
    if (mounted) setState(() => _customer = customer);
  }

  Future<void> _updateStatus(String newStatus) async {
    final controller = ref.read(orderControllerProvider(_order.id).notifier);
    
    // Status Logic
    if (_order.status == OrderModel.statusQuote && newStatus == OrderModel.statusPending) {
       final deposit = await _showDepositDialog();
       if (deposit == null) return;
       
       await controller.convertQuoteToOrder(deposit, _order.price);
       return;
    }

    await controller.updateStatus(newStatus);

    if ((newStatus == OrderModel.statusFitting || 
         newStatus == OrderModel.statusCompleted || 
         newStatus == OrderModel.statusInProgress) && 
        _customer?.phoneNumber != null && mounted) {
      _promptWhatsAppUpdate(newStatus);
    }
  }

  Future<void> _promptWhatsAppUpdate(String status) async {
    final wantToNotify = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Notify Customer?'),
              content: Text(
                  'Would you like to notify ${_customer!.fullName.split(' ').first} using:'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, null),
                    child: const Text('Cancel')),
                TextButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'sms'),
                  icon: const Icon(Icons.sms, color: Colors.blue),
                  label: const Text('SMS'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'whatsapp'),
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white),
                ),
              ],
            ));

    if (wantToNotify != null && _customer?.phoneNumber != null) {
      final phoneNumber = _customer!.phoneNumber!;
      final customerName = _customer!.fullName;
      final orderTitle = _order.title;
      final profile = ref.read(profileNotifierProvider).valueOrNull;

      if (wantToNotify == 'whatsapp') {
        await WhatsAppService.sendStatusUpdate(
          phoneNumber: phoneNumber,
          customerName: customerName,
          orderTitle: orderTitle,
          status: status,
          shopName: profile?.shopName,
          balanceDue: _order.balanceDue.toStringAsFixed(2),
          currency: profile?.currencySymbol,
          dueDate: _order.dueDate,
        );
      } else if (wantToNotify == 'sms') {
        await WhatsAppService.sendSMSUpdate(
          phoneNumber: phoneNumber,
          customerName: customerName,
          orderTitle: orderTitle,
          status: status,
          shopName: profile?.shopName,
          balanceDue: _order.balanceDue.toStringAsFixed(2),
          currency: profile?.currencySymbol,
          dueDate: _order.dueDate,
        );
      }
    }
  }

  Future<double?> _showDepositDialog() async {
    final controller = TextEditingController(text: '0');
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Deposit Amount:'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(prefixText: '${ref.read(profileNotifierProvider).valueOrNull?.currencySymbol ?? '₦'} '),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, double.tryParse(controller.text) ?? 0);
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecordPaymentDialog() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final symbol = ref.read(profileNotifierProvider).valueOrNull?.currencySymbol ?? '₦';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount ($symbol)',
                border: const OutlineInputBorder(),
                prefixText: '$symbol ',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'e.g. Cash, Part payment',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                ref.read(orderControllerProvider(_order.id).notifier).recordPayment(
                  amount,
                  note: noteController.text.isEmpty ? null : noteController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Watch the controller state
    final orderState = ref.watch(orderControllerProvider(widget.order.id));
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    
    // Listen for errors
    ref.listen(orderControllerProvider(widget.order.id), (previous, next) {
      if (next.hasError && !next.isLoading) {
        showErrorSnackBar(context, next.error!);
      }
      if (next.hasValue && !next.isLoading && !next.hasError) {
        // Update local order if we have new data
         setState(() => _order = next.valueOrNull!);
      }
    });

    final isLoading = orderState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_order.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
               await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateOrderScreen(order: _order)),
              );
              // Refresh order details when returning from edit
              ref.invalidate(orderControllerProvider(widget.order.id));
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Preview Invoice',
            onPressed: _customer == null ? null : () {
              final tier = ref.read(profileNotifierProvider).valueOrNull?.subscriptionTier ?? SubscriptionTier.freemium;
              if (tier == SubscriptionTier.freemium) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Premium Feature', style: TextStyle(fontWeight: FontWeight.bold)),
                    content: const Text('PDF Invoices & Quotations are only available on Standard and Premium plans. Upgrade to unlock this feature!'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E78D2), foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const needlix_upgrade.UpgradeScreen()));
                        },
                        child: const Text('View Plans'),
                      ),
                    ],
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoicePreviewScreen(order: _order, customer: _customer!),
                ),
              );
            },
          ),
          if (_order.status == OrderModel.statusQuote)
            TextButton(
              onPressed: isLoading ? null : () => _updateStatus(OrderModel.statusPending),
              child: isLoading 
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Convert to Order'),
            ),
          if (_order.status == OrderModel.statusCompleted || _order.status == OrderModel.statusDelivered)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.blue),
              tooltip: 'Share to Showroom',
              onPressed: () => _shareToShowroom(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusSelector(),
                Text(
                  '${profile?.currencySymbol ?? '₦'}${_order.price}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

              // --- Order Items List ---
              if (_order.items.isNotEmpty) ...[
                const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.name}', style: const TextStyle(fontSize: 16)),
                      Text('${profile?.currencySymbol ?? '₦'}${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                const Divider(),
                const SizedBox(height: 16),
              ],
            
            // --- Customer Info with Actions ---
            if (_customer != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: Text(_customer!.fullName.isNotEmpty ? _customer!.fullName[0].toUpperCase() : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_customer!.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(_customer!.phoneNumber ?? 'No Phone', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (_customer!.phoneNumber != null) ...[
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => launchUrl(Uri.parse('tel:${_customer!.phoneNumber}')),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Color(0xFF25D366)),
                        onPressed: () {
                          // Very basic formatting for Nigeria (default) - real app should use a formatter
                          String phone = _customer!.phoneNumber!.replaceAll(RegExp(r'\D'), '');
                          if (phone.startsWith('0')) phone = '234${phone.substring(1)}';
                          
                          final message = Uri.encodeComponent("Hello ${_customer!.fullName.split(' ').first}, your order for '${_order.title}' from MyTailorShop is ready!");
                          launchUrl(Uri.parse('https://wa.me/$phone?text=$message'), mode: LaunchMode.externalApplication);
                        },
                      ),
                    ]
                  ],
                ),
              ),

            // Due Date
            _buildDetailRow(Icons.calendar_today, 'Due Date', DateFormat.yMMMd().format(_order.dueDate)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    Icons.account_balance_wallet, 
                    'Balance Due', 
                    '${profile?.currencySymbol ?? '₦'}${_order.balanceDue.toStringAsFixed(2)}',
                    color: _order.balanceDue > 0 ? Colors.red : Colors.green,
                  ),
                ),
                if (_order.balanceDue > 0)
                  TextButton.icon(
                    onPressed: _showRecordPaymentDialog,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Record Payment'),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Fabric Status
            const Text('Fabric Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildFabricSelector(),
            const SizedBox(height: 24),

            // Payment History
            if (_order.payments.isNotEmpty) ...[
              const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _order.payments.reversed.map((p) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    title: Text('${profile?.currencySymbol ?? '₦'}${p.amount.toStringAsFixed(2)}'),
                    subtitle: Text(p.note ?? 'Payment recorded'),
                    trailing: Text(DateFormat.MMMd().format(p.date), style: const TextStyle(fontSize: 11)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Images
            if (_order.images.isNotEmpty) ...[
              const Text('Designs / Sketches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _order.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(_order.images[index], width: 120, height: 120, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Measurements / Notes
            if (_order.notes != null && _order.notes!.isNotEmpty) ...[
               const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Text(_order.notes!),
               ),
            ],
            
            const SizedBox(height: 40),
            
            if (OrderModel.activeStatuses.contains(_order.status) && _order.status != OrderModel.statusPending)
              const SizedBox.shrink(),

            if (_order.status == OrderModel.statusPending)
               SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ref.watch(orderControllerProvider(_order.id)).isLoading ? null : () => _updateStatus(OrderModel.statusInProgress),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: ref.watch(orderControllerProvider(_order.id)).isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Start Order'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    if (_order.status == OrderModel.statusQuote) {
      return _buildStatusChip(_order.status);
    }
    
    final allowedStatuses = OrderModel.allStatuses.where((s) => s != OrderModel.statusQuote).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _order.status,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          items: allowedStatuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: _buildStatusChip(status, isSmall: true),
            );
          }).toList(),
          onChanged: ref.watch(orderControllerProvider(_order.id)).isLoading ? null : (val) {
            if (val != null) _updateStatus(val);
          },
        ),
      ),
    );
  }

  Widget _buildFabricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.dry_cleaning, size: 20),
          const SizedBox(width: 12),
          const Text('Fabric: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _order.fabricStatus,
                isDense: true,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'not_received', child: Text('Not Received', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'received', child: Text('Received', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'cutoff', child: Text('Cut-off', style: TextStyle(fontSize: 13))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(orderControllerProvider(_order.id).notifier).updateFabricStatus(val);
                  }
                },
              ),
            ),
          ),
          const VerticalDivider(width: 12, thickness: 1),
          const Text('Src: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _order.fabricSource,
                isDense: true,
                isExpanded: true,
                hint: const Text('Select', style: TextStyle(fontSize: 12)),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Cust', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'shop', child: Text('Shop', style: TextStyle(fontSize: 13))),
                ],
                onChanged: (val) {
                  ref.read(orderControllerProvider(_order.id).notifier).updateFabricStatus(_order.fabricStatus, source: val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label:', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status, {bool isSmall = false}) {
    Color color;
    switch (status) {
      case OrderModel.statusPending: color = Colors.orange; break;
      case OrderModel.statusInProgress: color = Colors.blue; break;
      case OrderModel.statusFitting: color = Colors.purple; break;
      case OrderModel.statusAdjustment: color = Colors.amber; break;
      case OrderModel.statusCompleted: color = Colors.green; break;
      case OrderModel.statusDelivered: color = Colors.grey; break;
      case OrderModel.statusCanceled: color = Colors.red; break;
      case OrderModel.statusQuote: color = Colors.cyan; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 12, vertical: isSmall ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isSmall ? 10 : 12),
      ),
    );
  }

  Future<void> _shareToShowroom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share to Showroom?'),
        content: const Text('This will post your completed order to the community showroom for others to see your craft!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Share Now'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final profile = ref.read(profileNotifierProvider).valueOrNull;
      if (profile == null) return;

      final post = CommunityPost(
        id: '', // Handled by repository
        userId: profile.id,
        postType: 'showroom',
        title: 'Showcase: ${_order.title}',
        content: 'Check out my latest completed work! 🧵✨\n\n'
                '${_order.notes ?? "Just finished this beautiful piece."}',
        imageUrls: _order.images,
        createdAt: DateTime.now(),
      );

      try {
        await ref.read(communityRepositoryProvider).createPost(post);
        
        // Also add to user's portfolio if not already there
        if (_order.images.isNotEmpty) {
          final newPortfolio = List<String>.from(profile.portfolioUrls);
          bool modified = false;
          for (final img in _order.images) {
            if (!newPortfolio.contains(img)) {
              newPortfolio.add(img);
              modified = true;
            }
          }
          if (modified) {
            await ref.read(profileNotifierProvider.notifier).updateProfile(
              profile.copyWith(portfolioUrls: newPortfolio)
            );
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Posted to Showroom successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sharing: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
