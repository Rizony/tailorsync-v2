import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/monetization/payout_request.dart';
import '../session/session_controller.dart';

class PayoutsScreen extends ConsumerWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(controller),
            const SizedBox(height: 24),
            const Text(
              'Payout History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: controller.payoutRequests.isEmpty
                  ? const Center(
                      child: Text('No payout requests yet.'),
                    )
                  : ListView.builder(
                      itemCount: controller.payoutRequests.length,
                      itemBuilder: (context, index) {
                        final request =
                            controller.payoutRequests[index];
                        return _PayoutTile(request: request);

                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(SessionController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${controller.payableBalance.toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.canRequestPayout
                    ? controller.requestPayout
                    : null,
                child: const Text('Request Payout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  final PayoutRequest request;

  const _PayoutTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          '\$${request.amountUsd.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Requested ${_fmt(request.requestedAt)}',
        ),
        trailing: Chip(
          label: Text(request.isPaid ? 'PAID' : 'PENDING'),
          backgroundColor:
              request.isPaid ? Colors.green.shade100 : Colors.orange.shade100,
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
