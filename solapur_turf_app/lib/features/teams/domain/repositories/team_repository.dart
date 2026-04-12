import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/team.dart';

abstract class TeamRepository {
  /// Returns all teams the current authenticated user belongs to.
  Future<Either<Failure, List<Team>>> getMyTeams();

  /// Returns full detail for a single team including member roster.
  Future<Either<Failure, Team>> getTeamById(String teamId);

  /// Creates a new team and returns the created Team entity.
  Future<Either<Failure, Team>> createTeam({
    required String teamName,
    required String sportType,
    String? description,
    String? homeCity,
  });

  /// Joins an existing team using an 8-character team code.
  Future<Either<Failure, Team>> joinTeam(String teamCode);

  /// Leaves the current user from the given team.
  Future<Either<Failure, void>> leaveTeam(String teamId);
}
