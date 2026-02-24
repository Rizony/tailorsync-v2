import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';
import 'package:tailorsync_v2/features/monetization/screens/upgrade_screen.dart';
import 'package:tailorsync_v2/features/referrals/providers/referral_provider.dart';
import 'withdrawal_screen.dart';

class ReferralDashboardScreen extends ConsumerWidget {
  const ReferralDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        final isPremium = user?.subscriptionTier == SubscriptionTier.premium;
        final currencySymbol = user?.currencySymbol ?? '₦';
        final walletBalance = user?.walletBalance ?? 0.0;
        final referralCode = user?.referralCode ?? '';
        final referralLink = 'https://tailorsync.app/ref/$referralCode';

        if (!isPremium) {
          return _PremiumLockedView(onUpgrade: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradeScreen()));
          });
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileNotifierProvider);
              ref.invalidate(referralStatsProvider);
            },
            child: CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5D3FD3), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              // Plan badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '👑  PREMIUM PARTNER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Partner Earnings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Wallet balance
                              Text(
                                '$currencySymbol ${_fmt(walletBalance)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Available Balance',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // Withdraw button in app bar
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WithdrawalScreen(
                            walletBalance: walletBalance,
                            currencySymbol: currencySymbol,
                          ),
                        ),
                      ).then((_) {
                        ref.invalidate(profileNotifierProvider);
                      }),
                      icon: const Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 18),
                      label: const Text('Withdraw',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Stats Row ─────────────────────────
                        ref.watch(referralStatsProvider).when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Stats error: $e'),
                          data: (stats) => _StatsRow(
                            stats: stats,
                            currencySymbol: currencySymbol,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Referral Code ─────────────────────
                        _sectionLabel('Your Referral Code'),
                        const SizedBox(height: 8),
                        _ReferralCodeCard(referralCode: referralCode),
                        const SizedBox(height: 16),

                        // ── Referral Link ─────────────────────
                        _sectionLabel('Your Referral Link'),
                        const SizedBox(height: 8),
                        _ReferralLinkCard(
                          link: referralLink,
                          onShare: () => SharePlus.instance.share(ShareParams(
                            text: 'Join me on TailorSync — the best app for tailors! 🎉\n'
                                'Sign up with my referral link and get started:\n$referralLink',
                            subject: 'Join TailorSync',
                          )),
                        ),
                        const SizedBox(height: 20),

                        // ── Commission Info ───────────────────
                        const _CommissionInfoCard(),
                        const SizedBox(height: 20),

                        // ── Transaction History ───────────────
                        _sectionLabel('Commission History'),
                        const SizedBox(height: 8),
                        ref.watch(referralStatsProvider).when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('$e'),
                          data: (stats) => stats.transactions.isEmpty
                              ? _EmptyHistory()
                              : _TransactionList(
                                  transactions: stats.transactions,
                                  currencySymbol: currencySymbol,
                                ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _fmt(double n) =>
      n.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

// ── Premium Locked View ─────────────────────────────────────
class _PremiumLockedView extends StatelessWidget {
  const _PremiumLockedView({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D3FD3), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The Partner & Referral system is exclusive to Premium users.\n\n'
                'Earn 40% on the first month and 20% recurring for every tailor you refer!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.6),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Upgrade to Premium',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3FD3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mini widgets ────────────────────────────────────────────
Widget _sectionLabel(String label) => Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.currencySymbol});
  final ReferralStats stats;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
            label: 'Referrals',
            value: stats.totalReferrals.toString(),
            icon: Icons.people),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Total Earned',
            value: '$currencySymbol ${_fmt(stats.totalEarned)}',
            icon: Icons.payments_outlined),
        const SizedBox(width: 10),
        _StatCard(
            label: 'This Month',
            value: '$currencySymbol ${_fmt(stats.thisMonthEarned)}',
            icon: Icons.calendar_today_outlined),
      ],
    );
  }

  static String _fmt(double n) => n.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF5D3FD3).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF5D3FD3).withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF5D3FD3), size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({required this.referralCode});
  final String referralCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D3FD3), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              referralCode.isEmpty ? '—' : referralCode.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral code copied!')),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.white),
            tooltip: 'Copy code',
          ),
        ],
      ),
    );
  }
}

class _ReferralLinkCard extends StatelessWidget {
  const _ReferralLinkCard({required this.link, required this.onShare});
  final String link;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              link,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied!')),
              );
            },
            tooltip: 'Copy link',
          ),
          ElevatedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D3FD3),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommissionInfoCard extends StatelessWidget {
  const _CommissionInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.amber),
              SizedBox(width: 6),
              Text('Commission Structure',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          SizedBox(height: 8),
          _CommissionRow('First month per referral', '40%'),
          _CommissionRow('Recurring monthly', '20%'),
          _CommissionRow('Minimum withdrawal', '₦500'),
        ],
      ),
    );
  }
}

class _CommissionRow extends StatelessWidget {
  const _CommissionRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold,
                  color: Color(0xFF5D3FD3))),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('No commissions yet',
              style: TextStyle(color: Colors.grey[500])),
          Text('Share your link to start earning!',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList(
      {required this.transactions, required this.currencySymbol});
  final List<Map<String, dynamic>> transactions;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions.take(20).map((tx) {
        final amount = (tx['commission_amount'] as num?)?.toDouble() ?? 0.0;
        final isFirst = tx['is_first_month'] == true;
        final dateStr = tx['created_at']?.toString() ?? '';
        final date = DateTime.tryParse(dateStr);
        final formatted = date != null
            ? '${date.day}/${date.month}/${date.year}'
            : '—';
        final tier = (tx['subscription_tier'] ?? 'Standard').toString();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D3FD3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments_outlined,
                    color: Color(0xFF5D3FD3), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tier[0].toUpperCase()}${tier.substring(1)} ${isFirst ? '(1st month)' : '(recurring)'}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(formatted,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                '+$currencySymbol ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}