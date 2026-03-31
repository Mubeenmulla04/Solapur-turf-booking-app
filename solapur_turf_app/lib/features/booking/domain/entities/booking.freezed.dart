// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Booking {
  String get bookingId => throw _privateConstructorUsedError;
  String get turfId => throw _privateConstructorUsedError;
  String get turfName => throw _privateConstructorUsedError;
  String get bookingDate => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  double get onlineAmount => throw _privateConstructorUsedError;
  double get cashAmount => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  BookingStatus get bookingStatus => throw _privateConstructorUsedError;
  String? get razorpayOrderId => throw _privateConstructorUsedError;
  String? get razorpayPaymentId => throw _privateConstructorUsedError;
  String? get couponId => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;
  double? get commissionAmount => throw _privateConstructorUsedError;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingCopyWith<Booking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res, Booking>;
  @useResult
  $Res call(
      {String bookingId,
      String turfId,
      String turfName,
      String bookingDate,
      String startTime,
      String endTime,
      double totalAmount,
      double onlineAmount,
      double cashAmount,
      PaymentMethod paymentMethod,
      PaymentStatus paymentStatus,
      BookingStatus bookingStatus,
      String? razorpayOrderId,
      String? razorpayPaymentId,
      String? couponId,
      double? discountAmount,
      double? commissionAmount});
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? turfId = null,
    Object? turfName = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalAmount = null,
    Object? onlineAmount = null,
    Object? cashAmount = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? bookingStatus = null,
    Object? razorpayOrderId = freezed,
    Object? razorpayPaymentId = freezed,
    Object? couponId = freezed,
    Object? discountAmount = freezed,
    Object? commissionAmount = freezed,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String,
      turfName: null == turfName
          ? _value.turfName
          : turfName // ignore: cast_nullable_to_non_nullable
              as String,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      onlineAmount: null == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as double,
      cashAmount: null == cashAmount
          ? _value.cashAmount
          : cashAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      razorpayOrderId: freezed == razorpayOrderId
          ? _value.razorpayOrderId
          : razorpayOrderId // ignore: cast_nullable_to_non_nullable
              as String?,
      razorpayPaymentId: freezed == razorpayPaymentId
          ? _value.razorpayPaymentId
          : razorpayPaymentId // ignore: cast_nullable_to_non_nullable
              as String?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      commissionAmount: freezed == commissionAmount
          ? _value.commissionAmount
          : commissionAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingImplCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$$BookingImplCopyWith(
          _$BookingImpl value, $Res Function(_$BookingImpl) then) =
      __$$BookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      String turfId,
      String turfName,
      String bookingDate,
      String startTime,
      String endTime,
      double totalAmount,
      double onlineAmount,
      double cashAmount,
      PaymentMethod paymentMethod,
      PaymentStatus paymentStatus,
      BookingStatus bookingStatus,
      String? razorpayOrderId,
      String? razorpayPaymentId,
      String? couponId,
      double? discountAmount,
      double? commissionAmount});
}

