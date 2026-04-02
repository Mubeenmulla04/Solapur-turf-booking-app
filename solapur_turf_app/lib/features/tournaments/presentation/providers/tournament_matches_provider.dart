import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/tournament.dart';

part 'tournament_matches_provider.g.dart';

@riverpod
class TournamentMatches extends _$TournamentMatches {
  @override
  Future<List<TournamentMatch>> build(String tournamentId) async {
    final dio = ref.watch(apiClientProvider);
    final response = await dio.get('/tournaments/$tournamentId/matches');
    final List<dynamic> data = response.data['data'] ?? [];
    
    return data.map((j) {
      return TournamentMatch(
        matchId: j['id'].toString(),
        tournamentId: tournamentId,
        round: j['round'] as int,
        matchNumber: j['matchNumber'] as int,
        teamA: j['teamA'] != null ? Team.fromJson(j['teamA']) : null,
        teamB: j['teamB'] != null ? Team.fromJson(j['teamB']) : null,
        scoreA: j['scoreA'] as int?,
        scoreB: j['scoreB'] as int?,
        status: TournamentMatchStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == (j['status'] as String? ?? 'UPCOMING').toUpperCase(),
          orElse: () => TournamentMatchStatus.upcoming,
        ),
        winnerId: j['winner'] != null ? j['winner']['id'].toString() : null,
      );
    }).toList();
  }

  Future<void> updateMatchScore(String matchId, int scoreA, int scoreB) async {
    final dio = ref.read(apiClientProvider);
    try {
      await dio.post(
        '/tournaments/$tournamentId/matches/$matchId/score',
        queryParameters: {
          'scoreA': scoreA,
          'scoreB': scoreB,
        },
      );
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}
