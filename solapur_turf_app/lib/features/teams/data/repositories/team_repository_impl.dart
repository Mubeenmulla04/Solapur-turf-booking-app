import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_datasource.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource _remote;
  const TeamRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Team>>> getMyTeams() async {
    try {
      final teams = await _remote.getMyTeams();
      return Right(teams);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Team>> getTeamById(String teamId) async {
    try {
      final team = await _remote.getTeamById(teamId);
      return Right(team);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Team>> createTeam({
    required String teamName,
    required String sportType,
    String? description,
    String? homeCity,
  }) async {
    try {
      final team = await _remote.createTeam(
        teamName: teamName,
        sportType: sportType,
        description: description,
        homeCity: homeCity,
      );
      return Right(team);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Team>> joinTeam(String teamCode) async {
    try {
      final team = await _remote.joinTeam(teamCode);
      return Right(team);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(String teamId) async {
    try {
      await _remote.leaveTeam(teamId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
