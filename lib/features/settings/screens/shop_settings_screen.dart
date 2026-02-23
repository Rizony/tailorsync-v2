import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';

class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  ConsumerState<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends ConsumerState<ShopSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _brandNameController; 
  late TextEditingController _taxController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;
  
  // Branding Contact Info
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _socialController;
  
  String _selectedColor = '0xFF1E78D2'; 
  final List<String> _colors = [
    '0xFF1E78D2', // Brand Blue
    '0xFFF58220', // Brand Orange
    '0xFF43A047', // Green
    '0xFFE53935', // Red
    '0xFF5D3FD3', // Purple (Legacy)
    '0xFF000000', // Black
  ];

  String _selectedCurrencyCode = 'NGN';
  final Map<String, String> _currencies = {
    'NGN': '₦', // Naira
    'USD': '\$', // US Dollar
    'GBP': '£', // British Pound
    'EUR': '€', // Euro
    'GHS': '₵', // Ghanaian Cedi
    'KES': 'KSh', // Kenyan Shilling
    'ZAR': 'R', // South African Rand
  };

  File? _logoFile;
  String? _logoUrl;
  
  File? _signatureFile;
  String? _signatureUrl;

  bool _isLoading = false;
  bool _initialized = false; // Tracks whether controllers have been populated

  @override
  void initState() {
    super.initState();
    // Initialize controllers empty — they'll be populated in build() once
    // the profile provider resolves (avoids blank fields on slow connections)
    _shopNameController = TextEditingController();
    _brandNameController = TextEditingController();
    _taxController = TextEditingController();
    _notesController = TextEditingController();
    _termsController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    _socialController = TextEditingController();
  }

  void _populateControllers(dynamic user) {
    if (_initialized || user == null) return;
    _initialized = true;
    _shopNameController.text = user.shopName ?? '';
    _brandNameController.text = user.brandName ?? user.shopName ?? '';
    _taxController.text = user.defaultTaxRate.toString();
    _notesController.text = user.invoiceNotes ?? '';
    _termsController.text = user.termsAndConditions ?? '';
    _addressController.text = user.shopAddress ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _emailController.text = user.email ?? '';
    _websiteController.text = user.website ?? '';
    _socialController.text = user.socialMediaHandle ?? '';
    if (user.accentColor != null) {
      _selectedColor = user.accentColor!;
    }
    _selectedCurrencyCode = user.currencyCode ?? 'NGN';
    if (!_currencies.containsKey(_selectedCurrencyCode)) {
      _selectedCurrencyCode = 'NGN';
    }
    _logoUrl = user.logoUrl;
    _signatureUrl = user.signatureUrl;
    setState(() {});
  }

  String _getCurrencyName(String code) {
      switch (code) {
          case 'NGN': return 'Nigerian Naira';
          case 'USD': return 'US Dollar';
          case 'GBP': return 'British Pound';
          case 'EUR': return 'Euro';
          case 'GHS': return 'Ghanaian Cedi';
          case 'KES': return 'Kenyan Shilling';
          case 'ZAR': return 'South African Rand';
          default: return '';
      }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _brandNameController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _socialController.dispose();
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
      final storagePath = 'shop_assets/$fileName'; 
      
      await supabase.storage.from('app-assets').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      return supabase.storage.from('app-assets').getPublicUrl(storagePath);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Upload failed: $e');
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
      
      final currentUser = ref.read(profileNotifierProvider).valueOrNull;
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
          
          shopAddress: _addressController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text,
          website: _websiteController.text,
          socialMediaHandle: _socialController.text,
          
          currencyCode: _selectedCurrencyCode,
          currencySymbol: _currencies[_selectedCurrencyCode] ?? '₦',
        );
        
        await ref.read(profileNotifierProvider.notifier).updateProfile(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _parseColor(String colorString) {
    try {
      // Remove any leading '#' or '0x'
      String hex = colorString.replaceAll('#', '').replaceAll('0x', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if missing
      }
      return int.parse(hex, radix: 16);
    } catch (e) {
      return 0xFF1E78D2; // Default brand blue on error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Populate controllers as soon as profile data is available (once only)
    final profileAsync = ref.watch(profileNotifierProvider);
    profileAsync.whenData((user) => _populateControllers(user));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shop Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Branding Card ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('SHOP BRANDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _shopNameController,
                        decoration: const InputDecoration(labelText: 'Shop Name', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _brandNameController,
                        decoration: const InputDecoration(labelText: 'Brand Name (for Invoices)', border: OutlineInputBorder(), hintText: 'Same as Shop Name if empty'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Logo', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _pickImage(true),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey.shade100,
                                    backgroundImage: _logoFile != null 
                                        ? FileImage(_logoFile!) 
                                        : (_logoUrl != null ? NetworkImage(_logoUrl!) as ImageProvider : null),
                                    child: (_logoFile == null && _logoUrl == null) ? const Icon(Icons.add_a_photo, color: Colors.grey) : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Signature', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _pickImage(false),
                                  child: Container(
                                    height: 80,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      image: _signatureFile != null 
                                          ? DecorationImage(image: FileImage(_signatureFile!), fit: BoxFit.cover)
                                          : (_signatureUrl != null ? DecorationImage(image: NetworkImage(_signatureUrl!), fit: BoxFit.cover) : null),
                                    ),
                                    child: (_signatureFile == null && _signatureUrl == null) 
                                        ? const Center(child: Icon(Icons.draw, color: Colors.grey)) 
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 1.6 Regional Settings ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('REGIONAL SETTINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              const Text('Currency', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                          value: _selectedCurrencyCode,
                                          isExpanded: true,
                                          items: _currencies.entries.map((entry) {
                                              return DropdownMenuItem<String>(
                                                  value: entry.key,
                                                  child: Text('${entry.key} (${entry.value}) - ${_getCurrencyName(entry.key)}'),
                                              );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                  setState(() {
                                                      _selectedCurrencyCode = newValue;
                                                  });
                                              }
                                          },
                                      ),
                                  ),
                              ),
                          ],
                      ),
                  ),
              ),
              const SizedBox(height: 24),
              
              // --- 1.5 Contact & Socials Card ---
               const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('CONTACT & SOCIALS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Shop Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined)),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(labelText: 'Website', border: OutlineInputBorder(), prefixIcon: Icon(Icons.language_outlined)),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _socialController,
                        decoration: const InputDecoration(labelText: 'Social Media (e.g. @tailorsync, IG: @mystore)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.share_outlined)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // --- 2. Invoice Theme Card ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('INVOICE THEME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _colors.length,
                          itemBuilder: (context, index) {
                            final colorHex = _colors[index];
                            final color = Color(_parseColor(colorHex));
                            final isSelected = _selectedColor == colorHex;
                            
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = colorHex),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                                ),
                                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // --- 3. Financials & Terms Card ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('FINANCIALS & TERMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _taxController,
                        decoration: const InputDecoration(labelText: 'Default Tax Rate (%)', border: OutlineInputBorder(), suffixText: '%'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Instructions / Bank Details', 
                          border: OutlineInputBorder(), 
                          hintText: 'e.g. Please pay into GTBank: 0123456789',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _termsController,
                        decoration: const InputDecoration(
                          labelText: 'Terms & Conditions', 
                          border: OutlineInputBorder(), 
                          hintText: 'e.g. No refunds after 7 days.',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // FIXED: Prevent clicking when loading
                  onPressed: _isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color(_parseColor(_selectedColor)), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
