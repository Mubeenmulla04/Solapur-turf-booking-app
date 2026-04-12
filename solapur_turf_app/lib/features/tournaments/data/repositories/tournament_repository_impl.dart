import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_remote_datasource.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource _remote;
  const TournamentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Tournament>>> getTournaments() async {
    try {
      return Right(await _remote.getTournaments());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tournament>> getTournamentById(String id) async {
    try {
      return Right(await _remote.getTournamentById(id));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TournamentMatch>>> getTournamentMatches(String id) async {
    try {
      return Right(await _remote.getTournamentMatches(id));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      return Right(await _remote.createTournament(
        name: name,
        sportType: sportType,
        format: format,
        entryFee: entryFee,
        maxTeams: maxTeams,
        startDate: startDate,
        endDate: endDate,
        turfId: turfId,
        description: description,
        prizePool: prizePool,
      ));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    try {
      await _remote.registerTeam(tournamentId: tournamentId, teamId: teamId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMatchScore({
    required String tournamentId,
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    try {
      await _remote.updateMatchScore(
        tournamentId: tournamentId,
        matchId: matchId,
        scoreA: scoreA,
        scoreB: scoreB,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