/// @nodoc
class __$$BookingImplCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingImpl>
    implements _$$BookingImplCopyWith<$Res> {
  __$$BookingImplCopyWithImpl(
      _$BookingImpl _value, $Res Function(_$BookingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? turfId = null,
    Object? turfName = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalAmount = null,
    Object? onlineAmount = null,
    Object? cashAmount = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? bookingStatus = null,
    Object? razorpayOrderId = freezed,
    Object? razorpayPaymentId = freezed,
    Object? couponId = freezed,
    Object? discountAmount = freezed,
    Object? commissionAmount = freezed,
  }) {
    return _then(_$BookingImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String,
      turfName: null == turfName
          ? _value.turfName
          : turfName // ignore: cast_nullable_to_non_nullable
              as String,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      onlineAmount: null == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as double,
      cashAmount: null == cashAmount
          ? _value.cashAmount
          : cashAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      razorpayOrderId: freezed == razorpayOrderId
          ? _value.razorpayOrderId
          : razorpayOrderId // ignore: cast_nullable_to_non_nullable
              as String?,
      razorpayPaymentId: freezed == razorpayPaymentId
          ? _value.razorpayPaymentId
          : razorpayPaymentId // ignore: cast_nullable_to_non_nullable
              as String?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      commissionAmount: freezed == commissionAmount
          ? _value.commissionAmount
          : commissionAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$BookingImpl implements _Booking {
  const _$BookingImpl(
      {required this.bookingId,
      required this.turfId,
      required this.turfName,
      required this.bookingDate,
      required this.startTime,
      required this.endTime,
      required this.totalAmount,
      required this.onlineAmount,
      required this.cashAmount,
      required this.paymentMethod,
      required this.paymentStatus,
      required this.bookingStatus,
      this.razorpayOrderId,
      this.razorpayPaymentId,
      this.couponId,
      this.discountAmount,
      this.commissionAmount});

  @override
  final String bookingId;
  @override
  final String turfId;
  @override
  final String turfName;
  @override
  final String bookingDate;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final double totalAmount;
  @override
  final double onlineAmount;
  @override
  final double cashAmount;
  @override
  final PaymentMethod paymentMethod;
  @override
  final PaymentStatus paymentStatus;
  @override
  final BookingStatus bookingStatus;
  @override
  final String? razorpayOrderId;
  @override
  final String? razorpayPaymentId;
  @override
  final String? couponId;
  @override
  final double? discountAmount;
  @override
  final double? commissionAmount;

  @override
  String toString() {
    return 'Booking(bookingId: $bookingId, turfId: $turfId, turfName: $turfName, bookingDate: $bookingDate, startTime: $startTime, endTime: $endTime, totalAmount: $totalAmount, onlineAmount: $onlineAmount, cashAmount: $cashAmount, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, bookingStatus: $bookingStatus, razorpayOrderId: $razorpayOrderId, razorpayPaymentId: $razorpayPaymentId, couponId: $couponId, discountAmount: $discountAmount, commissionAmount: $commissionAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.turfId, turfId) || other.turfId == turfId) &&
            (identical(other.turfName, turfName) ||
                other.turfName == turfName) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.onlineAmount, onlineAmount) ||
                other.onlineAmount == onlineAmount) &&
            (identical(other.cashAmount, cashAmount) ||
                other.cashAmount == cashAmount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.razorpayOrderId, razorpayOrderId) ||
                other.razorpayOrderId == razorpayOrderId) &&
            (identical(other.razorpayPaymentId, razorpayPaymentId) ||
                other.razorpayPaymentId == razorpayPaymentId) &&
            (identical(other.couponId, couponId) ||
                other.couponId == couponId) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.commissionAmount, commissionAmount) ||
                other.commissionAmount == commissionAmount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      turfId,
      turfName,
      bookingDate,
      startTime,
      endTime,
      totalAmount,
      onlineAmount,
      cashAmount,
      paymentMethod,
      paymentStatus,
      bookingStatus,
      razorpayOrderId,
      razorpayPaymentId,
      couponId,
      discountAmount,
      commissionAmount);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      __$$BookingImplCopyWithImpl<_$BookingImpl>(this, _$identity);
}

abstract class _Booking implements Booking {
  const factory _Booking(
      {required final String bookingId,
      required final String turfId,
      required final String turfName,
      required final String bookingDate,
      required final String startTime,
      required final String endTime,
      required final double totalAmount,
      required final double onlineAmount,
      required final double cashAmount,
      required final PaymentMethod paymentMethod,
      required final PaymentStatus paymentStatus,
      required final BookingStatus bookingStatus,
      final String? razorpayOrderId,
      final String? razorpayPaymentId,
      final String? couponId,
      final double? discountAmount,
      final double? commissionAmount}) = _$BookingImpl;

