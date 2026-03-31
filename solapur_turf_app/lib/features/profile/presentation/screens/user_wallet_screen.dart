import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../providers/wallet_provider.dart';
import '../../domain/entities/wallet_transaction.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/constants/app_constants.dart';

class UserWalletScreen extends ConsumerStatefulWidget {
  const UserWalletScreen({super.key});

  @override
  ConsumerState<UserWalletScreen> createState() => _UserWalletScreenState();
}

class _UserWalletScreenState extends ConsumerState<UserWalletScreen> {
  late final Razorpay _razorpay;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    if (_pendingOrderId == null) return;
    ref.read(walletTopUpProvider.notifier).verifyPayment(
      orderId: _pendingOrderId!,
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (_pendingOrderId != null) {
      ref.read(walletTopUpProvider.notifier).reportPaymentFailure(
        orderId: _pendingOrderId!,
        paymentId: '',
        errorCode: response.code.toString(),
        errorMessage: response.message ?? 'Payment failed',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {}

  Future<void> _startTopUp() async {
    final result = await ref.read(walletTopUpProvider.notifier).createOrder(amount: 500);
    if (result == null) return;
    
    _pendingOrderId = result['id'];

    _razorpay.open({
      'key': AppConstants.razorpayKeyId,
      'amount': (result['amount']).toInt(), 
      'name': 'Turf Wallet',
      'description': 'Add funds to wallet',
      'order_id': _pendingOrderId,
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#0E7C61'},
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final profileAsync = ref.watch(userProfileProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    ref.listen(walletTopUpProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wallet updated successfully! 🎉'), backgroundColor: AppColors.success),
          );
        },
        error: (e, __) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update wallet: $e'), backgroundColor: AppColors.error),
          );
        }
      );
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Wallet', 
            style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, trace) => Center(child: Text('Failed to load wallet data: $e')),
        data: (user) {
          final balance = user.walletBalance.toStringAsFixed(2);
          final points = user.loyaltyPoints;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(userProfileProvider);
              ref.invalidate(walletTransactionsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // Wallet Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Balance', 
                              style: TextStyle(color: AppColors.surfaceLight, fontSize: 14)),
                          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.surfaceLight),
                        ],
                      ),
                      const Gap(16),
                      Text(
                        '₹$balance',
                        style: const TextStyle(
                          color: AppColors.surfaceLight,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const Gap(24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _startTopUp,
                              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                              label: const Text('Add Funds', 
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceLight,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.warning, size: 20),
                                const Gap(8),
                                Text('$points pt', 
                                    style: const TextStyle(color: AppColors.surfaceLight, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(32),
  
                // Transaction History
                const Text('Recent Transactions', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                const Gap(16),
                
                transactionsAsync.when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )),
                  error: (e, __) => Center(child: Text('Failed to load transactions: $e')),
                  data: (txs) => txs.isEmpty 
                    ? const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No transactions yet', style: TextStyle(color: AppColors.textSecondaryLight)),
                    ))
                    : Column(
                        children: txs.map((tx) => _buildTransactionTile(
                          tx.description, 
                          'Ref: ${tx.transactionReference ?? "N/A"}', 
                          tx.type == 'CREDIT' ? '+₹${tx.amount}' : '-₹${tx.amount}', 
                          tx.type == 'CREDIT'
                        )).toList(),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(String title, String subtitle, String amount, bool isCredit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit ? AppColors.success.withOpacity(0.1) : AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight, fontSize: 15)),
                const Gap(4),
                Text(subtitle, 
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isCredit ? AppColors.success : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
