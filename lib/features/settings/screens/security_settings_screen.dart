import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/utils/snackbar_util.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  Future<void> _updatePassword() async {
    final oldPassword = _passwordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      showErrorSnackBar(context, 'Please fill in all password fields');
      return;
    }

    if (newPassword != confirmPassword) {
      showErrorSnackBar(context, 'New passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      showErrorSnackBar(context, 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) throw 'User email not found';

      // 1. Re-authenticate to verify old password
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      // 2. Update to new password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        showSuccessSnackBar(context, 'Password updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to update password. Check your old password.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isVerified = user?.emailConfirmedAt != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Verification Status ---
            const Text('Verification Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  isVerified ? Icons.verified : Icons.warning_amber_rounded,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                title: Text(isVerified ? 'Email Verified' : 'Email Unverified'),
                subtitle: Text(user?.email ?? ''),
                trailing: isVerified 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : TextButton(
                      onPressed: () async {
                        try {
                          await Supabase.instance.client.auth.resend(type: OtpType.signup, email: user!.email!);
                          if (!context.mounted) return;
                          showSuccessSnackBar(context, 'Verification email sent!');
                        } catch (e) {
                          if (!context.mounted) return;
                          showErrorSnackBar(context, e);
                        }
                      },
                      child: const Text('Verify Now'),
                    ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Change Password ---
            const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureOld,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureOld = !_obscureOld),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureNew,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePassword,
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Update Password'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'Protect your account by using a strong password and verified email.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