  @override
  String get bookingId;
  @override
  String get turfId;
  @override
  String get turfName;
  @override
  String get bookingDate;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  double get totalAmount;
  @override
  double get onlineAmount;
  @override
  double get cashAmount;
  @override
  PaymentMethod get paymentMethod;
  @override
  PaymentStatus get paymentStatus;
  @override
  BookingStatus get bookingStatus;
  @override
  String? get razorpayOrderId;
  @override
  String? get razorpayPaymentId;
  @override
  String? get couponId;
  @override
  double? get discountAmount;
  @override
  double? get commissionAmount;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateBookingResult {
  String get bookingId => throw _privateConstructorUsedError;
  String get razorpayOrderId => throw _privateConstructorUsedError;
  double get onlineAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Create a copy of CreateBookingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateBookingResultCopyWith<CreateBookingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBookingResultCopyWith<$Res> {
  factory $CreateBookingResultCopyWith(
          CreateBookingResult value, $Res Function(CreateBookingResult) then) =
      _$CreateBookingResultCopyWithImpl<$Res, CreateBookingResult>;
  @useResult
  $Res call(
      {String bookingId,
      String razorpayOrderId,
      double onlineAmount,
      String currency});
}

/// @nodoc
class _$CreateBookingResultCopyWithImpl<$Res, $Val extends CreateBookingResult>
    implements $CreateBookingResultCopyWith<$Res> {
  _$CreateBookingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateBookingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? razorpayOrderId = null,
    Object? onlineAmount = null,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      razorpayOrderId: null == razorpayOrderId
          ? _value.razorpayOrderId
          : razorpayOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      onlineAmount: null == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateBookingResultImplCopyWith<$Res>
    implements $CreateBookingResultCopyWith<$Res> {
  factory _$$CreateBookingResultImplCopyWith(_$CreateBookingResultImpl value,
          $Res Function(_$CreateBookingResultImpl) then) =
      __$$CreateBookingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      String razorpayOrderId,
      double onlineAmount,
      String currency});
}

/// @nodoc
class __$$CreateBookingResultImplCopyWithImpl<$Res>
    extends _$CreateBookingResultCopyWithImpl<$Res, _$CreateBookingResultImpl>
    implements _$$CreateBookingResultImplCopyWith<$Res> {
  __$$CreateBookingResultImplCopyWithImpl(_$CreateBookingResultImpl _value,
      $Res Function(_$CreateBookingResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateBookingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? razorpayOrderId = null,
    Object? onlineAmount = null,
    Object? currency = null,
  }) {
    return _then(_$CreateBookingResultImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      razorpayOrderId: null == razorpayOrderId
          ? _value.razorpayOrderId
          : razorpayOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      onlineAmount: null == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CreateBookingResultImpl implements _CreateBookingResult {
  const _$CreateBookingResultImpl(
      {required this.bookingId,
      required this.razorpayOrderId,
      required this.onlineAmount,
      required this.currency});

  @override
  final String bookingId;
  @override
  final String razorpayOrderId;
  @override
  final double onlineAmount;
  @override
  final String currency;

  @override
  String toString() {
    return 'CreateBookingResult(bookingId: $bookingId, razorpayOrderId: $razorpayOrderId, onlineAmount: $onlineAmount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBookingResultImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.razorpayOrderId, razorpayOrderId) ||
                other.razorpayOrderId == razorpayOrderId) &&
            (identical(other.onlineAmount, onlineAmount) ||
                other.onlineAmount == onlineAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, bookingId, razorpayOrderId, onlineAmount, currency);

  /// Create a copy of CreateBookingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBookingResultImplCopyWith<_$CreateBookingResultImpl> get copyWith =>
      __$$CreateBookingResultImplCopyWithImpl<_$CreateBookingResultImpl>(
          this, _$identity);
}

abstract class _CreateBookingResult implements CreateBookingResult {
  const factory _CreateBookingResult(
      {required final String bookingId,
      required final String razorpayOrderId,
      required final double onlineAmount,
      required final String currency}) = _$CreateBookingResultImpl;

  @override
  String get bookingId;
  @override
  String get razorpayOrderId;
  @override
  double get onlineAmount;
  @override
  String get currency;

  /// Create a copy of CreateBookingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateBookingResultImplCopyWith<_$CreateBookingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
