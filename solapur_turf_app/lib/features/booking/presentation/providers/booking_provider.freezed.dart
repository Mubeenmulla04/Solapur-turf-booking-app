// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BookingFlowState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingFlowStateCopyWith<$Res> {
  factory $BookingFlowStateCopyWith(
          BookingFlowState value, $Res Function(BookingFlowState) then) =
      _$BookingFlowStateCopyWithImpl<$Res, BookingFlowState>;
}

/// @nodoc
class _$BookingFlowStateCopyWithImpl<$Res, $Val extends BookingFlowState>
    implements $BookingFlowStateCopyWith<$Res> {
  _$BookingFlowStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
          _$IdleImpl value, $Res Function(_$IdleImpl) then) =
      __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$BookingFlowStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'BookingFlowState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements BookingFlowState {
  const factory _Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$CreatingImplCopyWith<$Res> {
  factory _$$CreatingImplCopyWith(
          _$CreatingImpl value, $Res Function(_$CreatingImpl) then) =
      __$$CreatingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CreatingImplCopyWithImpl<$Res>
    extends _$BookingFlowStateCopyWithImpl<$Res, _$CreatingImpl>
    implements _$$CreatingImplCopyWith<$Res> {
  __$$CreatingImplCopyWithImpl(
      _$CreatingImpl _value, $Res Function(_$CreatingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CreatingImpl implements _Creating {
  const _$CreatingImpl();

  @override
  String toString() {
    return 'BookingFlowState.creating()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CreatingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) {
    return creating();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) {
    return creating?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (creating != null) {
      return creating();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) {
    return creating(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) {
    return creating?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) {
    if (creating != null) {
      return creating(this);
    }
    return orElse();
  }
}

abstract class _Creating implements BookingFlowState {
  const factory _Creating() = _$CreatingImpl;
}

/// @nodoc
abstract class _$$AwaitingPaymentImplCopyWith<$Res> {
  factory _$$AwaitingPaymentImplCopyWith(_$AwaitingPaymentImpl value,
          $Res Function(_$AwaitingPaymentImpl) then) =
      __$$AwaitingPaymentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CreateBookingResult result});

  $CreateBookingResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$AwaitingPaymentImplCopyWithImpl<$Res>
    extends _$BookingFlowStateCopyWithImpl<$Res, _$AwaitingPaymentImpl>
    implements _$$AwaitingPaymentImplCopyWith<$Res> {
  __$$AwaitingPaymentImplCopyWithImpl(
      _$AwaitingPaymentImpl _value, $Res Function(_$AwaitingPaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
  }) {
    return _then(_$AwaitingPaymentImpl(
      null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as CreateBookingResult,
    ));
  }

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateBookingResultCopyWith<$Res> get result {
    return $CreateBookingResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$AwaitingPaymentImpl implements _AwaitingPayment {
  const _$AwaitingPaymentImpl(this.result);

  @override
  final CreateBookingResult result;

  @override
  String toString() {
    return 'BookingFlowState.awaitingPayment(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AwaitingPaymentImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AwaitingPaymentImplCopyWith<_$AwaitingPaymentImpl> get copyWith =>
      __$$AwaitingPaymentImplCopyWithImpl<_$AwaitingPaymentImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) {
    return awaitingPayment(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) {
    return awaitingPayment?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (awaitingPayment != null) {
      return awaitingPayment(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) {
    return awaitingPayment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) {
    return awaitingPayment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) {
    if (awaitingPayment != null) {
      return awaitingPayment(this);
    }
    return orElse();
  }
}

abstract class _AwaitingPayment implements BookingFlowState {
  const factory _AwaitingPayment(final CreateBookingResult result) =
      _$AwaitingPaymentImpl;

  CreateBookingResult get result;

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AwaitingPaymentImplCopyWith<_$AwaitingPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VerifyingImplCopyWith<$Res> {
  factory _$$VerifyingImplCopyWith(
          _$VerifyingImpl value, $Res Function(_$VerifyingImpl) then) =
      __$$VerifyingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VerifyingImplCopyWithImpl<$Res>
    extends _$BookingFlowStateCopyWithImpl<$Res, _$VerifyingImpl>
    implements _$$VerifyingImplCopyWith<$Res> {
  __$$VerifyingImplCopyWithImpl(
      _$VerifyingImpl _value, $Res Function(_$VerifyingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VerifyingImpl implements _Verifying {
  const _$VerifyingImpl();

  @override
  String toString() {
    return 'BookingFlowState.verifying()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VerifyingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) {
    return verifying();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) {
    return verifying?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (verifying != null) {
      return verifying();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) {
    return verifying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) {
    return verifying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) {
    if (verifying != null) {
      return verifying(this);
    }
    return orElse();
  }
}

abstract class _Verifying implements BookingFlowState {
  const factory _Verifying() = _$VerifyingImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl value, $Res Function(_$SuccessImpl) then) =
      __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Booking booking});

  $BookingCopyWith<$Res> get booking;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$BookingFlowStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl _value, $Res Function(_$SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? booking = null,
  }) {
    return _then(_$SuccessImpl(
      null == booking
          ? _value.booking
          : booking // ignore: cast_nullable_to_non_nullable
              as Booking,
    ));
  }

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingCopyWith<$Res> get booking {
    return $BookingCopyWith<$Res>(_value.booking, (value) {
      return _then(_value.copyWith(booking: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.booking);

  @override
  final Booking booking;

  @override
  String toString() {
    return 'BookingFlowState.success(booking: $booking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.booking, booking) || other.booking == booking));
  }

  @override
  int get hashCode => Object.hash(runtimeType, booking);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) {
    return success(booking);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) {
    return success?.call(booking);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(booking);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements BookingFlowState {
  const factory _Success(final Booking booking) = _$SuccessImpl;

  Booking get booking;

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FlowErrorImplCopyWith<$Res> {
  factory _$$FlowErrorImplCopyWith(
          _$FlowErrorImpl value, $Res Function(_$FlowErrorImpl) then) =
      __$$FlowErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$FlowErrorImplCopyWithImpl<$Res>
    extends _$BookingFlowStateCopyWithImpl<$Res, _$FlowErrorImpl>
    implements _$$FlowErrorImplCopyWith<$Res> {
  __$$FlowErrorImplCopyWithImpl(
      _$FlowErrorImpl _value, $Res Function(_$FlowErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$FlowErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FlowErrorImpl implements _FlowError {
  const _$FlowErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'BookingFlowState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlowErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlowErrorImplCopyWith<_$FlowErrorImpl> get copyWith =>
      __$$FlowErrorImplCopyWithImpl<_$FlowErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() creating,
    required TResult Function(CreateBookingResult result) awaitingPayment,
    required TResult Function() verifying,
    required TResult Function(Booking booking) success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? creating,
    TResult? Function(CreateBookingResult result)? awaitingPayment,
    TResult? Function()? verifying,
    TResult? Function(Booking booking)? success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? creating,
    TResult Function(CreateBookingResult result)? awaitingPayment,
    TResult Function()? verifying,
    TResult Function(Booking booking)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Creating value) creating,
    required TResult Function(_AwaitingPayment value) awaitingPayment,
    required TResult Function(_Verifying value) verifying,
    required TResult Function(_Success value) success,
    required TResult Function(_FlowError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Creating value)? creating,
    TResult? Function(_AwaitingPayment value)? awaitingPayment,
    TResult? Function(_Verifying value)? verifying,
    TResult? Function(_Success value)? success,
    TResult? Function(_FlowError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Creating value)? creating,
    TResult Function(_AwaitingPayment value)? awaitingPayment,
    TResult Function(_Verifying value)? verifying,
    TResult Function(_Success value)? success,
    TResult Function(_FlowError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _FlowError implements BookingFlowState {
  const factory _FlowError(final String message) = _$FlowErrorImpl;

  String get message;

  /// Create a copy of BookingFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlowErrorImplCopyWith<_$FlowErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
