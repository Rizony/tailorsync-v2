import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/terms/terms_content.dart';
import 'package:tailorsync_v2/features/auth/repositories/auth_repository.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';

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

  bool _isLoading = false;
  bool _isLogin = true;

  // Signup agreement checkboxes
  bool _agreedToS = false;
  bool _agreedPrivacy = false;

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    // For signup, both boxes must be checked
    if (!_isLogin && (!_agreedToS || !_agreedPrivacy)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy to continue.'),
          backgroundColor: Colors.red,
        ),
      );
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
          data: {'full_name': name.isNotEmpty ? name : 'Shop Owner'},
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please check your email to confirm.')),
          );
          setState(() => _isLogin = true);
          return;
        }
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLegalSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Text(content,
                    style: const TextStyle(height: 1.65, fontSize: 13)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Logo ---
              Image.asset(
                'assets/logo_full.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'TailorSync',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'The OS for modern tailors',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // --- Email / Password Form ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Account',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),

                        // --- T&C Checkboxes (signup only) ---
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          _LegalCheckRow(
                            value: _agreedToS,
                            onChanged: (v) => setState(() => _agreedToS = v ?? false),
                            text: 'I agree to the ',
                            linkText: 'Terms of Service',
                            onLinkTap: () => _showLegalSheet('Terms of Service', kTermsOfService),
                          ),
                          _LegalCheckRow(
                            value: _agreedPrivacy,
                            onChanged: (v) => setState(() => _agreedPrivacy = v ?? false),
                            text: 'I agree to the ',
                            linkText: 'Privacy Policy',
                            onLinkTap: () => _showLegalSheet('Privacy Policy', kPrivacyPolicy),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_isLogin ? 'Login' : 'Sign Up'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Social Login (disabled until production) ---
              // Uncomment below when Google & Facebook OAuth is production-ready
              /*
              _SocialButton(label: 'Continue with Google', ...),
              _SocialButton(label: 'Continue with Facebook', ...),
              */

              const SizedBox(height: 8),

              // --- Switch Login / Sign Up ---
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() {
                          _isLogin = !_isLogin;
                          _agreedToS = false;
                          _agreedPrivacy = false;
                        }),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                      ),
                      TextSpan(
                        text: _isLogin ? 'Sign Up' : 'Login',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
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

/// A single compact agreement checkbox row with a tappable legal link.
class _LegalCheckRow extends StatelessWidget {
  const _LegalCheckRow({
    required this.value,
    required this.onChanged,
    required this.text,
    required this.linkText,
    required this.onLinkTap,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: Checkbox(value: value, onChanged: onChanged, visualDensity: VisualDensity.compact),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(text, style: const TextStyle(fontSize: 12)),
                GestureDetector(
                  onTap: onLinkTap,
                  child: Text(
                    linkText,
                    style: TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
