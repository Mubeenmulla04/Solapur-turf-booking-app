import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/wallet_transaction.dart';
import 'profile_provider.dart';

part 'wallet_provider.g.dart';

@riverpod
Future<List<WalletTransaction>> walletTransactions(Ref ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/wallets/transactions');
    final data = res.data['data'];
    final list = data['content'] as List<dynamic>;
    return list.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
  } on DioException catch (e) {
    throw Exception('Failed to load wallet transactions: ${e.message}');
  }
}

@riverpod
class WalletTopUp extends _$WalletTopUp {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<Map<String, dynamic>?> createOrder({required double amount}) async {
    state = const AsyncValue.loading();
    final dio = ref.read(apiClientProvider);
    try {
      final res = await dio.post('/payments/create-order', data: {
        'amount': amount,
        'transactionType': 'WALLET_TOPUP',
      });
      state = const AsyncValue.data(null);
      return res.data;
    } on DioException catch (e) {
      state = AsyncValue.error(e.message ?? 'Order creation failed', StackTrace.current);
      return null;
    }
  }

  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    state = const AsyncValue.loading();
    final dio = ref.read(apiClientProvider);
    try {
      await dio.post('/payments/verify', data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      });
      state = const AsyncValue.data(null);
      ref.invalidate(walletTransactionsProvider);
      ref.invalidate(userProfileProvider);
    } on DioException catch (e) {
      state = AsyncValue.error(e.message ?? 'Verification failed', StackTrace.current);
    }
  }

  Future<void> reportPaymentFailure({
    required String orderId,
    required String paymentId,
    required String errorCode,
    required String errorMessage,
  }) async {
    final dio = ref.read(apiClientProvider);
    try {
      await dio.post('/payments/failure', data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'errorCode': errorCode,
        'errorDescription': errorMessage,
      });
    } catch (_) {} 
    state = AsyncValue.error(errorMessage, StackTrace.current);
  }
}
