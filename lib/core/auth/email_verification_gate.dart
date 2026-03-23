import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/core/theme/app_theme.dart';

class EmailVerificationGate extends StatefulWidget {
  final Widget child;

  const EmailVerificationGate({super.key, required this.child});

  @override
  State<EmailVerificationGate> createState() => _EmailVerificationGateState();
}

class _EmailVerificationGateState extends State<EmailVerificationGate> {
  bool _isLoading = false;
  bool _isUpdatingEmail = false;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.refreshSession();
      if (res.user?.emailConfirmedAt != null) {
        if (mounted) {
          showSuccessSnackBar(context, 'Email verified successfully!');
        }
      } else {
        if (mounted) {
          showErrorSnackBar(context, 'Email not yet verified. Please check your inbox.');
        }
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email != null) {
        await Supabase.instance.client.auth.resend(
          type: OtpType.signup,
          email: email,
        );
        if (mounted) {
          showSuccessSnackBar(context, 'Verification email resent to $email!');
        }
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      showErrorSnackBar(context, 'Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Update Auth Email
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      // Update Profile Email
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('profiles').update({
          'email': newEmail,
        }).eq('id', userId);
      }

      if (mounted) {
        showSuccessSnackBar(context, 'Email updated! Please check $newEmail for the verification link.');
        setState(() => _isUpdatingEmail = false);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed to update email: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isVerified = user?.emailConfirmedAt != null;

    if (isVerified) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: _logout,
            tooltip: 'Log out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: AppTheme.brandDark,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandDark,
                ),
              ),
              const SizedBox(height: 16),
              
              if (!_isUpdatingEmail) ...[
                Text(
                  'We sent a verification link to:\n\n${user?.email ?? "your email"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("I've Verified — Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isLoading ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Resend Verification Email', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isUpdatingEmail = true;
                      _emailController.text = user?.email ?? '';
                    });
                  },
                  child: const Text(
                    'Incorrect Email? Update it here.',
                    style: TextStyle(color: AppTheme.brandDark, fontWeight: FontWeight.w600),
                  ),
                ),
              ] else ...[
                const Text(
                  'Enter your correct email address below to receive a new verification link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'New Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Update & Send Link", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isUpdatingEmail = false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
