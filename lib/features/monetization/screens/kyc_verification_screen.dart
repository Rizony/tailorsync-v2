import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/theme/app_theme.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  bool _loading = true;
  bool _isVerified = false;
  bool _uploading = false;
  String? _documentUrl;
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
          .select('is_kyc_verified, kyc_document_url')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        _isVerified = res['is_kyc_verified'] == true;
        _documentUrl = res['kyc_document_url'];
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

      _documentUrl = publicUrl;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Document uploaded successfully! Pending Admin approval.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e'), backgroundColor: Colors.red),
        );
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Identity Verification', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    (_isVerified && isEmailVerified) ? Icons.verified : Icons.admin_panel_settings_outlined,
                    size: 80,
                    color: (_isVerified && isEmailVerified) ? Colors.green : AppTheme.brandDark,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    (_isVerified && isEmailVerified) ? 'You are Verified! ✅' : 'Tailor Trust & Safety',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (_isVerified && isEmailVerified)
                      ? 'Your identity has been verified by the Needlix Admin team. You now have the blue verified badge on your marketplace profile.'
                      : (!isEmailVerified) 
                          ? 'You must verify your email address before you can upload identity documents.'
                          : 'To build trust with clients and enable Escrow withdrawals, you need to verify your identity. Please upload a valid Government ID (Passport, Driver\'s License, or NIN).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 48),

                  if (!isEmailVerified)
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.orange.shade50,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.orange.shade200),
                       ),
                       child: Column(
                         children: [
                           const Icon(Icons.mark_email_unread_outlined, color: Colors.orange, size: 40),
                           const SizedBox(height: 12),
                           const Text(
                             'Email Verification Required',
                             style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                           ),
                           const SizedBox(height: 8),
                           const Text(
                             'Please check your inbox and verify your email address to proceed with identity verification.',
                             textAlign: TextAlign.center,
                             style: TextStyle(color: Colors.black87),
                           ),
                           const SizedBox(height: 16),
                           ElevatedButton(
                             onPressed: () async {
                               try {
                                 final email = Supabase.instance.client.auth.currentUser?.email;
                                 if (email != null) {
                                   await Supabase.instance.client.auth.resend(
                                     type: OtpType.signup,
                                     email: email,
                                   );
                                   if (context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('Verification email resent!')),
                                     );
                                   }
                                 }
                               } catch (e) {
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                   );
                                 }
                               }
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.orange,
                               foregroundColor: Colors.white,
                             ),
                             child: const Text('Resend Verification Email'),
                           ),
                         ],
                       ),
                     )
                  else if (!_isVerified && _documentUrl == null) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name (as on ID)',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'e.g. John Doe',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                  ] else if (_isVerified && isEmailVerified)
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.green.shade50,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.green.shade200),
                       ),
                       child: const Row(
                         children: [
                           Icon(Icons.check_circle, color: Colors.green),
                           SizedBox(width: 12),
                           Expanded(
                             child: Text(
                               'Verification Complete. Your account is in good standing and payouts are fully enabled.',
                               style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                             ),
                           ),
                         ],
                       ),
                     )
                  else if (_documentUrl != null)
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.amber.shade50,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.amber.shade200),
                       ),
                       child: const Row(
                         children: [
                           Icon(Icons.hourglass_top, color: Colors.amber),
                           SizedBox(width: 12),
                           Expanded(
                             child: Text(
                               'Your ID document has been submitted and is currently under review by our Admin team.',
                               style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                             ),
                           ),
                         ],
                       ),
                     )
                  else
                     ElevatedButton.icon(
                       onPressed: _uploading ? null : _pickAndUpload,
                       icon: _uploading 
                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                         : const Icon(Icons.upload_file),
                       label: Text(_uploading ? 'Uploading...' : 'Upload Government ID', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppTheme.brandDark,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                     ),

                  const Spacer(),
                  const Text(
                    'Needlix protects your data using bank-grade encryption.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
