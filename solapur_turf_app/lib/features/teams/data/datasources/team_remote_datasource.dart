import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/team.dart';
import '../models/team_model.dart';

/// Remote data source that talks to the backend /teams endpoints.
class TeamRemoteDataSource {
  final Dio _dio;
  const TeamRemoteDataSource(this._dio);

  Future<List<Team>> getMyTeams() async {
    try {
      final res = await _dio.get('/teams/my-teams');
      final data = (res.data is Map ? res.data['data'] : res.data) as List<dynamic>;
      return data.map((j) => TeamModel.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Team> getTeamById(String teamId) async {
    try {
      final res = await _dio.get('/teams/$teamId');
      final j = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : (res.data['data'] as Map<String, dynamic>);
      return TeamModel.fromJson(j);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Team> createTeam({
    required String teamName,
    required String sportType,
    String? description,
    String? homeCity,
  }) async {
    try {
      final res = await _dio.post(
        '/teams',
        data: TeamModel.toCreateJson(
          teamName: teamName,
          sportType: sportType,
          description: description,
          homeCity: homeCity,
        ),
      );
      final j = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : (res.data['data'] as Map<String, dynamic>);
      return TeamModel.fromJson(j);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Team> joinTeam(String teamCode) async {
    try {
      final res = await _dio.post('/teams/join', data: {'teamCode': teamCode.toUpperCase()});
      final j = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : (res.data['data'] as Map<String, dynamic>);
      return TeamModel.fromJson(j);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<void> leaveTeam(String teamId) async {
    try {
      await _dio.delete('/teams/$teamId/leave');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
