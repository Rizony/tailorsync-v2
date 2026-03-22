import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/theme/app_theme.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  bool _loading = true;
  bool _uploading = false;
  bool _isVerified = false;
  String? _documentUrl;

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
      }
    } catch (e) {
      debugPrint("Error fetching KYC: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _simulateUpload() async {
    // In a real app, use image_picker and supabase storage.
    // For this demonstration, we'll simulate a successful upload.
    setState(() => _uploading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      const mockUrl = "https://example.com/mock-kyc-document.jpg";
      
      await Supabase.instance.client.from('profiles').update({
        'kyc_document_url': mockUrl,
      }).eq('id', user.id);

      _documentUrl = mockUrl;
      
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
  Widget build(BuildContext context) {
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
                    _isVerified ? Icons.verified : Icons.admin_panel_settings_outlined,
                    size: 80,
                    color: _isVerified ? Colors.green : AppTheme.brandDark,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isVerified ? 'You are Verified! ✅' : 'Tailor Trust & Safety',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isVerified 
                      ? 'Your identity has been verified by the Needlix Admin team. You now have the blue verified badge on your marketplace profile.'
                      : 'To build trust with clients and enable Escrow withdrawals, you need to verify your identity. Please upload a valid Government ID (Passport, Driver\'s License, or NIN).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 48),

                  if (_isVerified)
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
                       onPressed: _uploading ? null : _simulateUpload,
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
