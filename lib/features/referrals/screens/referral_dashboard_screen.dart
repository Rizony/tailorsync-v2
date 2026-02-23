import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';

class ReferralDashboardScreen extends ConsumerWidget {
  const ReferralDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(profileNotifierProvider).valueOrNull?.currencySymbol ?? '₦';
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Partner Earnings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildBalanceCard(currencySymbol),
          const SizedBox(height: 30),
          const Text("Your Referral Link", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildReferralLinkBox(context),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String currencySymbol) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF5D3FD3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("Available Balance", style: TextStyle(color: Colors.white70)),
          Text("$currencySymbol 12,400.00", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReferralLinkBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("tailorsync.app/ref/tailor123"),
          IconButton(onPressed: () {}, icon: const Icon(Icons.copy, size: 20)),
        ],
      ),
    );
  }
}