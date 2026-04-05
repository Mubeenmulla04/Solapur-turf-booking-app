import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';

enum PaymentMethod { fullOnline, partialOnlineCash, cashOnBooking, wallet }
enum PaymentStatus { pending, paid, partiallyPaid, failed, refunded }
enum BookingStatus { pending, confirmed, inProgress, completed, cancelled, noShow }

extension PaymentMethodX on PaymentMethod {
  String get apiValue => switch (this) {
        PaymentMethod.fullOnline => 'ONLINE',
        PaymentMethod.partialOnlineCash => 'CASH',
        PaymentMethod.cashOnBooking => 'CASH',
        PaymentMethod.wallet => 'ONLINE',
      };

  String get label => switch (this) {
        PaymentMethod.fullOnline => 'Full Online Payment',
        PaymentMethod.partialOnlineCash => '₹50 Advance + Cash at Venue',
        PaymentMethod.cashOnBooking => 'Full Cash at Venue',
        PaymentMethod.wallet => 'Wallet',
      };

  static PaymentMethod fromString(String s) => switch (s) {
        'PARTIAL_ONLINE_CASH' => PaymentMethod.partialOnlineCash,
        'CASH_ON_BOOKING' => PaymentMethod.cashOnBooking,
        'WALLET' => PaymentMethod.wallet,
        _ => PaymentMethod.fullOnline,
      };
}

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.pending => 'Pending',
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.inProgress => 'In Progress',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
        BookingStatus.noShow => 'No Show',
      };

  static BookingStatus fromString(String s) => switch (s) {
        'CONFIRMED' => BookingStatus.confirmed,
        'IN_PROGRESS' => BookingStatus.inProgress,
        'COMPLETED' => BookingStatus.completed,
        'CANCELLED' => BookingStatus.cancelled,
        'NO_SHOW' => BookingStatus.noShow,
        _ => BookingStatus.pending,
      };
}

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.paid => 'Paid',
        PaymentStatus.partiallyPaid => 'Partially Paid',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.refunded => 'Refunded',
        _ => 'Pending',
      };

  static PaymentStatus fromString(String s) => switch (s) {
        'PAID' => PaymentStatus.paid,
        'PARTIALLY_PAID' => PaymentStatus.partiallyPaid,
        'FAILED' => PaymentStatus.failed,
        'REFUNDED' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String bookingId,
    required String turfId,
    required String turfName,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required double totalAmount,
    required double onlineAmount,
    required double cashAmount,
    required PaymentMethod paymentMethod,
    required PaymentStatus paymentStatus,
    required BookingStatus bookingStatus,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? couponId,
    double? discountAmount,
    double? commissionAmount,
  }) = _Booking;
}

@freezed
class CreateBookingResult with _$CreateBookingResult {
  const factory CreateBookingResult({
    required String bookingId,
    required String razorpayOrderId,
    required double onlineAmount,
    required String currency,
  }) = _CreateBookingResult;
}
