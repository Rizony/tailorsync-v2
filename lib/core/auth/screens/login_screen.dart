import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:needlix/core/terms/terms_content.dart';
import 'package:needlix/features/auth/repositories/auth_repository.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/core/auth/screens/forgot_password_screen.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenStateV2();
}

class _LoginScreenStateV2 extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;

  bool _agreedToS = false;
  bool _agreedPrivacy = false;

  bool _obscurePassword = true;

  String _getFirebaseErrorTranslation(String errorMsg) {
    if (errorMsg.contains('Invalid login credentials')) return 'Invalid email or password.';
    if (errorMsg.contains('User already registered')) return 'This email is already in use.';
    if (errorMsg.contains('Password should be at least')) return 'Password is too weak.';
    return errorMsg.replaceAll('Exception: ', '').replaceAll('AuthException(', '').split(')').first;
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && (!_agreedToS || !_agreedPrivacy)) {
      showErrorSnackBar(context, 'Please agree to the Terms of Service & Privacy Policy.');
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      if (_isLogin) {
        await ref.read(authRepositoryProvider.notifier).signInWithEmailPassword(
          email: email,
          password: password,
        );
      } else {
        await ref.read(authRepositoryProvider.notifier).signUp(
          email: email,
          password: password,
          data: {
            'full_name': name.isNotEmpty ? name : 'Shop Owner',
            if (_referralCodeController.text.trim().isNotEmpty) 'referred_by': _referralCodeController.text.trim(),
          },
        );
        if (mounted) {
          showSuccessSnackBar(context, 'Success! Please verify your email via the link sent to your inbox.');
          setState(() {
            _isLogin = true;
            _passwordController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final errString = e.toString().toLowerCase();
        if (errString.contains('failed host lookup') || errString.contains('socketexception')) {
          showErrorSnackBar(context, 'No internet connection.');
        } else {
          showErrorSnackBar(context, _getFirebaseErrorTranslation(e.toString()));
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              Center(
                child: Image.asset(
                  'assets/logo_full.png',
                  height: 100,
                  errorBuilder: (_, __, ___) => const Text('NEEDLIX', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect & Create',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Tab Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AuthTab(title: 'Login', isActive: _isLogin, onTap: () => setState(() => _isLogin = true)),
                  const SizedBox(width: 16),
                  _AuthTab(title: 'Sign Up', isActive: !_isLogin, onTap: () => setState(() => _isLogin = false)),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              PremiumCard(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isLogin) ...[
                        CustomTextField(controller: _nameController, label: 'Full Name', prefixIcon: const Icon(Icons.person)),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: const Text('Recover Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        CustomTextField(controller: _referralCodeController, label: 'Referral Code (Optional)'),
                        const SizedBox(height: 16),
                        _LegalCheckRow(
                          value: _agreedToS,
                          onChanged: (v) => setState(() => _agreedToS = v ?? false),
                          text: 'I agree to the ',
                          linkText: 'Terms of Service',
                          onLinkTap: () => _showLegalDialog('Terms of Service', kTermsOfService),
                        ),
                        _LegalCheckRow(
                          value: _agreedPrivacy,
                          onChanged: (v) => setState(() => _agreedPrivacy = v ?? false),
                          text: 'I agree to the ',
                          linkText: 'Privacy Policy',
                          onLinkTap: () => _showLegalDialog('Privacy Policy', kPrivacyPolicy),
                        ),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        isLoading: _isLoading,
                        text: _isLogin ? 'Secure Login' : 'Create Account',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  const _AuthTab({required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? AppColors.primary : Colors.grey)),
          const SizedBox(height: 4),
          if (isActive) Container(height: 3, width: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))
          else const SizedBox(height: 3),
        ],
      ),
    );
  }
}

class _LegalCheckRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const _LegalCheckRow({required this.value, required this.onChanged, required this.text, required this.linkText, required this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(height: 32, child: Checkbox(value: value, onChanged: onChanged)),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(text, style: const TextStyle(fontSize: 12)),
                GestureDetector(
                  onTap: onLinkTap,
                  child: Text(linkText, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
