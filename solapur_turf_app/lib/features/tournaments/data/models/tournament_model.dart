import '../../domain/entities/tournament.dart';
import '../../../teams/data/models/team_model.dart';

/// Maps raw JSON from the backend to Tournament and TournamentMatch domain entities.
/// Backend uses camelCase (Jackson default). Field names match TournamentDto.java.
class TournamentModel {
  static Tournament fromJson(Map<String, dynamic> j) {
    // Backend: tournamentStatus (TournamentStatus enum), registration: registrationStatus
    // Flutter entity uses: TournamentStatus enum
    final rawStatus = j['tournamentStatus'] as String? ??
        j['tournament_status'] as String? ??
        j['status'] as String? ??
        'UPCOMING';

    // Backend: entryFeePerTeam (BigDecimal), Flutter: entryFee (double)
    final entryFee = _toDouble(j['entryFeePerTeam'] ?? j['entry_fee_per_team'] ?? j['entryFee']);

    // Backend: prizePoolWinner (BigDecimal), Flutter: prizePool (double?)
    final prizePool = j['prizePoolWinner'] != null
        ? _toDouble(j['prizePoolWinner'])
        : (j['prize_pool_winner'] != null ? _toDouble(j['prize_pool_winner']) : null);

    // Backend: format (TournamentFormat enum string), Flutter: format (String)
    final format = j['format']?.toString() ?? 'KNOCKOUT';

    // Backend: startDate/endDate as LocalDate (yyyy-MM-dd)
    final startDate = _dateToString(j['startDate'] ?? j['start_date']);
    final endDate = _dateToString(j['endDate'] ?? j['end_date']);

    return Tournament(
      tournamentId: (j['id'] ?? j['tournamentId'] ?? '').toString(),
      name: j['name'] as String? ?? '',
      sportType: j['sportType']?.toString() ?? j['sport_type']?.toString() ?? '',
      format: format,
      entryFee: entryFee,
      prizePool: prizePool,
      maxTeams: (j['maxTeams'] as int?) ?? (j['max_teams'] as int?) ?? 0,
      registeredTeams: _registeredTeamsCount(j),
      status: TournamentStatusX.fromString(rawStatus),
      startDate: startDate,
      endDate: endDate,
      turfId: j['turfId']?.toString() ?? j['turf_id']?.toString(),
      turfName: j['turfName'] as String? ?? j['turf_name'] as String?,
      description: j['description'] as String?,
    );
  }

  static TournamentMatch matchFromJson(Map<String, dynamic> j, String tournamentId) {
    final rawStatus = j['status'] as String? ?? 'UPCOMING';
    return TournamentMatch(
      matchId: (j['id'] ?? j['matchId'] ?? '').toString(),
      tournamentId: tournamentId,
      round: (j['round'] as int?) ?? 1,
      matchNumber: (j['matchNumber'] as int?) ?? (j['matchOrder'] as int?) ?? 1,
      teamA: j['teamA'] != null
          ? TeamModel.fromJson(j['teamA'] as Map<String, dynamic>)
          : null,
      teamB: j['teamB'] != null
          ? TeamModel.fromJson(j['teamB'] as Map<String, dynamic>)
          : null,
      scoreA: j['scoreA'] as int?,
      scoreB: j['scoreB'] as int?,
      status: TournamentMatchStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == rawStatus.toUpperCase(),
        orElse: () => TournamentMatchStatus.upcoming,
      ),
      winnerId: j['winner'] != null ? j['winner']['id']?.toString() : null,
      scheduledStartTime: j['scheduledStartTime'] as String?,
    );
  }

  static Map<String, dynamic> toCreateJson({
    required String name,
    required String sportType,
    required String format,
    required double entryFee,
    required int maxTeams,
    required String startDate,
    required String endDate,
    String? turfId,
    String? description,
    double? prizePool,
  }) =>
      {
        'name': name,
        'sportType': sportType,
        'format': format,
        'entryFeePerTeam': entryFee, // backend field name
        'maxTeams': maxTeams,
        'startDate': startDate,
        'endDate': endDate,
        if (turfId != null) 'turfId': turfId,
        if (description != null && description.isNotEmpty) 'description': description,
        if (prizePool != null) 'prizePoolWinner': prizePool, // backend field name
      };

  static int _registeredTeamsCount(Map<String, dynamic> j) {
    // Not returned directly by backend TournamentDto, fallback to 0
    return (j['registeredTeams'] as int?) ??
        (j['registered_teams'] as int?) ??
        0;
  }

  static String _dateToString(dynamic val) {
    if (val == null) return '';
    return val.toString(); // LocalDate serializes as "yyyy-MM-dd"
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
