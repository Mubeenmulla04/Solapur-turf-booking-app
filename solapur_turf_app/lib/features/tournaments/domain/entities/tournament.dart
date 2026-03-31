import 'package:freezed_annotation/freezed_annotation.dart';

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
    String? registrationDeadline,
    String? turfName,
    String? description,
  }) = _Tournament;
}
