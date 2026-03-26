import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/theme/app_colors.dart';

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
            Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('Verification Status', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 8),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(
                  isVerified ? Icons.verified : Icons.warning_amber_rounded,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                title: Text(isVerified ? 'Email Verified' : 'Email Unverified', style: AppTypography.label),
                subtitle: Text(user?.email ?? '', style: AppTypography.bodySmall),
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
            Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('Change Password', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 8),
            PremiumCard(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: _obscureOld,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    obscureText: _obscureNew,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.check_circle_outline),
                    obscureText: _obscureNew,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    isLoading: _isLoading,
                    text: 'Update Password',
                    icon: Icons.security_outlined,
                  ),
                ],
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
