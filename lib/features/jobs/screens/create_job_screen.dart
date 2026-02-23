// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tailorsync_v2/features/customers/screens/add_edit_customer_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/notifications/notification_service.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  final JobModel? job;
  const CreateJobScreen({super.key, this.job});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController(); // Replaced balanceController
  final _notesController = TextEditingController();
  
  DateTime? _dueDate;
  Customer? _selectedCustomer;
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;

  // Measurement editing
  Map<String, dynamic> _tempMeasurements = {};

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      final job = widget.job!;
      _titleController.text = job.title;
      _priceController.text = job.price.toString();
      _depositController.text = (job.price - job.balanceDue).toString();
      _notesController.text = job.notes ?? '';
      _dueDate = job.dueDate;
      _items.addAll(job.items);
      
      // We need to fetch the customer details since JobModel only has customerId
      // For now, we'll try to find it in the repository provider's cache or fetch it
      // This is a simplification; ideally we'd pass the Customer object too or fetch it properly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchCustomer(job.customerId);
      });
    }
  }

  Future<void> _fetchCustomer(String customerId) async {
    final result = await ref.read(customerRepositoryProvider.notifier).getCustomer(customerId);
    if (result != null) {
        setState(() {
            _selectedCustomer = result;
            _tempMeasurements = Map.from(result.measurements);
        });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _onCustomerSelected(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
      _tempMeasurements = Map.from(customer?.measurements ?? {});
    });
  }

  final List<JobItem> _items = [];

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _showAddItemDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name (e.g. Suit Jacket)'),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price', prefixText: '${ref.watch(profileNotifierProvider).valueOrNull?.currencySymbol ?? '₦'} '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                 final newItem = JobItem(
                   name: nameController.text,
                   price: double.tryParse(priceController.text) ?? 0,
                   quantity: int.tryParse(qtyController.text) ?? 1,
                 );
                 setState(() => _items.add(newItem));
                 Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveJob({required bool isQuote}) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_items.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
       return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_dueDate == null && !isQuote) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Images
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final storage = Supabase.instance.client.storage.from('job_images');
        for (var i = 0; i < _selectedImages.length; i++) {
          final file = _selectedImages[i];
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final userId = Supabase.instance.client.auth.currentUser!.id;
          final path = '$userId/$timestamp$i.jpg';
          
          await storage.upload(path, File(file.path));
          final url = storage.getPublicUrl(path);
          imageUrls.add(url);
        }
      }

      // 2. Update Customer Measurements if changed
      if (_selectedCustomer != null && _tempMeasurements.isNotEmpty) {
        final updatedCustomer = _selectedCustomer!.copyWith(measurements: _tempMeasurements);
        await ref.read(customerRepositoryProvider.notifier).updateCustomer(updatedCustomer);
      }

      // 3. Create Job
      // Auto-generate title if empty
      String title = _titleController.text.trim();
      if (title.isEmpty) {
        if (_items.length == 1) {
          title = _items.first.name;
        } else {
          title = '${_items.length} Items Order';
        }
      }
      
      final total = _calculateTotal();
      final deposit = double.tryParse(_depositController.text) ?? 0;

      final job = JobModel(
        id: widget.job?.id ?? '', 
        userId: Supabase.instance.client.auth.currentUser!.id,
        customerId: _selectedCustomer!.id!,
        title: title,
        items: _items,
        price: total,
        balanceDue: total - deposit,
        dueDate: _dueDate ?? DateTime.now(), 
        status: isQuote ? 'quote' : 'pending',
        images: imageUrls,
        notes: _notesController.text,
        createdAt: widget.job?.createdAt ?? DateTime.now(),
      );

      final result = widget.job == null 
          ? await ref.read(jobRepositoryProvider).createJob(job)
          : await ref.read(jobRepositoryProvider).updateJob(job);
      
      if (result.isLeft()) throw result.getLeft().toNullable()!;
      
      // 4. Schedule Notification (if it's an order)
      // 4. Schedule Notification (if it's an order)
      if (!isQuote && _dueDate != null) {
        try {
          final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          await NotificationService.scheduleNotification(
            id: notificationId,
            title: 'Job Due: ${job.title}',
            body: 'Order for ${_selectedCustomer!.fullName} is due today!',
            scheduledDate: _dueDate!,
          );
        } catch (e) {
          // Ignore notification errors - they shouldn't block the save
          debugPrint('Notification scheduling failed: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isQuote ? (widget.job == null ? 'Quote saved!' : 'Quote updated!') : (widget.job == null ? 'Order created!' : 'Order updated!'))),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: Text(widget.job == null ? 'New Order / Quote' : 'Edit Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Customer Selection ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCustomerDropdown()),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: IconButton(
                       icon: Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary),
                       onPressed: () async {
                         final newCustomer = await Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (_) => const AddEditCustomerScreen())
                         );
                         if (newCustomer != null && newCustomer is Customer) {
                            setState(() {
                              _selectedCustomer = newCustomer;
                              _tempMeasurements = Map.from(newCustomer.measurements);
                            });
                         }
                       },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // --- Measurements Expansion ---
              if (_selectedCustomer != null) _buildMeasurementsSection(),
              const SizedBox(height: 24),

              // --- Order Items Section ---
              const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  child: Text('No items added yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                )
              else 
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text('${item.quantity}x', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('₦${item.price.toStringAsFixed(2)} each'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₦${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => setState(() => _items.removeAt(index)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),

              // --- Title (Optional / Summary) ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Order Title / Summary',
                  hintText: 'e.g., Wedding Suit Package',
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty to auto-generate from items',
                ),
              ),
              const SizedBox(height: 16),

              // --- Totals ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Price:', style: TextStyle(fontSize: 16)),
                        Text('₦${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Deposit / Paid Amount',
                        prefixText: '₦ ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Balance Due:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '₦${(_calculateTotal() - (double.tryParse(_depositController.text) ?? 0)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: (_calculateTotal() - (double.tryParse(_depositController.text) ?? 0)) > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Due Date ---
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dueDate == null
                        ? 'Select Date'
                        : DateFormat.yMMMd().format(_dueDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Images ---
              _buildImagePicker(),
              const SizedBox(height: 16),

              // --- Notes ---
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // --- Actions ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _saveJob(isQuote: true),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Save as Quote'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _saveJob(isQuote: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Create Order'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown() {
    // You might want to use a Autocomplete or a Modal for better UX with many customers
    return Consumer(
      builder: (context, ref, _) {
        final customersAsync = ref.watch(customerRepositoryProvider);
        
        return customersAsync.when(
          data: (customers) {
            return DropdownButtonFormField<Customer>(
              decoration: const InputDecoration(
                labelText: 'Select Customer',
                border: OutlineInputBorder(),
              ),
              value: _selectedCustomer,
              items: customers.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.fullName),
              )).toList(),
              onChanged: _onCustomerSelected,
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Error loading customers: $err'),
        );
      },
    );
  }

  String _selectedGender = 'Male'; // Default

  Widget _buildMeasurementsSection() {
    return Card(
      child: ExpansionTile(
        title: const Text('Measurements'),
        subtitle: const Text('Select Gender directly edits these fields'),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Gender Selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Male')),
                        selected: _selectedGender == 'Male',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGender = 'Male';
                              _applyTemplate(Customer.maleMeasurements);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Female')),
                        selected: _selectedGender == 'Female',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGender = 'Female';
                              _applyTemplate(Customer.femaleMeasurements);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Fields
                if (_tempMeasurements.isEmpty)
                   const Text('Select a gender explicitly to load fields', style: TextStyle(color: Colors.grey)),

                ..._tempMeasurements.entries.map((e) => _buildMeasurementRow(e.key, e.value.toString())),
                
                // Add new
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    _showAddMeasurementDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom Field'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(List<String> keys) {
    for (var key in keys) {
      if (!_tempMeasurements.containsKey(key)) {
        _tempMeasurements[key] = '';
      }
    }
  }

  Widget _buildMeasurementRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text("$key:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextFormField(
              initialValue: value,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                _tempMeasurements[key] = val;
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMeasurementDialog() async {
    String key = '';
    String value = '';
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Measurement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name (e.g. Waist)'),
              onChanged: (v) => key = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Value (e.g. 32)'),
              onChanged: (v) => value = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (key.isNotEmpty) {
                setState(() {
                  _tempMeasurements[key] = value;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Design Images / Sketches', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              InkWell(
                onTap: _pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 8),
              ..._selectedImages.map((file) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(file.path), width: 80, height: 80, fit: BoxFit.cover),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
