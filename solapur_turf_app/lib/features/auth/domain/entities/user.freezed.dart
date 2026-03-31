// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$User {
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  double get walletBalance => throw _privateConstructorUsedError;
  int get loyaltyPoints => throw _privateConstructorUsedError;
  String? get favoriteSports => throw _privateConstructorUsedError;
  String? get preferredTimeSlots => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String userId,
      String email,
      String fullName,
      UserRole role,
      String? phone,
      double walletBalance,
      int loyaltyPoints,
      String? favoriteSports,
      String? preferredTimeSlots});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = null,
    Object? phone = freezed,
    Object? walletBalance = null,
    Object? loyaltyPoints = null,
    Object? favoriteSports = freezed,
    Object? preferredTimeSlots = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      loyaltyPoints: null == loyaltyPoints
          ? _value.loyaltyPoints
          : loyaltyPoints // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteSports: freezed == favoriteSports
          ? _value.favoriteSports
          : favoriteSports // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredTimeSlots: freezed == preferredTimeSlots
          ? _value.preferredTimeSlots
          : preferredTimeSlots // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String email,
      String fullName,
      UserRole role,
      String? phone,
      double walletBalance,
      int loyaltyPoints,
      String? favoriteSports,
      String? preferredTimeSlots});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = null,
    Object? phone = freezed,
    Object? walletBalance = null,
    Object? loyaltyPoints = null,
    Object? favoriteSports = freezed,
    Object? preferredTimeSlots = freezed,
  }) {
    return _then(_$UserImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      loyaltyPoints: null == loyaltyPoints
          ? _value.loyaltyPoints
          : loyaltyPoints // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteSports: freezed == favoriteSports
          ? _value.favoriteSports
          : favoriteSports // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredTimeSlots: freezed == preferredTimeSlots
          ? _value.preferredTimeSlots
          : preferredTimeSlots // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.userId,
      required this.email,
      required this.fullName,
      required this.role,
      this.phone,
      this.walletBalance = 0.0,
      this.loyaltyPoints = 0,
      this.favoriteSports,
      this.preferredTimeSlots});

  @override
  final String userId;
  @override
  final String email;
  @override
  final String fullName;
  @override
  final UserRole role;
  @override
  final String? phone;
  @override
  @JsonKey()
  final double walletBalance;
  @override
  @JsonKey()
  final int loyaltyPoints;
  @override
  final String? favoriteSports;
  @override
  final String? preferredTimeSlots;

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, fullName: $fullName, role: $role, phone: $phone, walletBalance: $walletBalance, loyaltyPoints: $loyaltyPoints, favoriteSports: $favoriteSports, preferredTimeSlots: $preferredTimeSlots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            (identical(other.loyaltyPoints, loyaltyPoints) ||
                other.loyaltyPoints == loyaltyPoints) &&
            (identical(other.favoriteSports, favoriteSports) ||
                other.favoriteSports == favoriteSports) &&
            (identical(other.preferredTimeSlots, preferredTimeSlots) ||
                other.preferredTimeSlots == preferredTimeSlots));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, email, fullName, role,
      phone, walletBalance, loyaltyPoints, favoriteSports, preferredTimeSlots);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);
}

abstract class _User implements User {
  const factory _User(
      {required final String userId,
      required final String email,
      required final String fullName,
      required final UserRole role,
      final String? phone,
      final double walletBalance,
      final int loyaltyPoints,
      final String? favoriteSports,
      final String? preferredTimeSlots}) = _$UserImpl;

  @override
  String get userId;
  @override
  String get email;
  @override
  String get fullName;
  @override
  UserRole get role;
  @override
  String? get phone;
  @override
  double get walletBalance;
  @override
  int get loyaltyPoints;
  @override
  String? get favoriteSports;
  @override
  String? get preferredTimeSlots;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AuthResponse {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
          AuthResponse value, $Res Function(AuthResponse) then) =
      _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({String accessToken, String refreshToken, User user});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
    ) as $Val);
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
          _$AuthResponseImpl value, $Res Function(_$AuthResponseImpl) then) =
      __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String refreshToken, User user});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
      _$AuthResponseImpl _value, $Res Function(_$AuthResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? user = null,
  }) {
    return _then(_$AuthResponseImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
    ));
  }
}

/// @nodoc

class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl(
      {required this.accessToken,
      required this.refreshToken,
      required this.user});

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final User user;

  @override
  String toString() {
    return 'AuthResponse(accessToken: $accessToken, refreshToken: $refreshToken, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken, user);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse(
      {required final String accessToken,
      required final String refreshToken,
      required final User user}) = _$AuthResponseImpl;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  User get user;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
