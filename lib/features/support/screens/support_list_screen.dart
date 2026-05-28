import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/theme/components/primary_button.dart';
import 'package:needlix/core/theme/components/premium_card.dart';

class SupportListScreen extends StatelessWidget {
  const SupportListScreen({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    const phoneNumber = '+2348141500086'; 
    const message = 'Hi Needlix Support! 👋\\n\\nI need some help navigating the app. My shop name is: [Enter Shop Name].\\n\\nHere is what I need help with:\\n';
    
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connect with Support Card
            PremiumCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We are here to help! 🙌',
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reach out directly to our friendly customer success team on WhatsApp. We typically respond within minutes.',
                    style: AppTypography.body.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: () => _openWhatsApp(context),
                    text: 'Chat with Needlix Support',
                    icon: Icons.forum_rounded,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // FAQs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Frequently Asked Questions',
                style: AppTypography.h3.copyWith(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildFaqItem(
              question: 'How do I add a new customer?',
              answer: 'Go to the "Customers" tab and tap the + icon in the top right. Fill out their details and measurements, then tap Save.',
            ),
            _buildFaqItem(
              question: 'How do I log a new order/job?',
              answer: 'Navigate to the "Orders" tab and tap the + icon. Assign it to a customer, specify the outfit type, total cost, and deadline.',
            ),
            _buildFaqItem(
              question: 'What happens if I work offline?',
              answer: 'Needlix handles offline mode seamlessly! Any customers or orders you add without internet will be automatically synced securely to your account once you connect to a network.',
            ),
            _buildFaqItem(
              question: 'How does the referral program work?',
              answer: 'Premium users can refer others to Needlix. Share your Needlix link and ensure they mention you. You earn up to 40% commission!',
            ),
            _buildFaqItem(
              question: 'How do I upgrade to Premium?',
              answer: 'Go to Settings > My Subscription and choose to upgrade. Premium gives you unlimited orders, unlimited customers, and access to the commission referral program.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        iconColor: Colors.blue,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
