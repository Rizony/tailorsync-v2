import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/features/monetization/screens/upgrade_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:needlix/features/monetization/models/subscription_tier.dart';

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
  late TextEditingController _bioController;
  late TextEditingController _specialtiesController;
  final TextEditingController _portfolioLinkController = TextEditingController();
  
  // Branding Contact Info
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _socialController;
  
  // Withdrawal Settings
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountNameController;
  late TextEditingController _withdrawalPinController;
  
  String _selectedColor = '0xFF1E78D2'; 
  final List<String> _colors = [
    '0xFF1E78D2', // Brand Blue
    '0xFFF58220', // Brand Orange
    '0xFF43A047', // Green
    '0xFFE53935', // Red
    '0xFF0076B6', // Deep Blue (Default)
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

  bool _isAvailable = true;
  bool _publicProfileEnabled = false;
  int _yearsOfExperience = 0;
  bool _isLoading = false;
  bool _initialized = false;
  bool _isUploadingPortfolio = false;
  List<String> _portfolioUrls = [];
  String _tailorType = 'Unisex';
  final List<String> _tailorTypes = ['Male Fashion', 'Female Fashion', 'Unisex'];
  final List<String> _availableSpecialties = ['Bespoke', 'Traditional African', 'Suits', 'Bridal', 'Casual Wear', 'Alterations', 'Native Attire'];
  List<String> _selectedSpecialties = [];

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
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _accountNameController = TextEditingController();
    _withdrawalPinController = TextEditingController();
    _bioController = TextEditingController();
    _specialtiesController = TextEditingController();
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
    _bankNameController.text = user.bankName ?? '';
    _accountNumberController.text = user.accountNumber ?? '';
    _accountNameController.text = user.accountName ?? '';
    _withdrawalPinController.text = user.withdrawalPin ?? '';
    if (user.accentColor != null) {
      _selectedColor = user.accentColor!;
    }
    _selectedCurrencyCode = user.currencyCode ?? 'NGN';
    if (!_currencies.containsKey(_selectedCurrencyCode)) {
      _selectedCurrencyCode = 'NGN';
    }
    _logoUrl = user.logoUrl;
    _signatureUrl = user.signatureUrl;
    _isAvailable = user.isAvailable;
    _publicProfileEnabled = user.publicProfileEnabled;
    _yearsOfExperience = user.yearsOfExperience;
    _bioController.text = user.bio ?? '';
    
    _tailorType = user.tailorType ?? 'Unisex';
    // Backwards compatibility matching
    if (_tailorType == 'Male') _tailorType = 'Male Fashion';
    if (_tailorType == 'Female') _tailorType = 'Female Fashion';
    if (!_tailorTypes.contains(_tailorType)) _tailorType = 'Unisex';
    
    final existingSpecialties = List<String>.from(user.specialties ?? const []);
    _selectedSpecialties = existingSpecialties.where((s) => _availableSpecialties.contains(s)).toList();
    final otherSpecialties = existingSpecialties.where((s) => !_availableSpecialties.contains(s)).toList();
    _specialtiesController.text = otherSpecialties.join(', ');
    
    _portfolioUrls = List<String>.from(user.portfolioUrls ?? const <String>[]);
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
    
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _withdrawalPinController.dispose();
    _bioController.dispose();
    _specialtiesController.dispose();
    _portfolioLinkController.dispose();
    super.dispose();
  }

  Future<void> _addPortfolioFromGallery() async {
    try {
      setState(() => _isUploadingPortfolio = true);
      final picker = ImagePicker();
      final files = await picker.pickMultiImage(imageQuality: 75);
      if (files.isEmpty) return;

      final uploaded = <String>[];
      for (final f in files) {
        final file = File(f.path);
        final url = await _uploadImage(file, 'portfolio_${DateTime.now().millisecondsSinceEpoch}.jpg');
        if (url != null) uploaded.add(url);
      }

      if (uploaded.isNotEmpty && mounted) {
        setState(() {
          final next = [..._portfolioUrls];
          for (final u in uploaded) {
            if (!next.contains(u)) next.add(u);
          }
          _portfolioUrls = next;
        });
        showSuccessSnackBar(context, 'Added ${uploaded.length} portfolio image(s).');
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Portfolio upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPortfolio = false);
    }
  }

  void _addPortfolioLink() {
    final link = _portfolioLinkController.text.trim();
    if (link.isEmpty) return;
    setState(() {
      if (!_portfolioUrls.contains(link)) _portfolioUrls = [..._portfolioUrls, link];
      _portfolioLinkController.clear();
    });
  }

  void _removePortfolioUrl(String url) {
    setState(() {
      _portfolioUrls = _portfolioUrls.where((u) => u != url).toList();
    });
  }

  Future<void> _pickImage(bool isLogo) async {
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    if (profile?.subscriptionTier == 'freemium') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Premium Feature', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Custom Shop Branding & Logos are only available on Standard and Premium plans. Upgrade to unlock this feature!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradeScreen()));
              },
              child: const Text('View Plans'),
            ),
          ],
        ),
      );
      return;
    }

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
        double? lat = currentUser.latitude;
        double? lng = currentUser.longitude;
        if (_addressController.text.isNotEmpty && _addressController.text != currentUser.shopAddress) {
          try {
            final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=' + Uri.encodeComponent(_addressController.text) + '&format=json&limit=1');
            final response = await http.get(uri).timeout(const Duration(seconds: 5));
            if (response.statusCode == 200) {
              final data = json.decode(response.body) as List;
              if (data.isNotEmpty) {
                lat = double.tryParse(data[0]['lat'].toString());
                lng = double.tryParse(data[0]['lon'].toString());
              }
            }
          } catch (_) {}
        }
        
        final otherSpecialties = _specialtiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        final finalSpecialties = {..._selectedSpecialties, ...otherSpecialties}.toList();
        
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
          
          bankName: _bankNameController.text,
          accountNumber: _accountNumberController.text,
          accountName: _accountNameController.text,
          withdrawalPin: _withdrawalPinController.text,
          
          currencyCode: _selectedCurrencyCode,
          currencySymbol: _currencies[_selectedCurrencyCode] ?? '₦',
          isAvailable: _isAvailable,
          publicProfileEnabled: _publicProfileEnabled,
          yearsOfExperience: _yearsOfExperience,
          bio: _bioController.text,
          tailorType: _tailorType,
          latitude: lat,
          longitude: lng,
          specialties: finalSpecialties,
          portfolioUrls: _portfolioUrls,
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
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('SHOP BRANDING', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _shopNameController,
                      label: 'Shop Name',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _brandNameController,
                      label: 'Brand Name (for Invoices)',
                      hintText: 'Same as Shop Name if empty',
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
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 3),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey.shade100,
                                        backgroundImage: _logoFile != null 
                                            ? FileImage(_logoFile!) 
                                            : (_logoUrl != null ? NetworkImage(_logoUrl!) as ImageProvider : null),
                                        child: (_logoFile == null && _logoUrl == null) ? const Icon(Icons.add_a_photo, color: Colors.grey) : null,
                                      ),
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
              const SizedBox(height: 24),

              // --- 1.6 Regional Settings ---
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('REGIONAL SETTINGS', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Currency', style: AppTypography.label),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrencyCode,
                          isExpanded: true,
                          items: _currencies.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                '${entry.key} (${entry.value}) - ${_getCurrencyName(entry.key)}',
                                style: AppTypography.body,
                              ),
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
              const SizedBox(height: 24),
              
              // --- 1.5 Contact & Socials Card ---
               Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('CONTACT & SOCIALS', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _addressController,
                      label: 'Shop Address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _websiteController,
                      label: 'Website',
                      prefixIcon: const Icon(Icons.language_outlined),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _socialController,
                      label: 'Social Media',
                      hintText: 'e.g. @NEEDLIX, IG: @mystore',
                      prefixIcon: const Icon(Icons.share_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // --- 2. Invoice Theme Card ---
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('INVOICE THEME', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accent Color', style: AppTypography.label),
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
                                border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
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
              const SizedBox(height: 24),
              
              // --- 3. Financials & Terms Card ---
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('FINANCIALS & TERMS', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _taxController,
                      label: 'Default Tax Rate (%)',
                      suffixText: '%',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _notesController,
                      label: 'Payment Instructions / Bank Details',
                      hintText: 'e.g. Please pay into GTBank: 0123456789',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _termsController,
                      label: 'Terms & Conditions',
                      hintText: 'e.g. No refunds after 7 days.',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- 4. Withdrawal Bank Details ---
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('WITHDRAWAL SETTINGS', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _bankNameController,
                      label: 'Bank Name',
                      prefixIcon: const Icon(Icons.account_balance_outlined),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _accountNumberController,
                      label: 'Account Number',
                      prefixIcon: const Icon(Icons.tag_outlined),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _accountNameController,
                      label: 'Account Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _withdrawalPinController,
                      label: 'Secure Withdrawal PIN (4 Digits)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Create a 4-digit PIN to secure withdrawals',
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- 5. Marketplace Profile Card ---
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('MARKETPLACE PROFILE', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      SwitchListTile(
                        title: const Text('Enable Public Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('List your shop on the Needlix web marketplace'),
                        value: _publicProfileEnabled,
                        onChanged: (val) => setState(() => _publicProfileEnabled = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_publicProfileEnabled) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            final userId = Supabase.instance.client.auth.currentUser?.id;
                            if (userId != null) {
                              final link = 'https://needlix.org/tailor/$userId';
                              SharePlus.instance.share(ShareParams(
                                text: 'Check out my tailoring profile on Needlix! 🧵\n$link',
                                subject: 'My Professional Profile',
                              ));
                            }
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share My Public Profile Link'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Portfolio / Showroom', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload or add links to your best work. This appears on your public profile and showroom.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        if (_portfolioUrls.isNotEmpty) ...[
                          SizedBox(
                            height: 92,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _portfolioUrls.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final url = _portfolioUrls[i];
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        width: 120,
                                        height: 92,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 120,
                                          height: 92,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image_outlined),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: InkWell(
                                        onTap: () => _removePortfolioUrl(url),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: _isUploadingPortfolio ? null : _addPortfolioFromGallery,
                          icon: _isUploadingPortfolio
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.photo_library_outlined, size: 18),
                          label: Text(_isUploadingPortfolio ? 'Uploading...' : 'Add photos'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _portfolioLinkController,
                                label: 'Add image link',
                              ),
                            ),
                            const SizedBox(width: 10),
                            PrimaryButton(
                              onPressed: _addPortfolioLink,
                              text: 'Add',
                              width: 80,
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Accepting Job Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Allow customers to send you inquiries'),
                        value: _isAvailable,
                        onChanged: (val) => setState(() => _isAvailable = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _bioController,
                        label: 'Professional Bio', 
                        hintText: 'Tell customers about your craftsmanship...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Text('Tailor Type', style: AppTypography.label),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _tailorType,
                            isExpanded: true,
                            items: _tailorTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type, style: AppTypography.body),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _tailorType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Specialties', style: AppTypography.label),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _availableSpecialties.map((specialty) {
                          final isSelected = _selectedSpecialties.contains(specialty);
                          return FilterChip(
                            label: Text(specialty, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSpecialties.add(specialty);
                                } else {
                                  _selectedSpecialties.removeWhere((String name) => name == specialty);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _specialtiesController,
                        label: 'Other Specialties', 
                        hintText: 'e.g. Vintage, Embroidery...',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Years of Experience:', style: AppTypography.label),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Slider(
                              value: _yearsOfExperience.toDouble(),
                              min: 0,
                              max: 30,
                              divisions: 30,
                              label: _yearsOfExperience.toString(),
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.primary.withValues(alpha: 0.1),
                              onChanged: (val) => setState(() => _yearsOfExperience = val.toInt()),
                            ),
                          ),
                          Text('$_yearsOfExperience', style: AppTypography.label),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // --- Save Button ---
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: _isLoading ? null : _saveSettings,
                isLoading: _isLoading,
                text: 'Save All Settings',
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
