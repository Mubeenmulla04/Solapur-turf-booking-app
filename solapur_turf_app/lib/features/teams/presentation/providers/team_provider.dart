import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/team.dart';

final myTeamsProvider = FutureProvider.autoDispose<List<Team>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/teams/my-teams');
    final list = res.data['data'] as List<dynamic>;
    // Check if the model has fromJson
    return list.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
  } on DioException catch (e) {
    throw Exception('Failed to load teams: ${e.message}');
  }
});
