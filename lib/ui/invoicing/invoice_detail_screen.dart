import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/invoicing/invoice.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle(context, 'Invoice Info'),
            _infoRow('Invoice ID', invoice.id.value),
            _infoRow('Status', invoice.status.name),
            _infoRow(
              'Total Amount',
              '\$${invoice.totalAmount.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 24),

            _sectionTitle(context, 'Payments'),
            if (invoice.payments.isEmpty)
              const Text('No payments recorded yet'),

            ...invoice.payments.map(
              (payment) => ListTile(
                leading: const Icon(Icons.payments),
                title: Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                ),
                subtitle: Text(
                  '${payment.method.name} • ${payment.paidAt}',
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle(context, 'Balance'),
            _infoRow(
              'Paid',
              '\$${invoice.payments.fold(0.0, (s, p) => s + p.amount).toStringAsFixed(2)}',
            ),
            _infoRow(
              'Balance Due',
              '\$${invoice.balanceDue.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
