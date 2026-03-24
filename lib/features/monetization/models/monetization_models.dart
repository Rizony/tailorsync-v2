import 'package:freezed_annotation/freezed_annotation.dart';

part 'monetization_models.freezed.dart';
part 'monetization_models.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    @JsonKey(name: 'tailor_id') required String tailorId,
    @JsonKey(name: 'available_balance') required double availableBalance,
    @JsonKey(name: 'pending_balance') required double pendingBalance,
    required String currency,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    @JsonKey(name: 'wallet_id') required String walletId,
    required double amount,
    required String type, // 'credit_pending', 'release_pending', 'credit_available', 'withdrawal'
    String? description,
    String? reference,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);
}

@freezed
class WithdrawalRequest with _$WithdrawalRequest {
  const factory WithdrawalRequest({
    required String id,
    @JsonKey(name: 'tailor_id') required String tailorId,
    required double amount,
    required String status, // 'pending', 'approved', 'rejected', 'paid'
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'processed_at') DateTime? processedAt,
  }) = _WithdrawalRequest;

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) => _$WithdrawalRequestFromJson(json);
}
