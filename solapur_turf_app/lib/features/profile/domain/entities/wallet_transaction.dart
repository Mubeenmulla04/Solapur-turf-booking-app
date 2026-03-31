import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_transaction.freezed.dart';
part 'wallet_transaction.g.dart';

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    required double amount,
    required String type, // CREDIT, DEBIT
    required String description,
    String? transactionReference,
    required DateTime createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}
