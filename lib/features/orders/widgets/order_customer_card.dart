import 'package:flutter/material.dart';
import 'package:needlix/features/customers/models/customer.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/core/auth/models/app_user.dart';
import 'package:needlix/core/utils/phone_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCustomerCard extends StatelessWidget {
  final Customer customer;
  final OrderModel order;
  final AppUser? profile;

  const OrderCustomerCard({
    super.key,
    required this.customer,
    required this.order,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: Text(customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(customer.phoneNumber ?? 'No Phone', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (customer.phoneNumber != null) ...[
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => launchUrl(Uri.parse('tel:${customer.phoneNumber}')),
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Color(0xFF25D366)),
              onPressed: () {
                String phone = PhoneFormatter.formatForExternalApi(customer.phoneNumber!);
                final message = Uri.encodeComponent("Hello ${customer.fullName.split(' ').first}, your order for '${order.title}' from ${profile?.shopName ?? 'Tailor Shop'} is ready!");
                launchUrl(Uri.parse('https://wa.me/$phone?text=$message'), mode: LaunchMode.externalApplication);
              },
            ),
          ]
        ],
      ),
    );
  }
}
