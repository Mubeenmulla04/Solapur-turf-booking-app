import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../teams/domain/entities/team.dart';

part 'tournament.freezed.dart';

enum TournamentStatus { upcoming, ongoing, completed, cancelled }
enum TournamentFormat { knockout, league, roundRobin }

extension TournamentStatusX on TournamentStatus {
  String get label => switch (this) {
        TournamentStatus.upcoming => 'Upcoming',
        TournamentStatus.ongoing => 'Ongoing',
        TournamentStatus.completed => 'Completed',
        TournamentStatus.cancelled => 'Cancelled',
      };
  static TournamentStatus fromString(String s) => switch (s.toUpperCase()) {
        'ONGOING' => TournamentStatus.ongoing,
        'COMPLETED' => TournamentStatus.completed,
        'CANCELLED' => TournamentStatus.cancelled,
        _ => TournamentStatus.upcoming,
      };
}

@freezed
class Tournament with _$Tournament {
  const factory Tournament({
    required String tournamentId,
    required String name,
    required String sportType,
    required String format,
    required double entryFee,
    double? prizePool,
    required int maxTeams,
    required int registeredTeams,
    required TournamentStatus status,
    required String startDate,
    required String endDate,
    String? turfId,
    String? turfName,
    String? description,
  }) = _Tournament;
}

enum TournamentMatchStatus { upcoming, live, completed, cancelled }

@freezed
class TournamentMatch with _$TournamentMatch {
  const factory TournamentMatch({
    required String matchId,
    required String tournamentId,
    required int round,
    required int matchNumber,
    Team? teamA,
    Team? teamB,
    String? winnerId,
    int? scoreA,
    int? scoreB,
    required TournamentMatchStatus status,
    String? scheduledStartTime,
  }) = _TournamentMatch;
}
