import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/terms/terms_content.dart';
import 'package:tailorsync_v2/core/terms/terms_service.dart';
import 'package:tailorsync_v2/features/auth/repositories/auth_repository.dart';

/// Blocks access to [child] until the current user has accepted the T&Cs.
/// Existing users who have never agreed are shown the full-screen agreement.
/// Declining signs them out and returns them to the login screen.
class TermsGate extends ConsumerStatefulWidget {
  const TermsGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<TermsGate> createState() => _TermsGateState();
}

class _TermsGateState extends ConsumerState<TermsGate> {
  bool? _accepted; // null = loading, true = accepted, false = show T&C
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkAcceptance();
  }

  Future<void> _checkAcceptance() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _accepted = false);
      return;
    }
    final accepted = await TermsService.hasAcceptedTerms(uid);
    if (mounted) setState(() => _accepted = accepted);
  }

  Future<void> _onAccept() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _isProcessing = true);
    await TermsService.markTermsAccepted(uid);
    if (mounted) setState(() => _accepted = true);
  }

  Future<void> _onDecline() async {
    setState(() => _isProcessing = true);
    await ref.read(authRepositoryProvider.notifier).signOut();
    // AuthGate will react to the session change and show LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    // Loading check
    if (_accepted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Already accepted — show app
    if (_accepted == true) return widget.child;

    // Show full-screen T&C
    return _TermsScreen(
      isProcessing: _isProcessing,
      onAccept: _onAccept,
      onDecline: _onDecline,
    );
  }
}

class _TermsScreen extends StatefulWidget {
  const _TermsScreen({
    required this.isProcessing,
    required this.onAccept,
    required this.onDecline,
  });

  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<_TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<_TermsScreen> {
  bool _agreedToS = false;
  bool _agreedPrivacy = false;
  bool _showingPrivacy = false; // toggle between ToS and Privacy view

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canAccept = _agreedToS && _agreedPrivacy;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => setState(() => _showingPrivacy = !_showingPrivacy),
            child: Text(
              _showingPrivacy ? 'View T&C' : 'Privacy Policy',
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _TabBtn(
                  label: 'Terms of Service',
                  selected: !_showingPrivacy,
                  onTap: () => setState(() => _showingPrivacy = false),
                ),
                _TabBtn(
                  label: 'Privacy Policy',
                  selected: _showingPrivacy,
                  onTap: () => setState(() => _showingPrivacy = true),
                ),
              ],
            ),
          ),

          // Scrollable document text
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _showingPrivacy ? kPrivacyPolicy : kTermsOfService,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.65),
              ),
            ),
          ),

          // Divider + checkboxes + buttons
          const Divider(height: 1),
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AgreementRow(
                  value: _agreedToS,
                  onChanged: (v) => setState(() => _agreedToS = v ?? false),
                  text: 'I have read and agree to the ',
                  linkText: 'Terms of Service',
                  onLinkTap: () => setState(() => _showingPrivacy = false),
                ),
                _AgreementRow(
                  value: _agreedPrivacy,
                  onChanged: (v) => setState(() => _agreedPrivacy = v ?? false),
                  text: 'I have read and agree to the ',
                  linkText: 'Privacy Policy',
                  onLinkTap: () => setState(() => _showingPrivacy = true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.isProcessing ? null : widget.onDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade300),
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Decline & Sign Out',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (canAccept && !widget.isProcessing)
                            ? widget.onAccept
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: widget.isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('I Agree & Continue',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
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
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(text: text),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
