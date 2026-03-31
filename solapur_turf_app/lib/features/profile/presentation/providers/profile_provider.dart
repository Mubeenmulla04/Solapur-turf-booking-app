import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/data/models/auth_model.dart';

// Provider to fetch the latest profile data separately from the auth token payload
final userProfileProvider = FutureProvider.autoDispose<User>((ref) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.get('/users/me');
    final model = UserModel.fromJson(res.data);
    return model.toDomain();
  } on DioException catch (e) {
    throw Exception('Failed to load profile: ${e.response?.data?['message'] ?? e.message}');
  }
});

// Provider to hold state for updating profile fields
final updateProfileProvider = FutureProvider.family.autoDispose<User, Map<String, dynamic>>((ref, updates) async {
  final dio = ref.watch(apiClientProvider);
  try {
    final res = await dio.put('/users/me', data: updates);
    final model = UserModel.fromJson(res.data);
    // Invalidate the profile provider so consumers get the new accurate state
    ref.invalidate(userProfileProvider);
    return model.toDomain();
  } on DioException catch (e) {
    throw Exception('Failed to update profile: ${e.response?.data?['message'] ?? e.message}');
  }
});
