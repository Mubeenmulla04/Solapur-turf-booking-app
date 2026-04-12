import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/tournament_remote_datasource.dart';
import '../../data/repositories/tournament_repository_impl.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return TournamentRepositoryImpl(TournamentRemoteDataSource(dio));
});

// ── Read Providers ────────────────────────────────────────────────────────────

/// All tournaments list
final tournamentsProvider = FutureProvider.autoDispose<List<Tournament>>((ref) async {
  final result = await ref.watch(tournamentRepositoryProvider).getTournaments();
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (list) => list,
  );
});

/// Single tournament detail
final tournamentDetailProvider =
    FutureProvider.autoDispose.family<Tournament, String>((ref, id) async {
  final result = await ref.watch(tournamentRepositoryProvider).getTournamentById(id);
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (t) => t,
  );
});

/// Matches/bracket for a tournament
final tournamentMatchesProvider =
    FutureProvider.autoDispose.family<List<TournamentMatch>, String>((ref, id) async {
  final result = await ref.watch(tournamentRepositoryProvider).getTournamentMatches(id);
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (matches) => matches,
  );
});

// ── Mutation Notifiers ───────────────────────────────────────────────────────

/// State for tournament creation
class TournamentCreateNotifier extends StateNotifier<AsyncValue<Tournament?>> {
  final TournamentRepository _repo;
  TournamentCreateNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<Tournament?> createTournament({
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
    state = const AsyncValue.loading();
    final result = await _repo.createTournament(
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
    );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.userMessage, StackTrace.current);
        return null;
      },
      (tournament) {
        state = AsyncValue.data(tournament);
        return tournament;
      },
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

final tournamentCreateProvider =
    StateNotifierProvider.autoDispose<TournamentCreateNotifier, AsyncValue<Tournament?>>((ref) {
  return TournamentCreateNotifier(ref.read(tournamentRepositoryProvider));
});

/// State for team registration in a tournament
class TournamentRegistrationNotifier extends StateNotifier<AsyncValue<void>> {
  final TournamentRepository _repo;
  TournamentRegistrationNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> registerTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repo.registerTeam(
      tournamentId: tournamentId,
      teamId: teamId,
    );
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

final tournamentRegistrationProvider = StateNotifierProvider.autoDispose<
    TournamentRegistrationNotifier, AsyncValue<void>>((ref) {
  return TournamentRegistrationNotifier(ref.read(tournamentRepositoryProvider));
});

/// Score update notifier — used by TournamentMatches in admin/owner screens
class MatchScoreNotifier extends StateNotifier<AsyncValue<void>> {
  final TournamentRepository _repo;
  final String tournamentId;

  MatchScoreNotifier(this._repo, this.tournamentId)
      : super(const AsyncValue.data(null));

  Future<bool> updateScore({
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repo.updateMatchScore(
      tournamentId: tournamentId,
      matchId: matchId,
      scoreA: scoreA,
      scoreB: scoreB,
    );
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
}

final matchScoreProvider = StateNotifierProvider.autoDispose
    .family<MatchScoreNotifier, AsyncValue<void>, String>((ref, tournamentId) {
  return MatchScoreNotifier(ref.read(tournamentRepositoryProvider), tournamentId);
});
