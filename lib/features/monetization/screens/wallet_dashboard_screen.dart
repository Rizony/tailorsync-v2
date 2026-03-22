import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/theme/app_theme.dart';
import 'package:tailorsync_v2/features/referrals/screens/withdrawal_screen.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  bool _loading = true;
  double _available = 0.0;
  double _pending = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchWallet();
  }

  Future<void> _fetchWallet() async {
    setState(() => _loading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Ensure wallet exists (trigger should handle it, but fallback just in case)
      final res = await Supabase.instance.client
          .from('wallets')
          .select()
          .eq('tailor_id', user.id)
          .maybeSingle();

      if (res != null) {
        _available = (res['available_balance'] as num).toDouble();
        _pending = (res['pending_balance'] as num).toDouble();
        
        // Fetch transactions
        final txRes = await Supabase.instance.client
            .from('wallet_transactions')
            .select()
            .eq('wallet_id', res['id'])
            .order('created_at', ascending: false)
            .limit(20);
            
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(txRes);
        });
      }
    } catch (e) {
      debugPrint("Error fetching wallet: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchWallet,
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
                                // Balances
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Available to Withdraw', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                          Text('₦${_fmt(_available)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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
                                          Text('₦${_fmt(_pending)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _available > 0 ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WithdrawalScreen(
                                            walletBalance: _available,
                                            currencySymbol: '₦',
                                          ),
                                        ),
                                      ).then((_) => _fetchWallet());
                                    } : null,
                                    icon: const Icon(Icons.account_balance_wallet, color: AppTheme.brandDark),
                                    label: const Text('Request Withdrawal', style: TextStyle(color: AppTheme.brandDark, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
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
                          ),
                          const SizedBox(height: 24),
                          const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          if (_transactions.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _transactions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final tx = _transactions[index];
                                final type = tx['type'].toString();
                                final isCredit = type.startsWith('credit') || type == 'release_pending';
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
                                          type == 'credit_pending' ? Icons.hourglass_top : 
                                          type == 'release_pending' ? Icons.check_circle_outline :
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
                                            Text(tx['description'] ?? type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                            Text(tx['created_at'].toString().split('T').first, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isCredit ? '+' : '-'}₦${_fmt((tx['amount'] as num).toDouble())}',
                                        style: TextStyle(
                                          color: isCredit ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),
    );
  }

  static String _fmt(double n) => n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
