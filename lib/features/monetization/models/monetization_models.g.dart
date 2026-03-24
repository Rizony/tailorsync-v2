// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monetization_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletImpl _$$WalletImplFromJson(Map<String, dynamic> json) => _$WalletImpl(
      id: json['id'] as String,
      tailorId: json['tailor_id'] as String,
      availableBalance: (json['available_balance'] as num).toDouble(),
      pendingBalance: (json['pending_balance'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$WalletImplToJson(_$WalletImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tailor_id': instance.tailorId,
      'available_balance': instance.availableBalance,
      'pending_balance': instance.pendingBalance,
      'currency': instance.currency,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionImpl(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      orderId: json['order_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$WalletTransactionImplToJson(
        _$WalletTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wallet_id': instance.walletId,
      'amount': instance.amount,
      'type': instance.type,
      'description': instance.description,
      'reference': instance.reference,
      'order_id': instance.orderId,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$WithdrawalRequestImpl _$$WithdrawalRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$WithdrawalRequestImpl(
      id: json['id'] as String,
      tailorId: json['tailor_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
    );

Map<String, dynamic> _$$WithdrawalRequestImplToJson(
        _$WithdrawalRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tailor_id': instance.tailorId,
      'amount': instance.amount,
      'status': instance.status,
      'bank_name': instance.bankName,
      'account_number': instance.accountNumber,
      'account_name': instance.accountName,
      'admin_notes': instance.adminNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'processed_at': instance.processedAt?.toIso8601String(),
    };
