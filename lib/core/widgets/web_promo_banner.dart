import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/features/monetization/models/subscription_tier.dart';
import 'package:needlix/features/monetization/screens/upgrade_screen.dart';

/// Tracks whether the user has dismissed the promo banner this session.
final _webPromoBannerDismissedProvider = StateProvider<bool>((ref) => false);

/// A slim, non-blocking promotional banner shown only on Flutter Web
/// for freemium users. Sits below the BottomNavigationBar so it never
/// obstructs the main content. Dismissable for the rest of the session.
class WebPromoBanner extends ConsumerWidget {
  const WebPromoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show on web
    if (!kIsWeb) return const SizedBox.shrink();

    // Hide if dismissed this session
    final dismissed = ref.watch(_webPromoBannerDismissedProvider);
    if (dismissed) return const SizedBox.shrink();

    // Only show for freemium users
    final tier = ref.watch(profileNotifierProvider).valueOrNull?.subscriptionTier
        ?? SubscriptionTier.freemium;
    if (tier != SubscriptionTier.freemium) return const SizedBox.shrink();

    return _WebPromoBannerContent(
      onDismiss: () =>
          ref.read(_webPromoBannerDismissedProvider.notifier).state = true,
      onUpgrade: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UpgradeScreen()),
      ),
    );
  }
}

class _WebPromoBannerContent extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback onUpgrade;

  const _WebPromoBannerContent({
    required this.onDismiss,
    required this.onUpgrade,
  });

  @override
  State<_WebPromoBannerContent> createState() => _WebPromoBannerContentState();
}

class _WebPromoBannerContentState extends State<_WebPromoBannerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Cycles through a few short messages so it doesn't feel static
  static const _messages = [
    '✂️  Unlock unlimited customers & orders',
    '📄  Generate branded PDF invoices with your logo',
    '💰  Earn 40% commission referring other tailors',
    '🚀  Go Premium — starting at ₦3,000/month',
  ];

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    // Rotate messages every 5 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: const Color(0xFF0A1128), // Needlix navy
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Freemium badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0076B6), Color(0xFF00AEEF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Rotating message
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _messages[_messageIndex],
                        key: ValueKey(_messageIndex),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Upgrade CTA button
                  GestureDetector(
                    onTap: widget.onUpgrade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0076B6), Color(0xFF00AEEF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Dismiss button
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
