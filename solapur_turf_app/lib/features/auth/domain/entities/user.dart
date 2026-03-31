import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserRole { user, owner, admin }

extension UserRoleX on UserRole {
  String get value => name.toUpperCase();

  static UserRole fromString(String s) => switch (s.toUpperCase()) {
        'OWNER' => UserRole.owner,
        'ADMIN' => UserRole.admin,
        _ => UserRole.user,
      };
}

/// Core user domain entity — no JSON dependency.
@freezed
class User with _$User {
  const factory User({
    required String userId,
    required String email,
    required String fullName,
    required UserRole role,
    String? phone,
    @Default(0.0) double walletBalance,
    @Default(0) int loyaltyPoints,
    String? favoriteSports,
    String? preferredTimeSlots,
  }) = _User;
}

/// Holds tokens + user info after successful auth.
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required User user,
  }) = _AuthResponse;
}
