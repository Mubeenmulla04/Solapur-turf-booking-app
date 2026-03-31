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

final _ownerBookingsProvider =
    FutureProvider.autoDispose<List<_OwnerBookingItem>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/bookings/owner-bookings', queryParameters: {'limit': 50});
    final data = res.data is Map ? res.data['data'] : res.data;
    final list = (data is Map ? data['content'] ?? [] : data) as List;
    return list
        .map((j) => _OwnerBookingItem.fromJson(j as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw AppException.fromDioException(e);
  }
});

class _OwnerBookingItem {
  final String bookingId;
  final String userFullName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String bookingStatus;
  final String paymentStatus;
  final String turfName;

  const _OwnerBookingItem({
    required this.bookingId,
    required this.userFullName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.turfName,
  });

  factory _OwnerBookingItem.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>? ?? {};
    final turf = j['turf'] as Map<String, dynamic>? ?? {};
    return _OwnerBookingItem(
      bookingId: j['booking_id'] as String? ?? j['bookingId'] as String? ?? '',
      userFullName: user['full_name'] as String? ?? user['fullName'] as String? ?? 'User',
      bookingDate: j['booking_date'] as String? ?? j['bookingDate'] as String? ?? '',
      startTime: j['start_time'] as String? ?? j['startTime'] as String? ?? '',
      endTime: j['end_time'] as String? ?? j['endTime'] as String? ?? '',
      totalAmount: double.tryParse((j['final_amount'] ?? j['finalAmount'] ?? j['total_amount'] ?? j['totalAmount'] ?? 0).toString()) ?? 0,
      bookingStatus: j['booking_status'] as String? ?? j['bookingStatus'] as String? ?? 'PENDING',
      paymentStatus: j['payment_status'] as String? ?? j['paymentStatus'] as String? ?? 'PENDING',
      turfName: turf['turf_name'] as String? ?? turf['turfName'] as String? ?? 'Turf',
    );
  }
}

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final bookingsAsync = ref.watch(_ownerBookingsProvider);

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
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: const Text(
                  'Operations Ledger',
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
                      icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(children: [
                              Icon(Icons.filter_alt_outlined, color: AppColors.primary),
                              Gap(10),
                              Text('Advanced filtering coming soon!'),
                            ]),
                            backgroundColor: AppColors.surfaceLight,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
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
              onRetry: () => ref.invalidate(_ownerBookingsProvider),
            ),
            data: (bookings) => bookings.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.assignment_outlined,
                    title: 'No operations active',
                    subtitle: 'Paid bookings for your turfs will populate here.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(_ownerBookingsProvider),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _OwnerBookingCard(item: bookings[i]),
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

class _OwnerBookingCard extends ConsumerWidget {
  final _OwnerBookingItem item;
  const _OwnerBookingCard({required this.item});

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.cancel_outlined, color: AppColors.error),
          Gap(12),
          Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking for ${item.turfName}\n${item.bookingDate} • ${item.startTime}–${item.endTime}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.5),
            ),
            const Gap(16),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel It'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(apiClientProvider).patch(
        '/bookings/${item.bookingId}/cancel',
        data: {'reason': reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : 'Cancelled by owner'},
      );
      ref.invalidate(_ownerBookingsProvider);
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Color get _statusColor {
    return switch (item.bookingStatus.toUpperCase()) {
      'CONFIRMED' => AppColors.statusConfirmed,
      'COMPLETED' => AppColors.statusCompleted,
      'CANCELLED' => AppColors.error,
      'IN_PROGRESS' => AppColors.statusInProgress,
      _ => AppColors.statusPending,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
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
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.stadium_rounded, size: 16, color: _statusColor),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.turfName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimaryLight),
                        ),
                        Text(
                          'ID: ${item.bookingId.length > 8 ? item.bookingId.substring(0, 8) : item.bookingId}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textHint, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppFormatters.toTitleCase(item.bookingStatus),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.dividerLight),

          // ── Data Matrix ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _DataRow(Icons.calendar_month, 'Date', _fmt(item.bookingDate))),
                    Container(width: 1, height: 30, color: AppColors.dividerLight),
                    const Gap(16),
                    Expanded(child: _DataRow(Icons.schedule, 'Time', '${AppFormatters.formatTimeString(item.startTime)} - ${AppFormatters.formatTimeString(item.endTime)}')),
                  ],
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(item.userFullName.isNotEmpty ? item.userFullName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          item.userFullName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                        ),
                      ),
                    ],
                  ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Revenue', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                    Text(
                      AppFormatters.formatCurrency(item.totalAmount),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.paymentStatus.toUpperCase() == 'PAID' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: item.paymentStatus.toUpperCase() == 'PAID' ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.paymentStatus.toUpperCase() == 'PAID' ? Icons.check_circle_outline : Icons.pending_outlined,
                        size: 14,
                        color: item.paymentStatus.toUpperCase() == 'PAID' ? AppColors.success : AppColors.warning,
                      ),
                      const Gap(6),
                      Text(
                        item.paymentStatus.toUpperCase() == 'PAID' ? 'PAID' : 'PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.paymentStatus.toUpperCase() == 'PAID' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Cancel Action (for active bookings only) ──
          if (item.bookingStatus.toUpperCase() != 'CANCELLED' &&
              item.bookingStatus.toUpperCase() != 'COMPLETED') ...[  
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: OutlinedButton.icon(
                onPressed: () => _cancelBooking(context, ref),
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                label: const Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(
                      color: AppColors.error, width: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(String d) {
    try {
      return AppFormatters.formatDate(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DataRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textHint),
            const Gap(4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
          ],
        ),
        const Gap(4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight)),
      ],
    );
  }
}
