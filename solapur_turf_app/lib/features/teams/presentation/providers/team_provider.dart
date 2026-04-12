import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/team_remote_datasource.dart';
import '../../data/repositories/team_repository_impl.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return TeamRepositoryImpl(TeamRemoteDataSource(dio));
});

// ── Read Providers ────────────────────────────────────────────────────────────

/// My teams list
final myTeamsProvider = FutureProvider.autoDispose<List<Team>>((ref) async {
  final result = await ref.watch(teamRepositoryProvider).getMyTeams();
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (teams) => teams,
  );
});

/// Single team detail
final teamDetailProvider =
    FutureProvider.autoDispose.family<Team, String>((ref, teamId) async {
  final result = await ref.watch(teamRepositoryProvider).getTeamById(teamId);
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (team) => team,
  );
});

// ── Mutation Notifier ─────────────────────────────────────────────────────────

/// State for team mutations: createTeam and joinTeam
class TeamMutationNotifier extends StateNotifier<AsyncValue<Team?>> {
  final TeamRepository _repo;
  TeamMutationNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<Team?> createTeam({
    required String teamName,
    required String sportType,
    String? description,
    String? homeCity,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repo.createTeam(
      teamName: teamName,
      sportType: sportType,
      description: description,
      homeCity: homeCity,
    );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.userMessage, StackTrace.current);
        return null;
      },
      (team) {
        state = AsyncValue.data(team);
        return team;
      },
    );
  }

  Future<Team?> joinTeam(String teamCode) async {
    state = const AsyncValue.loading();
    final result = await _repo.joinTeam(teamCode);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.userMessage, StackTrace.current);
        return null;
      },
      (team) {
        state = AsyncValue.data(team);
        return team;
      },
    );
  }

  Future<bool> leaveTeam(String teamId) async {
    state = const AsyncValue.loading();
    final result = await _repo.leaveTeam(teamId);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.userMessage, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

final teamMutationProvider =
    StateNotifierProvider.autoDispose<TeamMutationNotifier, AsyncValue<Team?>>((ref) {
  return TeamMutationNotifier(ref.read(teamRepositoryProvider));
});
