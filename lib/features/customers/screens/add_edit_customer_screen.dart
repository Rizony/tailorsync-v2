import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  ConsumerState<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  // Measurement editing
  Map<String, dynamic> _measurements = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _measurements = Map.from(widget.customer?.measurements ?? {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customer = Customer(
        id: widget.customer?.id, // Null for new, existing for edit
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        measurements: _measurements,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
      );

      if (widget.customer == null) {
        // Create
        await ref.read(customerRepositoryProvider.notifier).addCustomer(customer);
      } else {
        // Update
        await ref.read(customerRepositoryProvider.notifier).updateCustomer(customer);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.customer == null ? 'Customer created!' : 'Customer updated!')),
        );
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted) Navigator.pop(context);
        }
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
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 24),

              // Measurements Section
              _buildMeasurementsSection(),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3FD3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(isEditing ? 'Update Customer' : 'Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementsSection() {
    return Card(
      child: ExpansionTile(
        title: const Text('Measurements'),
        subtitle: const Text('Tap to add/edit measurements'),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // List existing measurements
                if (_measurements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text("No measurements added yet.", style: TextStyle(color: Colors.grey)),
                  ),
                
                ..._measurements.entries.map((e) => _buildMeasurementRow(e.key, e.value.toString())),
                
                // Add new button
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _showAddMeasurementDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Measurement Field'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(child: Text("$key:", style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: value,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                _measurements[key] = val;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _measurements.remove(key);
              });
            },
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
              decoration: const InputDecoration(labelText: 'Name (e.g. Waist, Inseam)'),
              autofocus: true,
              onChanged: (v) => key = v,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Value (e.g. 32, 10.5)'),
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
                  _measurements[key] = value;
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
}
