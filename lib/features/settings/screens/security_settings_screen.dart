import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/auth/app_lock_gate.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPinController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscurePin = true;

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      showErrorSnackBar(context, 'Please provide a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      if (mounted) {
        showSuccessSnackBar(context, 'Verification links sent to both old and new emails. Please verify to confirm the change.');
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    final oldPassword = _passwordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      showErrorSnackBar(context, 'Please fill in both password fields');
      return;
    }

    if (newPassword.length < 6) {
      showErrorSnackBar(context, 'New password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) throw 'User email not found';

      // Re-authenticate
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      // Update password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        showSuccessSnackBar(context, 'Password updated successfully!');
        _passwordController.clear();
        _newPasswordController.clear();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed to update password. Check your old password.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePin() async {
    final newPin = _newPinController.text.trim();
    if (newPin.length != 4 || int.tryParse(newPin) == null) {
      showErrorSnackBar(context, 'PIN must be exactly 4 digits');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not found';

      await Supabase.instance.client.from('profiles').update({
        'withdrawal_pin': newPin,
      }).eq('id', userId);

      if (mounted) {
        showSuccessSnackBar(context, 'Withdrawal PIN secured successfully.');
        _newPinController.clear();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed to set PIN: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isVerified = user?.emailConfirmedAt != null;
    final appLockEnabled = ref.watch(appLockEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Setup device security
            _buildSectionHeader('Device Protection'),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Biometric App Lock', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Require FaceID/TouchID after 1 min of inactivity to protect your business.'),
                value: appLockEnabled,
                onChanged: (val) async {
                  if (val) {
                    final LocalAuthentication auth = LocalAuthentication();
                    final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
                    if (!canAuthenticate && context.mounted) {
                      showErrorSnackBar(context, 'Biometrics not supported or setup on this device.');
                      return;
                    }
                  }
                  ref.read(appLockEnabledProvider.notifier).toggle(val);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Account Basics
            _buildSectionHeader('Account Email'),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                leading: Icon(
                  isVerified ? Icons.mark_email_read : Icons.warning_amber_rounded,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                title: Text(user?.email ?? 'Unknown Email', style: AppTypography.label),
                subtitle: Text(isVerified ? 'Verified' : 'Unverified - Action Required', style: TextStyle(color: isVerified ? Colors.green : Colors.orange)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (!isVerified) ...[
                          PrimaryButton(
                            onPressed: () async {
                              try {
                                await Supabase.instance.client.auth.resend(type: OtpType.signup, email: user!.email!);
                                if (context.mounted) showSuccessSnackBar(context, 'Verification email sent!');
                              } catch (e) {
                                if (context.mounted) showErrorSnackBar(context, e);
                              }
                            },
                            text: 'Resend Verification Email',
                            isSecondary: true,
                          ),
                          const SizedBox(height: 16),
                        ],
                        CustomTextField(
                          controller: _emailController,
                          label: 'New Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onPressed: _isLoading ? null : _updateEmail,
                          text: 'Change Email',
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Password Settings
            _buildSectionHeader('Authentication'),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                leading: const Icon(Icons.password, color: Colors.blue),
                title: const Text('Change Password', style: AppTypography.label),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Current Password',
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
                          obscureText: _obscureNew,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onPressed: _isLoading ? null : _updatePassword,
                          text: 'Update Password',
                          isLoading: _isLoading,
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await Supabase.instance.client.auth.resetPasswordForEmail(user!.email!);
                              if (context.mounted) showSuccessSnackBar(context, 'Password reset link sent to your email.');
                            } catch (e) {
                              if (context.mounted) showErrorSnackBar(context, 'Failed to send reset link.');
                            }
                          }, 
                          child: const Text('Forgot Current Password? Send Reset Link')
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Financial Security
            _buildSectionHeader('Wallet Security'),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                leading: const Icon(Icons.dialpad, color: Colors.purple),
                title: const Text('Escrow Withdrawal PIN', style: AppTypography.label),
                subtitle: const Text('Manage 4-digit master PIN for payouts.'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Your 4-digit PIN is required to transfer funds out of Escrow. Never share this PIN.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _newPinController,
                          label: 'Enter 4-Digit PIN',
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: _obscurePin,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePin = !_obscurePin),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onPressed: _isLoading ? null : _updatePin,
                          text: 'Set / Update PIN',
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }
}
