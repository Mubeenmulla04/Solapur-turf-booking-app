// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) {
  return _BookingModel.fromJson(json);
}

/// @nodoc
mixin _$BookingModel {
  String get bookingId => throw _privateConstructorUsedError;
  String get turfId => throw _privateConstructorUsedError;
  String get bookingDate => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'finalAmount')
  dynamic get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'advanceAmount', defaultValue: 0)
  dynamic get onlineAmount => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  dynamic get cashAmount => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String get bookingStatus => throw _privateConstructorUsedError;
  String? get razorpayOrderId => throw _privateConstructorUsedError;
  String? get razorpayPaymentId => throw _privateConstructorUsedError;
  String? get couponId => throw _privateConstructorUsedError;
  dynamic get discountAmount => throw _privateConstructorUsedError;
  dynamic get commissionAmount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get turf => throw _privateConstructorUsedError;

  /// Serializes this BookingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingModelCopyWith<BookingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingModelCopyWith<$Res> {
  factory $BookingModelCopyWith(
          BookingModel value, $Res Function(BookingModel) then) =
      _$BookingModelCopyWithImpl<$Res, BookingModel>;
  @useResult
  $Res call(
      {String bookingId,
      String turfId,
      String bookingDate,
      String startTime,
      String endTime,
      @JsonKey(name: 'finalAmount') dynamic totalAmount,
      @JsonKey(name: 'advanceAmount', defaultValue: 0) dynamic onlineAmount,
      @JsonKey(defaultValue: 0) dynamic cashAmount,
      String paymentMethod,
      String paymentStatus,
      String bookingStatus,
      String? razorpayOrderId,
      String? razorpayPaymentId,
      String? couponId,
      dynamic discountAmount,
      dynamic commissionAmount,
      Map<String, dynamic>? turf});
}

/// @nodoc
class _$BookingModelCopyWithImpl<$Res, $Val extends BookingModel>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? turfId = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalAmount = freezed,
    Object? onlineAmount = freezed,
    Object? cashAmount = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? bookingStatus = null,
    Object? razorpayOrderId = freezed,
    Object? razorpayPaymentId = freezed,
    Object? couponId = freezed,
    Object? discountAmount = freezed,
    Object? commissionAmount = freezed,
    Object? turf = freezed,
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
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      onlineAmount: freezed == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cashAmount: freezed == cashAmount
          ? _value.cashAmount
          : cashAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String,
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
              as dynamic,
      commissionAmount: freezed == commissionAmount
          ? _value.commissionAmount
          : commissionAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      turf: freezed == turf
          ? _value.turf
          : turf // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingModelImplCopyWith<$Res>
    implements $BookingModelCopyWith<$Res> {
  factory _$$BookingModelImplCopyWith(
          _$BookingModelImpl value, $Res Function(_$BookingModelImpl) then) =
      __$$BookingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      String turfId,
      String bookingDate,
      String startTime,
      String endTime,
      @JsonKey(name: 'finalAmount') dynamic totalAmount,
      @JsonKey(name: 'advanceAmount', defaultValue: 0) dynamic onlineAmount,
      @JsonKey(defaultValue: 0) dynamic cashAmount,
      String paymentMethod,
      String paymentStatus,
      String bookingStatus,
      String? razorpayOrderId,
      String? razorpayPaymentId,
      String? couponId,
      dynamic discountAmount,
      dynamic commissionAmount,
      Map<String, dynamic>? turf});
}

