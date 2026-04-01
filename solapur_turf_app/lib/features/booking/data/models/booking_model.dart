import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/booking.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String bookingId,
    required String turfId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    @JsonKey(name: 'finalAmount') required dynamic totalAmount,
    @JsonKey(name: 'advanceAmount', defaultValue: 0) required dynamic onlineAmount,
    @JsonKey(defaultValue: 0) dynamic cashAmount,
    required String paymentMethod,
    required String paymentStatus,
    required String bookingStatus,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? couponId,
    dynamic discountAmount,
    dynamic commissionAmount,
    Map<String, dynamic>? turf,  // Nested turf object from API
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);
}

@freezed
class CreateBookingResponseModel with _$CreateBookingResponseModel {
  const factory CreateBookingResponseModel({
    required String bookingId,
    String? razorpayOrderId,
    @JsonKey(name: 'advanceAmount') required dynamic onlineAmount,
    @JsonKey(defaultValue: 'INR') required String currency,
  }) = _CreateBookingResponseModel;

  factory CreateBookingResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingResponseModelFromJson(json);
}

extension BookingModelX on BookingModel {
  Booking toDomain() => Booking(
        bookingId: bookingId,
        turfId: turfId,
        turfName: (turf?['turf_name'] as String?) ?? 'Turf',
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        totalAmount: _d(totalAmount),
        onlineAmount: _d(onlineAmount),
        cashAmount: _d(cashAmount),
        paymentMethod: PaymentMethodX.fromString(paymentMethod),
        paymentStatus: PaymentStatusX.fromString(paymentStatus),
        bookingStatus: BookingStatusX.fromString(bookingStatus),
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        couponId: couponId,
        discountAmount: discountAmount != null ? _d(discountAmount) : null,
        commissionAmount:
            commissionAmount != null ? _d(commissionAmount) : null,
      );

  double _d(dynamic v) => double.tryParse(v.toString()) ?? 0;
}

extension CreateBookingResponseModelX on CreateBookingResponseModel {
  CreateBookingResult toDomain() => CreateBookingResult(
        bookingId: bookingId,
        razorpayOrderId: razorpayOrderId ?? '',
        onlineAmount: double.tryParse(onlineAmount.toString()) ?? 0,
        currency: currency,
      );
}
