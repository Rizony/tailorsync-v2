import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/premium_card.dart';

class SupportListScreen extends StatelessWidget {
  const SupportListScreen({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    // Developers can update this number to their actual support line
    const phoneNumber = '+2348000000000'; 
    const message = 'Hello TailorSync Support, I need help with my account.';
    
    final uri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp. Please ensure it is installed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'We are here to help!',
                  style: AppTypography.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Our support team is available on WhatsApp to assist you with any issues or questions you might have.',
                  style: AppTypography.body.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  onPressed: () => _openWhatsApp(context),
                  text: 'Chat on WhatsApp',
                  icon: Icons.send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
