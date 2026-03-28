import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/features/customers/models/customer.dart';
import 'package:needlix/features/customers/repositories/customer_repository.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/features/monetization/screens/upgrade_screen.dart';

import 'package:needlix/features/customers/utils/smart_measurement_engine.dart';
import 'package:needlix/features/customers/utils/measurement_guides.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  ConsumerState<AddEditCustomerScreen> createState() =>
      _AddEditCustomerScreenState();
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

  String _selectedGender = 'Male';
  String _selectedFit = 'Regular';
  bool _isCm = true;
  String? _focusedField;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();

  final FocusNode _heightFocus = FocusNode();
  final FocusNode _chestFocus = FocusNode();
  final FocusNode _waistFocus = FocusNode();
  final FocusNode _hipFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _heightFocus.addListener(() => _onFocusChange('Height', _heightFocus.hasFocus));
    _chestFocus.addListener(() => _onFocusChange('Chest', _chestFocus.hasFocus));
    _waistFocus.addListener(() => _onFocusChange('Waist', _waistFocus.hasFocus));
    _hipFocus.addListener(() => _onFocusChange('Hip', _hipFocus.hasFocus));

    _nameController =
        TextEditingController(text: widget.customer?.fullName ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _emailController =
        TextEditingController(text: widget.customer?.email ?? '');
    _measurements = Map.from(widget.customer?.measurements ?? {});
    _existingPhotoUrl = widget.customer?.photoUrl;

    if (widget.customer == null) {
      _selectedGender = 'Male';
    } else {
      if (_measurements.containsKey('Bust') ||
          _measurements.containsKey('Gown Length') ||
          _measurements.containsKey('Skirt Length')) {
        _selectedGender = 'Female';
      }
      for (var e in _measurements.entries) {
        _measurementControllers[e.key] =
            TextEditingController(text: e.value.toString());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _heightFocus.dispose();
    _chestFocus.dispose();
    _waistFocus.dispose();
    _hipFocus.dispose();
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange(String field, bool hasFocus) {
    if (hasFocus) {
      setState(() {
        _focusedField = field;
      });
    }
  }

  Widget _buildMeasurementGuide() {
    final guide = BeSafeTailorGuides.getGuide(_focusedField ?? 'Default');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: PremiumCard(
        padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  guide.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.description,
                      style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        photoUrl: uploadedPhotoUrl,
        measurements: _measurements,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
      );

      if (widget.customer == null) {
        // Create
        final newCustomer = await ref
            .read(customerRepositoryProvider.notifier)
            .addCustomer(customer);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Customer created!')));
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted) Navigator.pop(context, newCustomer);
        }
      } else {
        // Update
        await ref
            .read(customerRepositoryProvider.notifier)
            .updateCustomer(customer);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Customer updated!')));
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted) {
            Navigator.pop(context,
                customer); // Return updated input (though ID might be missing if we used input? No, widget.customer has ID)
          }
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
        title: const Text('Customer Limit Reached',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
              icon:
                  const Icon(Icons.play_circle_fill, color: Color(0xFF0076B6)),
              label: const Text('Watch Ad (+1)',
                  style: TextStyle(color: Color(0xFF0076B6))),
              onPressed: () {
                Navigator.pop(ctx);
                ref
                    .read(customerRepositoryProvider.notifier)
                    .handleLimitWithAd(context);
              },
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E78D2),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UpgradeScreen()));
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
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : (_existingPhotoUrl != null
                              ? NetworkImage(_existingPhotoUrl!)
                              : null),
                      child: _profileImage == null && _existingPhotoUrl == null
                          ? const Icon(Icons.add_a_photo,
                              size: 32, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Measurements Section
              _buildMeasurementsSection(),
              const SizedBox(height: 32),

              PrimaryButton(
                onPressed: _saveCustomer,
                text: isEditing ? 'Update Customer' : 'Save Customer',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildMeasurementsSection() {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text('Measurements', style: AppTypography.h3),
        subtitle: Text('Use Gender Selector to quick-fill', style: AppTypography.bodySmall),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedGender == 'Male' ? AppColors.primary : null,
                          fontWeight: _selectedGender == 'Male' ? FontWeight.bold : null,
                        ),
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
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedGender == 'Female' ? AppColors.primary : null,
                          fontWeight: _selectedGender == 'Female' ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFit,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Fit',
                            border: OutlineInputBorder()),
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        initialValue: _isCm,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: true, child: Text("CM (cm)")),
                          DropdownMenuItem(
                              value: false, child: Text("Inches (in)")),
                        ],
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue != null) {
                              _isCm = newValue;
                              _triggerAutoCalculate();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                if (_focusedField != null) _buildMeasurementGuide(),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _heightController,
                        label: 'Height (${_isCm ? 'cm' : 'in'})',
                        isDense: true,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _chestController,
                        label: _selectedGender == 'Male' ? 'Chest' : 'Bust',
                        isDense: true,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _waistController,
                        label: 'Waist',
                        isDense: true,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _hipController,
                        label: 'Hip',
                        isDense: true,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _triggerAutoCalculate(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text("Auto-Generated Proportions",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                // List existing measurements
                if (_measurements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text("Select gender or add manually.",
                        style: TextStyle(color: Colors.grey)),
                  ),

                ..._measurements.entries.map(
                    (e) => _buildMeasurementRow(e.key, e.value.toString())),

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
        isCm: _isCm,
      );

      setState(() {
        _measurements.clear();
        for (var controller in _measurementControllers.values) {
          controller.dispose();
        }
        _measurementControllers.clear();

        results.forEach((key, value) {
          _measurements[key] = value.toString();
          _measurementControllers[key] =
              TextEditingController(text: value.toString());
        });
      });
    }
  }

  Widget _buildMeasurementRow(String key, String value) {
    _measurementControllers[key] ??= TextEditingController(text: value);
    final controller = _measurementControllers[key]!;

    return Focus(
      onFocusChange: (hasFocus) => _onFocusChange(key, hasFocus),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Expanded(
                child: Text("$key:",
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                label: '',
                controller: controller,
                isDense: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: 'e.g. 36',
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
              decoration:
                  const InputDecoration(labelText: 'Name (e.g. Waist, Inseam)'),
              autofocus: true,
              onChanged: (v) => key = v,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Value (e.g. 32, 10.5)'),
              onChanged: (v) => value = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (key.isNotEmpty) {
                setState(() {
                  _measurements[key] = value;
                  _measurementControllers[key] =
                      TextEditingController(text: value);
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
