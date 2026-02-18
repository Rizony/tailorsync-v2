import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';

class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  ConsumerState<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends ConsumerState<ShopSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _brandNameController; // Optional alias
  late TextEditingController _taxController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;
  
  // Color selection
  String _selectedColor = '0xFF5D3FD3'; // Default purple
  final List<String> _colors = [
    '0xFF5D3FD3', // Purple
    '0xFF1E88E5', // Blue
    '0xFF43A047', // Green
    '0xFFE53935', // Red
    '0xFFFB8C00', // Orange
    '0xFF000000', // Black
  ];

  // Image Uploads
  File? _logoFile;
  String? _logoUrl;
  
  File? _signatureFile;
  String? _signatureUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileNotifierProvider).value;
    _shopNameController = TextEditingController(text: user?.shopName);
    _brandNameController = TextEditingController(text: user?.brandName ?? user?.shopName);
    _taxController = TextEditingController(text: user?.defaultTaxRate.toString() ?? '0');
    _notesController = TextEditingController(text: user?.invoiceNotes);
    _termsController = TextEditingController(text: user?.termsAndConditions);
    
    if (user?.accentColor != null) {
      _selectedColor = user!.accentColor!;
    }
    _logoUrl = user?.logoUrl;
    _signatureUrl = user?.signatureUrl;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _brandNameController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(pickedFile.path);
        } else {
          _signatureFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File file, String path) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      final storagePath = 'shop_assets/$fileName'; // Assuming 'shop_assets' bucket exists
      
      await supabase.storage.from('app-assets').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      final publicUrl = supabase.storage.from('app-assets').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
      return null;
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      String? newLogoUrl = _logoUrl;
      String? newSignatureUrl = _signatureUrl;
      
      if (_logoFile != null) {
        final url = await _uploadImage(_logoFile!, 'logo.jpg');
        if (url != null) newLogoUrl = url;
      }
      
      if (_signatureFile != null) {
        final url = await _uploadImage(_signatureFile!, 'signature.jpg');
        if (url != null) newSignatureUrl = url;
      }
      
      final currentUser = ref.read(profileNotifierProvider).value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          shopName: _shopNameController.text,
          brandName: _brandNameController.text,
          logoUrl: newLogoUrl,
          signatureUrl: newSignatureUrl,
          accentColor: _selectedColor,
          defaultTaxRate: double.tryParse(_taxController.text) ?? 0.0,
          invoiceNotes: _notesController.text,
          termsAndConditions: _termsController.text,
        );
        
        await ref.read(profileNotifierProvider.notifier).updateProfile(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Branding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              // Shop Name
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              // Brand Name (Optional)
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(labelText: 'Brand Name (for Invoices)', border: OutlineInputBorder(), hintText: 'Same as Shop Name if empty'),
              ),
              const SizedBox(height: 24),
              
              // Logo & Signature
              Row(
                children: [
                   Expanded(
                     child: Column(
                       children: [
                         const Text('Logo'),
                         const SizedBox(height: 8),
                         GestureDetector(
                           onTap: () => _pickImage(true),
                           child: CircleAvatar(
                             radius: 40,
                             backgroundImage: _logoFile != null 
                                 ? FileImage(_logoFile!) 
                                 : (_logoUrl != null ? NetworkImage(_logoUrl!) as ImageProvider : null),
                             child: (_logoFile == null && _logoUrl == null) ? const Icon(Icons.add_a_photo) : null,
                           ),
                         ),
                       ],
                     ),
                   ),
                   Expanded(
                     child: Column(
                       children: [
                         const Text('Signature'),
                         const SizedBox(height: 8),
                         GestureDetector(
                           onTap: () => _pickImage(false),
                           child: Container(
                             height: 80,
                             width: 120,
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey),
                               borderRadius: BorderRadius.circular(8),
                               image: _signatureFile != null 
                                   ? DecorationImage(image: FileImage(_signatureFile!), fit: BoxFit.cover)
                                   : (_signatureUrl != null ? DecorationImage(image: NetworkImage(_signatureUrl!), fit: BoxFit.cover) : null),
                             ),
                             child: (_signatureFile == null && _signatureUrl == null) 
                                 ? const Center(child: Icon(Icons.add_a_photo)) 
                                 : null,
                           ),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Accent Color
              const Text('Invoice Theme Color', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final colorHex = _colors[index];
                    final color = Color(int.parse(colorHex));
                    final isSelected = _selectedColor == colorHex;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorHex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
               const Text('Financial & Legal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
               const SizedBox(height: 16),
               
               // Tax Rate
               TextFormField(
                 controller: _taxController,
                 decoration: const InputDecoration(labelText: 'Default Tax Rate (%)', border: OutlineInputBorder(), suffixText: '%'),
                 keyboardType: TextInputType.number,
               ),
               const SizedBox(height: 12),
               
               // Invoice Notes
               TextFormField(
                 controller: _notesController,
                 decoration: const InputDecoration(labelText: 'Default Invoice Notes', border: OutlineInputBorder(), hintText: 'e.g. Thanks for your business!'),
                 maxLines: 2,
               ),
               const SizedBox(height: 12),
               
               // Terms
               TextFormField(
                 controller: _termsController,
                 decoration: const InputDecoration(labelText: 'Terms & Conditions', border: OutlineInputBorder(), hintText: 'e.g. No refunds after 7 days.'),
                 maxLines: 3,
               ),
               
               const SizedBox(height: 40),
               
               // Save Button
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: _isLoading ? _saveSettings : _saveSettings,
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     backgroundColor: Color(int.parse(_selectedColor)), // Preview theme color
                     foregroundColor: Colors.white,
                   ),
                   child: _isLoading 
                       ? const CircularProgressIndicator(color: Colors.white) 
                       : const Text('Save Settings'),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
