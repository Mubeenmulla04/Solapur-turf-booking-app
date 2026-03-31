import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String email,
    required String fullName,
    required String role,
    String? phone,
    @Default(0.0) double walletBalance,
    @Default(0) int loyaltyPoints,
    String? favoriteSports,
    String? preferredTimeSlots,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension AuthResponseModelX on AuthResponseModel {
  AuthResponse toDomain() => AuthResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user.toDomain(),
      );
}

extension UserModelX on UserModel {
  User toDomain() => User(
        userId: userId,
        email: email,
        fullName: fullName,
        role: UserRoleX.fromString(role),
        phone: phone,
        walletBalance: walletBalance,
        loyaltyPoints: loyaltyPoints,
        favoriteSports: favoriteSports,
        preferredTimeSlots: preferredTimeSlots,
      );
}
