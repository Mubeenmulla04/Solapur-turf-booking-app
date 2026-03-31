import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/booking.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: false,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => AppErrorWidget(
          message: e is Failure ? e.userMessage : e.toString(),
          onRetry: () => ref.invalidate(myBookingsProvider),
        ),
        data: (bookings) => bookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: const Icon(Icons.receipt_long_outlined,
                          size: 48, color: AppColors.textHint),
                    ),
                    const Gap(24),
                    const Text('No Bookings Found',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight)),
                    const Gap(8),
                    const Text('Your turf bookings will appear here.',
                        style: TextStyle(color: AppColors.textSecondaryLight)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myBookingsProvider),
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const Gap(20),
                  itemBuilder: (_, i) =>
                      _BookingTicketCard(booking: bookings[i]),
                ),
              ),
      ),
    );
  }
}

class _BookingTicketCard extends ConsumerStatefulWidget {
  final Booking booking;
  const _BookingTicketCard({required this.booking});

  @override
  ConsumerState<_BookingTicketCard> createState() => _BookingTicketCardState();
}

class _BookingTicketCardState extends ConsumerState<_BookingTicketCard> {
  bool _cancelling = false;

  Booking get booking => widget.booking;

  Color get _statusColor => switch (booking.bookingStatus) {
        BookingStatus.confirmed => AppColors.success,
        BookingStatus.completed => AppColors.textSecondaryLight,
        BookingStatus.cancelled => AppColors.error,
        BookingStatus.inProgress => AppColors.warning,
        _ => AppColors.primary,
      };

  IconData get _statusIcon => switch (booking.bookingStatus) {
        BookingStatus.confirmed => Icons.check_circle_rounded,
        BookingStatus.completed => Icons.history_rounded,
        BookingStatus.cancelled => Icons.cancel_rounded,
        BookingStatus.inProgress => Icons.directions_run_rounded,
        _ => Icons.pending_actions_rounded,
      };

  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to cancel this booking? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Cancel Booking',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ref.read(bookingNotifierProvider.notifier).cancelBooking(booking.bookingId);
      ref.invalidate(myBookingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to cancel: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _showQrPass() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Booking Pass',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        size: 80, color: AppColors.primaryDark),
                    const Gap(4),
                    Text(
                      '#${booking.bookingId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            Text(
              booking.turfName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
            Text(
              '${_formatDate(booking.bookingDate)}\n${AppFormatters.formatTimeString(booking.startTime)} – ${AppFormatters.formatTimeString(booking.endTime)}',
              style: const TextStyle(
                  color: AppColors.textSecondaryLight, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking.bookingStatus == BookingStatus.cancelled;
    final isCompleted = booking.bookingStatus == BookingStatus.completed;
    final isFaded = isCancelled || isCompleted;

    return Opacity(
      opacity: isFaded ? 0.7 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCancelled ? AppColors.error.withOpacity(0.3) : AppColors.dividerLight,
            width: isCancelled ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(isFaded ? 0.02 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Upper Ticket Section ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(_statusIcon, color: _statusColor, size: 24),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.turfName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(4),
                            Text(
                              'Booking ID: #${booking.bookingId.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textHint,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  
                  // Date & Time Block
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                            const Gap(4),
                            Text(
                              _formatDate(booking.bookingDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.dividerLight),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Time Slots', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                              const Gap(4),
                              Text(
                                '${AppFormatters.formatTimeString(booking.startTime)}\n${AppFormatters.formatTimeString(booking.endTime)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ── Dashed Divider Ticket Cutout ──
            Row(
              children: [
                _buildCutout(isLeft: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            (constraints.hasBoundedWidth ? constraints.maxWidth : 300.0) ~/ 10,
                            (index) => const SizedBox(
                              width: 4,
                              height: 1.5,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: AppColors.dividerLight),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildCutout(isLeft: false),
              ],
            ),

            // ── Bottom Section (Financials) ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: isCancelled ? AppColors.errorContainer.withOpacity(0.3) : AppColors.surfaceVariantLight.withOpacity(0.4),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                        ),
                        const Gap(4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              AppFormatters.formatCurrency(booking.totalAmount),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isCancelled ? AppColors.error : AppColors.textPrimaryLight,
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const Gap(8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: booking.paymentStatus == PaymentStatus.paid
                                      ? AppColors.primaryContainer
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.dividerLight),
                                ),
                                child: Text(
                                  booking.paymentMethod.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: booking.paymentStatus == PaymentStatus.paid
                                        ? AppColors.primary
                                        : AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  
                   // Action Button or Status Chip
                  booking.bookingStatus == BookingStatus.confirmed
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _showQrPass,
                            icon: const Icon(Icons.qr_code, size: 16, color: AppColors.primary),
                            label: const Text('Pass', style: TextStyle(color: AppColors.primary)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const Gap(8),
                          _cancelling
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: AppColors.error, strokeWidth: 2))
                            : OutlinedButton(
                                onPressed: _cancelBooking,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text('Cancel',
                                    style: TextStyle(color: AppColors.error, fontSize: 12)),
                              ),
                        ],
                      )
                    : StatusChip(
                        label: booking.bookingStatus.label,
                        color: _statusColor,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutout({required bool isLeft}) {
    return SizedBox(
      height: 24,
      width: 12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border(
            top: const BorderSide(color: AppColors.dividerLight),
            bottom: const BorderSide(color: AppColors.dividerLight),
            right: isLeft ? const BorderSide(color: AppColors.dividerLight) : BorderSide.none,
            left: !isLeft ? const BorderSide(color: AppColors.dividerLight) : BorderSide.none,
          ),
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(isLeft ? 12 : 0),
            left: Radius.circular(!isLeft ? 12 : 0),
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('EEE, d MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }
}
