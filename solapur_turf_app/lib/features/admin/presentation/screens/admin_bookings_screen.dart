import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';

final _adminBookingsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/bookings', queryParameters: {'limit': 50});
    final pageData = res.data is Map ? res.data['data'] : null;
    final list = (pageData is Map && pageData.containsKey('content')) ? pageData['content'] as List : [];
    return list.cast<Map<String, dynamic>>();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final bookingsAsync = ref.watch(_adminBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              pinned: true,
              expandedHeight: 120,
              iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: const Text(
                  'Global Ledger',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
          body: bookingsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => AppErrorWidget(
              message: e is Failure ? e.userMessage : e.toString(),
              onRetry: () => ref.invalidate(_adminBookingsProvider),
            ),
            data: (bookings) => bookings.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'Ledger Empty',
                    subtitle: 'No transactions found on the platform yet.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(_adminBookingsProvider),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _AdminBookingTile(j: bookings[i]),
                              ),
                              childCount: bookings.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AdminBookingTile extends StatelessWidget {
  final Map<String, dynamic> j;
  const _AdminBookingTile({required this.j});

  @override
  Widget build(BuildContext context) {
    final user = j['user'] as Map<String, dynamic>? ?? {};
    final turf = j['turf'] as Map<String, dynamic>? ?? {};
    final status = j['booking_status'] as String? ?? j['bookingStatus'] as String? ?? '';
    final payStatus = j['payment_status'] as String? ?? j['paymentStatus'] as String? ?? '';
    final amount = double.tryParse((j['total_amount'] ?? j['totalAmount'] ?? 0).toString()) ?? 0;
    final date = j['booking_date'] as String? ?? j['bookingDate'] as String? ?? '';
    final bookingId = j['booking_id'] as String? ?? j['bookingId'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Segment ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.confirmation_num_rounded, size: 16, color: _statusColor(status)),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turf['turf_name'] as String? ?? turf['turfName'] as String? ?? 'Turf',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimaryLight),
                        ),
                        Text(
                          'ID: ${bookingId.length > 8 ? bookingId.substring(0, 8) : bookingId}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textHint, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppFormatters.toTitleCase(status),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.dividerLight),

          // ── Match Data ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                    const Gap(4),
                    Text(_fmt(date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Booker', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                    const Gap(4),
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 14, color: AppColors.textHint),
                        const Gap(4),
                        Text(
                          user['full_name'] as String? ?? user['fullName'] as String? ?? 'User',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.dividerLight),

          // ── Finance Row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatCurrency(amount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: payStatus.toUpperCase() == 'PAID' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: payStatus.toUpperCase() == 'PAID' ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        payStatus.toUpperCase() == 'PAID' ? Icons.check_circle_outline : Icons.pending_outlined,
                        size: 14,
                        color: payStatus.toUpperCase() == 'PAID' ? AppColors.success : AppColors.warning,
                      ),
                      const Gap(6),
                      Text(
                        payStatus.toUpperCase() == 'PAID' ? 'PAID' : 'PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: payStatus.toUpperCase() == 'PAID' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Actions Segment ──
          if (payStatus.toUpperCase() == 'PAID' && status.toUpperCase() == 'CANCELLED')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRefundDialog(context, ref),
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Process Refund'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController(text: amount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initiate Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the amount to refund back to the user via Razorpay.'),
            const Gap(16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final refundAmount = double.tryParse(amountController.text);
              if (refundAmount == null) return;
              
              final dio = ref.read(apiClientProvider);
              try {
                await dio.post('/payments/refund-booking/$bookingId', data: {
                  'amount': refundAmount,
                  'reason': 'Admin initiated refund from Ledger',
                });
                Navigator.pop(context);
                ref.invalidate(_adminBookingsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refund processed successfully!'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Refund failed: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s.toUpperCase()) {
        'CONFIRMED' => AppColors.statusConfirmed,
        'COMPLETED' => AppColors.statusCompleted,
        'CANCELLED' => AppColors.error,
        _ => AppColors.statusPending,
      };

  String _fmt(String d) {
    try {
      return AppFormatters.formatDate(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }
}
