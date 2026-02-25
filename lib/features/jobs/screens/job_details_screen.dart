import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';


import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tailorsync_v2/features/jobs/controllers/job_controller.dart';
import 'package:tailorsync_v2/features/jobs/screens/create_job_screen.dart';
import 'package:tailorsync_v2/features/invoicing/screens/invoice_preview_screen.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/screens/upgrade_screen.dart' as tailorsync_upgrade;
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final JobModel job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  late JobModel _job;
  Customer? _customer;



  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _fetchCustomer();
  }

  Future<void> _fetchCustomer() async {
    final customer = await ref.read(customerRepositoryProvider.notifier).getCustomer(_job.customerId);
    if (mounted) setState(() => _customer = customer);
  }

  Future<void> _updateStatus(String newStatus) async {
    final controller = ref.read(jobControllerProvider(_job.id).notifier);
    
    // Status Logic
    if (_job.status == JobModel.statusQuote && newStatus == JobModel.statusPending) {
       final deposit = await _showDepositDialog();
       if (deposit == null) return;
       
       await controller.convertQuoteToOrder(deposit, _job.price);
       return;
    }

    await controller.updateStatus(newStatus);
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



  @override
  Widget build(BuildContext context) {
    // Watch the controller state
    final jobState = ref.watch(jobControllerProvider(widget.job.id));
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    
    // Listen for errors
    ref.listen(jobControllerProvider(widget.job.id), (previous, next) {
      if (next.hasError && !next.isLoading) {
        showErrorSnackBar(context, next.error!);
      }
      if (next.hasValue && !next.isLoading && !next.hasError) {
        // Update local job if we have new data
         setState(() => _job = next.valueOrNull!);
      }
    });

    final isLoading = jobState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_job.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
               await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateJobScreen(job: _job)),
              );
              // Refresh job details when returning from edit
              ref.invalidate(jobControllerProvider(widget.job.id));
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
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const tailorsync_upgrade.UpgradeScreen()));
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
                  builder: (_) => InvoicePreviewScreen(job: _job, customer: _customer!),
                ),
              );
            },
          ),
          if (_job.status == JobModel.statusQuote)
            TextButton(
              onPressed: isLoading ? null : () => _updateStatus(JobModel.statusPending),
              child: isLoading 
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Convert to Order'),
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
                  '${profile?.currencySymbol ?? '₦'}${_job.price}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

              // --- Order Items List ---
              if (_job.items.isNotEmpty) ...[
                const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._job.items.map((item) => Padding(
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
                          
                          final message = Uri.encodeComponent("Hello ${_customer!.fullName.split(' ').first}, your order from TailorSync is ready!");
                          launchUrl(Uri.parse('https://wa.me/$phone?text=$message'), mode: LaunchMode.externalApplication);
                        },
                      ),
                    ]
                  ],
                ),
              ),

            // Due Date
            _buildDetailRow(Icons.calendar_today, 'Due Date', DateFormat.yMMMd().format(_job.dueDate)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.attach_money, 'Balance Due', '${profile?.currencySymbol ?? '₦'}${_job.balanceDue}'),
            const SizedBox(height: 24),

            // Images
            if (_job.images.isNotEmpty) ...[
              const Text('Designs / Sketches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _job.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(_job.images[index], width: 120, height: 120, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Measurements / Notes
            if (_job.notes != null && _job.notes!.isNotEmpty) ...[
               const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Text(_job.notes!),
               ),
            ],
            
            const SizedBox(height: 40),
            
            if (JobModel.activeStatuses.contains(_job.status) && _job.status != JobModel.statusPending)
              const SizedBox.shrink(),

            if (_job.status == JobModel.statusPending)
               SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ref.watch(jobControllerProvider(_job.id)).isLoading ? null : () => _updateStatus(JobModel.statusInProgress),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: ref.watch(jobControllerProvider(_job.id)).isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Start Job'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    if (_job.status == JobModel.statusQuote) {
      return _buildStatusChip(_job.status);
    }
    
    final allowedStatuses = JobModel.allStatuses.where((s) => s != JobModel.statusQuote).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _job.status,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          items: allowedStatuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: _buildStatusChip(status, isSmall: true),
            );
          }).toList(),
          onChanged: ref.watch(jobControllerProvider(_job.id)).isLoading ? null : (val) {
            if (val != null) _updateStatus(val);
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('$label:', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
  
  Widget _buildStatusChip(String status, {bool isSmall = false}) {
    Color color;
    switch (status) {
      case JobModel.statusPending: color = Colors.orange; break;
      case JobModel.statusInProgress: color = Colors.blue; break;
      case JobModel.statusFitting: color = Colors.purple; break;
      case JobModel.statusAdjustment: color = Colors.amber; break;
      case JobModel.statusCompleted: color = Colors.green; break;
      case JobModel.statusDelivered: color = Colors.grey; break;
      case JobModel.statusCanceled: color = Colors.red; break;
      case JobModel.statusQuote: color = Colors.cyan; break;
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
}