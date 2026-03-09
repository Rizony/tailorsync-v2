import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';
import 'package:tailorsync_v2/features/monetization/screens/upgrade_screen.dart';

import 'package:tailorsync_v2/features/customers/utils/smart_measurement_engine.dart';

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

  File? _profileImage;
  String? _existingPhotoUrl;

  // Measurement editing
  Map<String, dynamic> _measurements = {};
  final Map<String, TextEditingController> _measurementControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _measurements = Map.from(widget.customer?.measurements ?? {});
    _existingPhotoUrl = widget.customer?.photoUrl;

    if (widget.customer == null) {
      _selectedGender = 'Male';
    } else {
      if (_measurements.containsKey('Bust') || _measurements.containsKey('Gown Length') || _measurements.containsKey('Skirt Length')) {
        _selectedGender = 'Female';
      }
      for (var e in _measurements.entries) {
        _measurementControllers[e.key] = TextEditingController(text: e.value.toString());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final path = '$userId/$fileName';
      
      await Supabase.instance.client.storage
          .from('customer_photos')
          .upload(path, imageFile);
          
      return Supabase.instance.client.storage
          .from('customer_photos')
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('Photo upload failed: $e');
      return null;
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? uploadedPhotoUrl = _existingPhotoUrl;
      
      if (_profileImage != null) {
        final newUrl = await _uploadImage(_profileImage!);
        if (newUrl != null) uploadedPhotoUrl = newUrl;
      }

      final customer = Customer(
        id: widget.customer?.id, // Null for new, existing for edit
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        photoUrl: uploadedPhotoUrl,
        measurements: _measurements,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
      );

      if (widget.customer == null) {
        // Create
        final newCustomer = await ref.read(customerRepositoryProvider.notifier).addCustomer(customer);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer created!')));
           await Future.delayed(const Duration(milliseconds: 50));
           if (mounted) Navigator.pop(context, newCustomer);
        }
      } else {
        // Update
        await ref.read(customerRepositoryProvider.notifier).updateCustomer(customer);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer updated!')));
           await Future.delayed(const Duration(milliseconds: 50));
           if (mounted) Navigator.pop(context, customer); // Return updated input (though ID might be missing if we used input? No, widget.customer has ID)
        }
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        if (errStr.contains('MAX_LIMIT_REACHED')) {
          _showLimitDialog(isHardLimit: true);
        } else if (errStr.contains('LIMIT_REACHED')) {
          _showLimitDialog(isHardLimit: false);
        } else {
          showErrorSnackBar(context, e);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLimitDialog({required bool isHardLimit}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customer Limit Reached', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(isHardLimit 
            ? 'You have reached the absolute maximum of 50 customers allowed on the Freemium plan. Upgrade to Standard or Premium for unlimited customers.'
            : 'You have reached your free 20-customer limit. Watch a short ad to add 1 more customer, or upgrade for unlimited.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (!isHardLimit)
            OutlinedButton.icon(
              icon: const Icon(Icons.play_circle_fill, color: Color(0xFF0076B6)),
              label: const Text('Watch Ad (+1)', style: TextStyle(color: Color(0xFF0076B6))),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(customerRepositoryProvider.notifier).handleLimitWithAd(context);
              },
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E78D2),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradeScreen()));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
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
              // __ Profile Photo Picker ___ //
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null 
                      ? FileImage(_profileImage!) as ImageProvider
                      : (_existingPhotoUrl != null ? NetworkImage(_existingPhotoUrl!) : null),
                    child: _profileImage == null && _existingPhotoUrl == null
                        ? const Icon(Icons.add_a_photo, size: 32, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  backgroundColor: const Color(0xFF0076B6),
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

  String _selectedGender = 'Male'; 
  String _selectedFit = 'Regular';
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();

  Widget _buildMeasurementsSection() {
    return Card(
      child: ExpansionTile(
        title: const Text('Measurements'),
        subtitle: const Text('Use Gender Selector to quick-fill'),
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
                              _triggerAutoCalculate();
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
                              _triggerAutoCalculate();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedFit,
                  decoration: const InputDecoration(labelText: 'Fit Preference', border: OutlineInputBorder()),
                  items: ['Slim', 'Regular', 'Loose'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue != null) _selectedFit = newValue;
                      _triggerAutoCalculate(); 
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _chestController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: _selectedGender == 'Male' ? 'Chest (cm)' : 'Bust (cm)', border: const OutlineInputBorder()),
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _waistController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Waist (Optional)', border: OutlineInputBorder()),
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _hipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Hip (Optional)', border: OutlineInputBorder()),
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text("Auto-Generated Proportions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                // List existing measurements
                if (_measurements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text("Select gender or add manually.", style: TextStyle(color: Colors.grey)),
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

  void _triggerAutoCalculate() {
    final height = double.tryParse(_heightController.text);
    final chest = double.tryParse(_chestController.text);
    final waist = double.tryParse(_waistController.text);
    final hip = double.tryParse(_hipController.text);

    if (height != null && chest != null) {
      final results = SmartMeasurementEngine.generateMeasurements(
        gender: _selectedGender,
        height: height,
        chest: chest,
        waist: waist,
        hip: hip,
        fitType: _selectedFit,
      );

      setState(() {
        _measurements.clear();
        for (var controller in _measurementControllers.values) {
          controller.dispose();
        }
        _measurementControllers.clear();

        results.forEach((key, value) {
           _measurements[key] = value.toString();
           _measurementControllers[key] = TextEditingController(text: value.toString());
        });
      });
    }
  }

  Widget _buildMeasurementRow(String key, String value) {
    _measurementControllers[key] ??= TextEditingController(text: value);
    final controller = _measurementControllers[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(child: Text("$key:", style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(),
                hintText: 'e.g. 36',
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
                _measurementControllers[key]?.dispose();
                _measurementControllers.remove(key);
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
                  _measurementControllers[key] = TextEditingController(text: value);
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
