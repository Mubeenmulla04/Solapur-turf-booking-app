import '../../domain/entities/team.dart';

/// Maps raw JSON from the backend TeamDto into domain [Team] and [TeamMember] entities.
///
/// Backend TeamDto fields: id, name, inviteCode, captainId, sportType, city,
///   logoUrl, description, isActive, members (if expanded).
/// Flutter also sends: teamName, homeCity, teamCode (handled via @JsonAlias on backend).
class TeamModel {
  static Team fromJson(Map<String, dynamic> j) {
    final rawMembers = j['members'] as List<dynamic>?;
    final members = rawMembers?.map((m) => _memberFromJson(m as Map<String, dynamic>)).toList();

    // Backend serializes: name (TeamDto.name), city (TeamDto.city), inviteCode
    // Flutter may receive either the DTO fields or the aliased field names.
    final teamName = j['name'] as String? ??          // backend canonical
        j['teamName'] as String? ??                    // Flutter alias
        j['team_name'] as String? ??                   // snake_case
        '';
    final teamCode = j['inviteCode'] as String? ??    // backend canonical
        j['teamCode'] as String? ??                    // Flutter alias
        j['invite_code'] as String? ??                 // snake_case
        j['team_code'] as String? ??                   // alt snake_case
        '';
    final city = j['city'] as String? ??              // backend canonical
        j['homeCity'] as String? ??                    // Flutter alias
        j['home_city'] as String?;                     // snake_case

    return Team(
      teamId: (j['id'] ?? j['teamId'] ?? j['team_id'] ?? '').toString(),
      teamName: teamName,
      teamCode: teamCode,
      sportType: j['sportType']?.toString() ?? j['sport_type']?.toString() ?? '',
      description: j['description'] as String?,
      logoUrl: j['logoUrl'] as String? ?? j['logo_url'] as String?,
      homeCity: city,
      memberCount: (j['memberCount'] as int?) ??
          (j['member_count'] as int?) ??
          members?.length ??
          0,
      members: members,
    );
  }

  static TeamMember _memberFromJson(Map<String, dynamic> j) => TeamMember(
        userId: (j['userId'] ?? j['user_id'] ?? j['id'] ?? '').toString(),
        fullName: j['fullName'] as String? ?? j['full_name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        role: (j['role'] as String? ?? '').toUpperCase() == 'ADMIN' ||
                (j['role'] as String? ?? '').toUpperCase() == 'CAPTAIN'
            ? TeamMemberRole.admin
            : TeamMemberRole.member,
      );

  static Map<String, dynamic> toCreateJson({
    required String teamName,
    required String sportType,
    String? description,
    String? homeCity,
  }) =>
      {
        // Send both the backend canonical name and the alias (backend accepts either via @JsonAlias)
        'name': teamName,
        'teamName': teamName,     // backend @JsonAlias fallback
        'sportType': sportType,
        if (description != null && description.isNotEmpty) 'description': description,
        if (homeCity != null && homeCity.isNotEmpty) ...{
          'city': homeCity,       // backend canonical
          'homeCity': homeCity,   // @JsonAlias fallback
        },
      };
}