/// @nodoc
class __$$BookingModelImplCopyWithImpl<$Res>
    extends _$BookingModelCopyWithImpl<$Res, _$BookingModelImpl>
    implements _$$BookingModelImplCopyWith<$Res> {
  __$$BookingModelImplCopyWithImpl(
      _$BookingModelImpl _value, $Res Function(_$BookingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? turfId = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalAmount = freezed,
    Object? onlineAmount = freezed,
    Object? cashAmount = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? bookingStatus = null,
    Object? razorpayOrderId = freezed,
    Object? razorpayPaymentId = freezed,
    Object? couponId = freezed,
    Object? discountAmount = freezed,
    Object? commissionAmount = freezed,
    Object? turf = freezed,
  }) {
    return _then(_$BookingModelImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
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
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      onlineAmount: freezed == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cashAmount: freezed == cashAmount
          ? _value.cashAmount
          : cashAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String,
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
              as dynamic,
      commissionAmount: freezed == commissionAmount
          ? _value.commissionAmount
          : commissionAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      turf: freezed == turf
          ? _value._turf
          : turf // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl implements _BookingModel {
  const _$BookingModelImpl(
      {required this.bookingId,
      required this.turfId,
      required this.bookingDate,
      required this.startTime,
      required this.endTime,
      @JsonKey(name: 'finalAmount') required this.totalAmount,
      @JsonKey(name: 'advanceAmount', defaultValue: 0)
      required this.onlineAmount,
      @JsonKey(defaultValue: 0) this.cashAmount,
      required this.paymentMethod,
      required this.paymentStatus,
      required this.bookingStatus,
      this.razorpayOrderId,
      this.razorpayPaymentId,
      this.couponId,
      this.discountAmount,
      this.commissionAmount,
      final Map<String, dynamic>? turf})
      : _turf = turf;

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  final String bookingId;
  @override
  final String turfId;
  @override
  final String bookingDate;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  @JsonKey(name: 'finalAmount')
  final dynamic totalAmount;
  @override
  @JsonKey(name: 'advanceAmount', defaultValue: 0)
  final dynamic onlineAmount;
  @override
  @JsonKey(defaultValue: 0)
  final dynamic cashAmount;
  @override
  final String paymentMethod;
  @override
  final String paymentStatus;
  @override
  final String bookingStatus;
  @override
  final String? razorpayOrderId;
  @override
  final String? razorpayPaymentId;
  @override
  final String? couponId;
  @override
  final dynamic discountAmount;
  @override
  final dynamic commissionAmount;
  final Map<String, dynamic>? _turf;
  @override
  Map<String, dynamic>? get turf {
    final value = _turf;
    if (value == null) return null;
    if (_turf is EqualUnmodifiableMapView) return _turf;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BookingModel(bookingId: $bookingId, turfId: $turfId, bookingDate: $bookingDate, startTime: $startTime, endTime: $endTime, totalAmount: $totalAmount, onlineAmount: $onlineAmount, cashAmount: $cashAmount, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, bookingStatus: $bookingStatus, razorpayOrderId: $razorpayOrderId, razorpayPaymentId: $razorpayPaymentId, couponId: $couponId, discountAmount: $discountAmount, commissionAmount: $commissionAmount, turf: $turf)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.turfId, turfId) || other.turfId == turfId) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            const DeepCollectionEquality()
                .equals(other.totalAmount, totalAmount) &&
            const DeepCollectionEquality()
                .equals(other.onlineAmount, onlineAmount) &&
            const DeepCollectionEquality()
                .equals(other.cashAmount, cashAmount) &&
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
            const DeepCollectionEquality()
                .equals(other.discountAmount, discountAmount) &&
            const DeepCollectionEquality()
                .equals(other.commissionAmount, commissionAmount) &&
            const DeepCollectionEquality().equals(other._turf, _turf));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      turfId,
      bookingDate,
      startTime,
      endTime,
      const DeepCollectionEquality().hash(totalAmount),
      const DeepCollectionEquality().hash(onlineAmount),
      const DeepCollectionEquality().hash(cashAmount),
      paymentMethod,
      paymentStatus,
      bookingStatus,
      razorpayOrderId,
      razorpayPaymentId,
      couponId,
      const DeepCollectionEquality().hash(discountAmount),
      const DeepCollectionEquality().hash(commissionAmount),
      const DeepCollectionEquality().hash(_turf));

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      __$$BookingModelImplCopyWithImpl<_$BookingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingModelImplToJson(
      this,
    );
  }
}

abstract class _BookingModel implements BookingModel {
  const factory _BookingModel(
      {required final String bookingId,
      required final String turfId,
      required final String bookingDate,
      required final String startTime,
      required final String endTime,
      @JsonKey(name: 'finalAmount') required final dynamic totalAmount,
      @JsonKey(name: 'advanceAmount', defaultValue: 0)
      required final dynamic onlineAmount,
      @JsonKey(defaultValue: 0) final dynamic cashAmount,
      required final String paymentMethod,
      required final String paymentStatus,
      required final String bookingStatus,
      final String? razorpayOrderId,
      final String? razorpayPaymentId,
      final String? couponId,
      final dynamic discountAmount,
      final dynamic commissionAmount,
      final Map<String, dynamic>? turf}) = _$BookingModelImpl;

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  String get bookingId;
  @override
  String get turfId;
  @override
  String get bookingDate;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  @JsonKey(name: 'finalAmount')
  dynamic get totalAmount;
  @override
  @JsonKey(name: 'advanceAmount', defaultValue: 0)
  dynamic get onlineAmount;
  @override
  @JsonKey(defaultValue: 0)
  dynamic get cashAmount;
  @override
  String get paymentMethod;
  @override
  String get paymentStatus;
  @override
  String get bookingStatus;
  @override
  String? get razorpayOrderId;
  @override
  String? get razorpayPaymentId;
  @override
  String? get couponId;
  @override
  dynamic get discountAmount;
  @override
  dynamic get commissionAmount;
  @override
  Map<String, dynamic>? get turf;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateBookingResponseModel _$CreateBookingResponseModelFromJson(
    Map<String, dynamic> json) {
  return _CreateBookingResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CreateBookingResponseModel {
  String get bookingId => throw _privateConstructorUsedError;
  String? get razorpayOrderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'advanceAmount')
  dynamic get onlineAmount => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 'INR')
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this CreateBookingResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateBookingResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateBookingResponseModelCopyWith<CreateBookingResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBookingResponseModelCopyWith<$Res> {
  factory $CreateBookingResponseModelCopyWith(CreateBookingResponseModel value,
          $Res Function(CreateBookingResponseModel) then) =
      _$CreateBookingResponseModelCopyWithImpl<$Res,
          CreateBookingResponseModel>;
  @useResult
  $Res call(
      {String bookingId,
      String? razorpayOrderId,
      @JsonKey(name: 'advanceAmount') dynamic onlineAmount,
      @JsonKey(defaultValue: 'INR') String currency});
}

/// @nodoc
class _$CreateBookingResponseModelCopyWithImpl<$Res,
        $Val extends CreateBookingResponseModel>
    implements $CreateBookingResponseModelCopyWith<$Res> {
  _$CreateBookingResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateBookingResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? razorpayOrderId = freezed,
    Object? onlineAmount = freezed,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      razorpayOrderId: freezed == razorpayOrderId
          ? _value.razorpayOrderId
          : razorpayOrderId // ignore: cast_nullable_to_non_nullable
              as String?,
      onlineAmount: freezed == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateBookingResponseModelImplCopyWith<$Res>
    implements $CreateBookingResponseModelCopyWith<$Res> {
  factory _$$CreateBookingResponseModelImplCopyWith(
          _$CreateBookingResponseModelImpl value,
          $Res Function(_$CreateBookingResponseModelImpl) then) =
      __$$CreateBookingResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      String? razorpayOrderId,
      @JsonKey(name: 'advanceAmount') dynamic onlineAmount,
      @JsonKey(defaultValue: 'INR') String currency});
}

