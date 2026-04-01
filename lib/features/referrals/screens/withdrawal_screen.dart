import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import '../../monetization/providers/wallet_provider.dart';
import 'package:needlix/core/theme/app_colors.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({
    super.key,
    required this.walletBalance,
    required this.currencySymbol,
  });

  final double walletBalance;
  final String currencySymbol;

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accNumberCtrl = TextEditingController();
  final _accNameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill saved bank details
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    if (profile != null) {
      _bankCtrl.text = profile.bankName ?? '';
      _accNumberCtrl.text = profile.accountNumber ?? '';
      _accNameCtrl.text = profile.accountName ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _bankCtrl.dispose();
    _accNumberCtrl.dispose();
    _accNameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount < 500) {
      _snack('Minimum withdrawal amount is ${widget.currencySymbol}500', isError: true);
      return;
    }
    if (amount > widget.walletBalance) {
      _snack(
          'Amount exceeds your balance of ${widget.currencySymbol}${_fmt(widget.walletBalance)}',
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) throw Exception('Not logged in');

      final bankDetails = '${_bankCtrl.text.trim()} | ${_accNumberCtrl.text.trim()} | ${_accNameCtrl.text.trim()}';

      await ref.read(walletStateProvider.notifier).requestWithdrawal(
        amount: amount,
        bankDetails: bankDetails,
        pin: _pinCtrl.text.trim(),
      );

      ref.invalidate(profileNotifierProvider);
      if (mounted) {
        _snack('Withdrawal request submitted! We\'ll process it shortly.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('Insufficient balance') 
            ? 'Insufficient balance' 
            : e.toString().contains('Incorrect withdrawal PIN')
                ? 'Incorrect withdrawal PIN'
                : 'Request failed. Please try again.';
        _snack(errorMsg, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  static String _fmt(double n) => n
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context) {
    final sym = widget.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Withdrawal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Balance Card ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '$sym ${_fmt(widget.walletBalance)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Minimum withdrawal: ${sym}500',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Amount ─────────────────────────────────────
              const Text('Withdrawal Amount',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '$sym ',
                  hintText: '0.00',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  if (n < 500) return 'Minimum amount is ${sym}500';
                  if (n > widget.walletBalance) return 'Exceeds available balance';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Bank Details ───────────────────────────────
              const Text('Bank Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bankCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length != 10) return 'Must be 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _accNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              
              // ── Security PIN ───────────────────────────────
              const Text('Security Verification',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pinCtrl,
                decoration: const InputDecoration(
                  labelText: '4-Digit Withdrawal PIN',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your PIN'
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length != 4) return 'PIN must be 4 digits';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ── Notice ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Withdrawals are processed within 48 hours. '
                        'The amount will be held from your balance until processed.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Submit ─────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Withdrawal Request',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
