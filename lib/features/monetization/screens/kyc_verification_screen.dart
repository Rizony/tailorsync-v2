import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  bool _loading = true;
  String _kycStatus = 'none';
  bool _uploading = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKycStatus();
  }

  Future<void> _fetchKycStatus() async {
    setState(() => _loading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from('profiles')
          .select('is_kyc_verified, kyc_status, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        if (res['is_kyc_verified'] == true) {
          _kycStatus = 'verified';
        } else {
          _kycStatus = res['kyc_status'] ?? 'none';
        }
        if (res['full_name'] != null) {
          _nameController.text = res['full_name'];
        }
      }
    } catch (e) {
      debugPrint("Error fetching KYC: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return;

    setState(() => _uploading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '${user.id}/$fileName';

      await Supabase.instance.client.storage
          .from('kyc-documents')
          .uploadBinary(path, fileBytes, fileOptions: FileOptions(contentType: 'image/$fileExt'));

      final publicUrl = Supabase.instance.client.storage
          .from('kyc-documents')
          .getPublicUrl(path);

      await Supabase.instance.client.from('profiles').update({
        'kyc_document_url': publicUrl,
        'kyc_status': 'pending',
        'full_name': _nameController.text.trim(),
      }).eq('id', user.id);

      setState(() => _kycStatus = 'pending');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Document uploaded successfully.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmailVerified = Supabase.instance.client.auth.currentUser?.emailConfirmedAt != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildHeader(isEmailVerified),
              const SizedBox(height: 32),
              if (!isEmailVerified)
                _buildEmailVerificationWarning()
              else if (_kycStatus == 'verified')
                _buildVerifiedState()
              else if (_kycStatus == 'pending')
                _buildPendingState()
              else if (_kycStatus == 'rejected')
                _buildUploadForm(isRejected: true)
              else 
                _buildUploadForm(isRejected: false),
                
              const SizedBox(height: 48),
              const Text('TailorSync protects your data using bank-grade encryption.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
    );
  }

  Widget _buildHeader(bool isEmailVerified) {
    final isVerified = _kycStatus == 'verified';
    final iconColor = (isVerified && isEmailVerified) ? Colors.green : AppColors.primary;

    return Column(
      children: [
        Icon(isVerified ? Icons.verified : Icons.admin_panel_settings_outlined, size: 80, color: iconColor),
        const SizedBox(height: 16),
        Text(isVerified ? 'You correspond to verified identity! ✅' : 'Tailor Trust & Safety', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          isVerified 
            ? 'Your account is in good standing and Escrow payouts are enabled.'
            : 'We must verify your identity. Upload a valid Government ID (Passport, Driver\'s License, or NIN).',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationWarning() {
    return PremiumCard(
      child: Column(
        children: [
          const Icon(Icons.mark_email_unread_outlined, color: Colors.orange, size: 40),
          const SizedBox(height: 12),
          const Text('Email Verification Required', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Please verify your email address to proceed with identity verification.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () async {
              try {
                final email = Supabase.instance.client.auth.currentUser?.email;
                if (email != null) {
                  await Supabase.instance.client.auth.resend(type: OtpType.signup, email: email);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification resend link sent!')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            text: 'Resend Verification Email',
          ),
        ],
      ),
    );
  }

  Widget _buildUploadForm({required bool isRejected}) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRejected) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Your previous document was rejected. Please ensure the image is clear and matches the legal name.', style: TextStyle(color: Colors.red, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          CustomTextField(
            controller: _nameController,
            label: 'Legal Full Name',
            prefixIcon: const Icon(Icons.person_outline),
            hintText: 'As it appears on your ID',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: _uploading ? null : _pickAndUpload,
            isLoading: _uploading,
            text: isRejected ? 'Re-upload Document' : 'Upload Document',
            icon: Icons.upload_file,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    return PremiumCard(
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, color: Colors.amber, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Review in Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Your ID document has been submitted and is currently under review by our team.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedState() {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Complete', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('You are securely established. Escrow payouts are unlocked.', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
