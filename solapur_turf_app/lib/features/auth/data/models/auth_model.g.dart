// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseModelImpl _$$AuthResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthResponseModelImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseModelImplToJson(
        _$AuthResponseModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      favoriteSports: json['favoriteSports'] as String?,
      preferredTimeSlots: json['preferredTimeSlots'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': instance.role,
      'phone': instance.phone,
      'walletBalance': instance.walletBalance,
      'loyaltyPoints': instance.loyaltyPoints,
      'favoriteSports': instance.favoriteSports,
      'preferredTimeSlots': instance.preferredTimeSlots,
    };
