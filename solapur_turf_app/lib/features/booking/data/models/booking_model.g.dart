// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingModelImpl _$$BookingModelImplFromJson(Map<String, dynamic> json) =>
    _$BookingModelImpl(
      bookingId: json['bookingId'] as String,
      turfId: json['turfId'] as String,
      bookingDate: json['bookingDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalAmount: json['finalAmount'],
      onlineAmount: json['advanceAmount'] ?? 0,
      cashAmount: json['cashAmount'] ?? 0,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      bookingStatus: json['bookingStatus'] as String,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      couponId: json['couponId'] as String?,
      discountAmount: json['discountAmount'],
      commissionAmount: json['commissionAmount'],
      turf: json['turf'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BookingModelImplToJson(_$BookingModelImpl instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'turfId': instance.turfId,
      'bookingDate': instance.bookingDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'finalAmount': instance.totalAmount,
      'advanceAmount': instance.onlineAmount,
      'cashAmount': instance.cashAmount,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'bookingStatus': instance.bookingStatus,
      'razorpayOrderId': instance.razorpayOrderId,
      'razorpayPaymentId': instance.razorpayPaymentId,
      'couponId': instance.couponId,
      'discountAmount': instance.discountAmount,
      'commissionAmount': instance.commissionAmount,
      'turf': instance.turf,
    };

_$CreateBookingResponseModelImpl _$$CreateBookingResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateBookingResponseModelImpl(
      bookingId: json['bookingId'] as String,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      onlineAmount: json['advanceAmount'],
      currency: json['currency'] as String? ?? 'INR',
    );

Map<String, dynamic> _$$CreateBookingResponseModelImplToJson(
        _$CreateBookingResponseModelImpl instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'razorpayOrderId': instance.razorpayOrderId,
      'advanceAmount': instance.onlineAmount,
      'currency': instance.currency,
    };
