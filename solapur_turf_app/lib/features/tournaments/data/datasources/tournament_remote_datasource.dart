import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/tournament.dart';
import '../models/tournament_model.dart';

/// Remote data source for all /tournaments backend endpoints.
class TournamentRemoteDataSource {
  final Dio _dio;
  const TournamentRemoteDataSource(this._dio);

  Future<List<Tournament>> getTournaments() async {
    try {
      final res = await _dio.get('/tournaments');
      final data = (res.data is Map ? res.data['data'] : res.data) as List<dynamic>;
      return data.map((j) => TournamentModel.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Tournament> getTournamentById(String tournamentId) async {
    try {
      final res = await _dio.get('/tournaments/$tournamentId');
      final j = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : (res.data['data'] as Map<String, dynamic>);
      return TournamentModel.fromJson(j);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<List<TournamentMatch>> getTournamentMatches(String tournamentId) async {
    try {
      final res = await _dio.get('/tournaments/$tournamentId/matches');
      final data = (res.data is Map ? (res.data['data'] ?? []) : res.data) as List<dynamic>;
      return data
          .map((j) => TournamentModel.matchFromJson(j as Map<String, dynamic>, tournamentId))
          .toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Tournament> createTournament({
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
      final res = await _dio.post(
        '/tournaments',
        data: TournamentModel.toCreateJson(
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
        ),
      );
      final j = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : (res.data['data'] as Map<String, dynamic>);
      return TournamentModel.fromJson(j);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> registerTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    try {
      await _dio.post(
        '/tournaments/$tournamentId/register',
        data: {'teamId': teamId},
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> updateMatchScore({
    required String tournamentId,
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    try {
      await _dio.post(
        '/tournaments/$tournamentId/matches/$matchId/score',
        queryParameters: {'scoreA': scoreA, 'scoreB': scoreB},
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