/// @nodoc
class __$$CreateBookingResponseModelImplCopyWithImpl<$Res>
    extends _$CreateBookingResponseModelCopyWithImpl<$Res,
        _$CreateBookingResponseModelImpl>
    implements _$$CreateBookingResponseModelImplCopyWith<$Res> {
  __$$CreateBookingResponseModelImplCopyWithImpl(
      _$CreateBookingResponseModelImpl _value,
      $Res Function(_$CreateBookingResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateBookingResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? razorpayOrderId = freezed,
    Object? onlineAmount = freezed,
    Object? currency = null,
  }) {
    return _then(_$CreateBookingResponseModelImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      razorpayOrderId: freezed == razorpayOrderId
          ? _value.razorpayOrderId
          : razorpayOrderId // ignore: cast_nullable_to_non_nullable
              as String?,
      onlineAmount: freezed == onlineAmount
          ? _value.onlineAmount
          : onlineAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBookingResponseModelImpl implements _CreateBookingResponseModel {
  const _$CreateBookingResponseModelImpl(
      {required this.bookingId,
      this.razorpayOrderId,
      @JsonKey(name: 'advanceAmount') required this.onlineAmount,
      @JsonKey(defaultValue: 'INR') required this.currency});

  factory _$CreateBookingResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreateBookingResponseModelImplFromJson(json);

  @override
  final String bookingId;
  @override
  final String? razorpayOrderId;
  @override
  @JsonKey(name: 'advanceAmount')
  final dynamic onlineAmount;
  @override
  @JsonKey(defaultValue: 'INR')
  final String currency;

  @override
  String toString() {
    return 'CreateBookingResponseModel(bookingId: $bookingId, razorpayOrderId: $razorpayOrderId, onlineAmount: $onlineAmount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBookingResponseModelImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.razorpayOrderId, razorpayOrderId) ||
                other.razorpayOrderId == razorpayOrderId) &&
            const DeepCollectionEquality()
                .equals(other.onlineAmount, onlineAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bookingId, razorpayOrderId,
      const DeepCollectionEquality().hash(onlineAmount), currency);

  /// Create a copy of CreateBookingResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBookingResponseModelImplCopyWith<_$CreateBookingResponseModelImpl>
      get copyWith => __$$CreateBookingResponseModelImplCopyWithImpl<
          _$CreateBookingResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBookingResponseModelImplToJson(
      this,
    );
  }
}

abstract class _CreateBookingResponseModel
    implements CreateBookingResponseModel {
  const factory _CreateBookingResponseModel(
          {required final String bookingId,
          final String? razorpayOrderId,
          @JsonKey(name: 'advanceAmount') required final dynamic onlineAmount,
          @JsonKey(defaultValue: 'INR') required final String currency}) =
      _$CreateBookingResponseModelImpl;

  factory _CreateBookingResponseModel.fromJson(Map<String, dynamic> json) =
      _$CreateBookingResponseModelImpl.fromJson;

  @override
  String get bookingId;
  @override
  String? get razorpayOrderId;
  @override
  @JsonKey(name: 'advanceAmount')
  dynamic get onlineAmount;
  @override
  @JsonKey(defaultValue: 'INR')
  String get currency;

  /// Create a copy of CreateBookingResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateBookingResponseModelImplCopyWith<_$CreateBookingResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
