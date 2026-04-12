import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tournament.dart';

abstract class TournamentRepository {
  /// Returns all active/upcoming tournaments.
  Future<Either<Failure, List<Tournament>>> getTournaments();

  /// Returns a single tournament by ID.
  Future<Either<Failure, Tournament>> getTournamentById(String tournamentId);

  /// Returns bracket/match schedule for a tournament.
  Future<Either<Failure, List<TournamentMatch>>> getTournamentMatches(String tournamentId);

  /// Creates a new tournament (Owner only).
  Future<Either<Failure, Tournament>> createTournament({
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
  });

  /// Registers the current user's team in a tournament.
  Future<Either<Failure, void>> registerTeam({
    required String tournamentId,
    required String teamId,
  });

  /// Updates match score (Owner/Admin only).
  Future<Either<Failure, void>> updateMatchScore({
    required String tournamentId,
    required String matchId,
    required int scoreA,
    required int scoreB,
  });
}
