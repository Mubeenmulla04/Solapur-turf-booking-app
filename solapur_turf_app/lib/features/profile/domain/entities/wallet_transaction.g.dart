// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      transactionReference: json['transactionReference'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WalletTransactionImplToJson(
        _$WalletTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'type': instance.type,
      'description': instance.description,
      'transactionReference': instance.transactionReference,
      'createdAt': instance.createdAt.toIso8601String(),
    };
