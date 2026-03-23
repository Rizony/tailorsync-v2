import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/auth/auth_provider.dart';
import '../models/monetization_models.dart';

part 'wallet_provider.g.dart';

@riverpod
class WalletState extends _$WalletState {
  final _supabase = Supabase.instance.client;

  @override
  Future<Wallet?> build() async {
    // Rebuild on auth change
    ref.watch(authControllerProvider);
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final res = await _supabase
        .from('wallets')
        .select()
        .eq('tailor_id', userId)
        .maybeSingle();

    if (res == null) return null;
    return Wallet.fromJson(res);
  }

  Future<void> requestWithdrawal({
    required double amount,
    required String bankDetails,
    required String pin,
  }) async {
    await _supabase.rpc(
      'request_withdrawal',
      params: {
        'req_amount': amount,
        'req_bank_details': bankDetails,
        'req_pin': pin,
      },
    );
    
    // Refresh wallet after withdrawal
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<WalletTransaction>> walletTransactions(WalletTransactionsRef ref) async {
  // Rebuild on auth change
  ref.watch(authControllerProvider);
  
  final wallet = await ref.watch(walletStateProvider.future);
  if (wallet == null) return [];

  final _supabase = Supabase.instance.client;
  final res = await _supabase
      .from('wallet_transactions')
      .select()
      .eq('wallet_id', wallet.id)
      .order('created_at', ascending: false)
      .limit(50);

  return (res as List).map((e) => WalletTransaction.fromJson(e)).toList();
}
