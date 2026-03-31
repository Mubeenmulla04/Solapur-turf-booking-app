import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';
part 'team.g.dart';

enum TeamMemberRole { admin, member }

@freezed
class Team with _$Team {
  const factory Team({
    required String teamId,
    required String teamName,
    required String teamCode,
    required String sportType,
    String? description,
    String? logoUrl,
    String? homeCity,
    required int memberCount,
    List<TeamMember>? members,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

@freezed
class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String userId,
    required String fullName,
    required String email,
    required TeamMemberRole role,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
}
