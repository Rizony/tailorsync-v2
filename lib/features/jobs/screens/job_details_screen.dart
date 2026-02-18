import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import 'package:tailorsync_v2/features/invoicing/services/invoice_service.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final JobModel job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  late JobModel _job;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final updatedJob = _job.copyWith(status: newStatus);
      await ref.read(jobRepositoryProvider.notifier).updateJob(updatedJob);
      
      setState(() {
        _job = updatedJob;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  } // FIXED: Removed the extra floating setState and duplicate closing brace here

  Future<void> _generateInvoice() async {
    setState(() => _isLoading = true);
    try {
      final profile = ref.read(profileNotifierProvider).value;
      if (profile == null) {
        throw Exception('Profile not loaded');
      }

final customer = await ref.read(customerRepositoryProvider.notifier).getCustomer(_job.customerId);      
      if (customer == null) {
        throw Exception('Customer not found');
      }

      await ref.read(invoiceServiceProvider).generateInvoice(
        job: _job, 
        customer: customer, 
        profile: profile,
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating invoice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_job.title),
        actions: [ // FIXED: Removed duplicate 'actions: ['
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Generate Invoice',
            onPressed: _isLoading ? null : _generateInvoice,
          ),
          if (_job.status == JobModel.statusQuote)
            TextButton(
              onPressed: _isLoading ? null : () => _updateStatus(JobModel.statusPending),
              child: const Text('Convert to Order', style: TextStyle(color: Colors.white)),
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
                  '₦${_job.price}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D3FD3)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Due Date
            _buildDetailRow(Icons.calendar_today, 'Due Date', DateFormat.yMMMd().format(_job.dueDate)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.attach_money, 'Balance Due', '₦${_job.balanceDue}'),
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
                   color: Colors.grey[100],
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
                  onPressed: _isLoading ? null : () => _updateStatus(JobModel.statusInProgress),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Job'),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
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
          onChanged: _isLoading ? null : (val) {
            if (val != null) _updateStatus(val);
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(color: Colors.grey)),
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