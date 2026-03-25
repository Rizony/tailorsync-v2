import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:needlix/core/theme/app_theme.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/features/monetization/providers/wallet_provider.dart';
import 'package:needlix/features/referrals/screens/withdrawal_screen.dart';
import 'package:needlix/core/widgets/premium_empty_state.dart';
import '../providers/wallet_provider.dart';

class WalletDashboardScreen extends ConsumerWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletStateProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (wallet) {
          if (wallet == null) {
            return const Center(child: Text('No wallet found. Try restarting the app.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(walletStateProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0A1128), Color(0xFF0076B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('ESCROW WALLET', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Available to Withdraw', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text('₦${_fmt(wallet.availableBalance)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Pending Escrow', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                        Text('₦${_fmt(wallet.pendingBalance)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: wallet.availableBalance > 0 ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WithdrawalScreen(
                                          walletBalance: wallet.availableBalance,
                                          currencySymbol: '₦',
                                        ),
                                      ),
                                    ).then((_) {
                                      ref.invalidate(walletStateProvider);
                                      ref.invalidate(walletTransactionsProvider);
                                    });
                                  } : null,
                                  icon: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                                  label: const Text('Request Withdrawal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 20, color: Colors.amber),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'When clients pay for orders via Escrow, 50% is available immediately. 50% remains Pending until delivery is confirmed by the client.',
                                  style: TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        transactionsAsync.when(
                          loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                          error: (err, stack) => Text('Error loading transactions: $err'),
                          data: (transactions) {
                            if (transactions.isEmpty) {
                              return const PremiumEmptyState(
                                icon: Icons.history_edu_outlined,
                                title: 'No Transactions',
                                message: 'Your financial history will appear here once you start receiving payments or making withdrawals.',
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isCredit = tx.type.startsWith('credit') || tx.type == 'release_pending';
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          tx.type == 'credit_pending' ? Icons.hourglass_top : 
                                          tx.type == 'release_pending' ? Icons.check_circle_outline :
                                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                          color: isCredit ? Colors.green : Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(tx.description ?? tx.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                            Text(tx.createdAt.toString().split(' ').first, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isCredit ? '+' : '-'}₦${_fmt(tx.amount)}',
                                        style: TextStyle(
                                          color: isCredit ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _fmt(double n) => n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

