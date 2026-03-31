// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamImpl _$$TeamImplFromJson(Map<String, dynamic> json) => _$TeamImpl(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      teamCode: json['teamCode'] as String,
      sportType: json['sportType'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      homeCity: json['homeCity'] as String?,
      memberCount: (json['memberCount'] as num).toInt(),
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TeamImplToJson(_$TeamImpl instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamCode': instance.teamCode,
      'sportType': instance.sportType,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'homeCity': instance.homeCity,
      'memberCount': instance.memberCount,
      'members': instance.members,
    };

_$TeamMemberImpl _$$TeamMemberImplFromJson(Map<String, dynamic> json) =>
    _$TeamMemberImpl(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$TeamMemberRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$$TeamMemberImplToJson(_$TeamMemberImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'email': instance.email,
      'role': _$TeamMemberRoleEnumMap[instance.role]!,
    };

const _$TeamMemberRoleEnumMap = {
  TeamMemberRole.admin: 'admin',
  TeamMemberRole.member: 'member',
};
