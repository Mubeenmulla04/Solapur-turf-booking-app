import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    HapticFeedback.vibrate();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(60),
              // Success Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 80,
                  ),
                ),
              ),
              const Gap(24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Gap(8),
              Text(
                'Your slot has been successfully reserved.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const Gap(40),
              
              // Booking Details Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Turf',
                        value: booking.turfName,
                        isBold: true,
                      ),
                      const Divider(height: 32),
                      _DetailRow(
                        label: 'Date',
                        value: AppFormatters.formatDate(DateTime.parse(booking.bookingDate)),
                      ),
                      const Gap(16),
                      _DetailRow(
                        label: 'Time',
                        value: '${AppFormatters.formatTimeString(booking.startTime)} - ${AppFormatters.formatTimeString(booking.endTime)}',
                      ),
                      const Gap(16),
                      _DetailRow(
                        label: 'Payment',
                        value: booking.paymentMethod.label,
                      ),
                      const Divider(height: 32),
                      _DetailRow(
                        label: 'Total Amount',
                        value: AppFormatters.formatCurrency(booking.totalAmount),
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Gap(40),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/user/bookings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View My Bookings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Gap(12),
                    TextButton(
                      onPressed: () => context.go('/user/dashboard'),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimaryLight,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
