import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import 'interceptors.dart';
import 'token_storage.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(ApiClientRef ref) {
  final storage = ref.watch(tokenStorageProvider);
  return _buildDio(storage);
}

Dio _buildDio(TokenStorage storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    UnauthorizedInterceptor(storage),
    CacheInterceptor(),
    RetryInterceptor(dio),
    ErrorInterceptor(),
  if (AppConstants.enableLogging)
    PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: AppConstants.compactLogging,
    ),
  ]);

  return dio;
}
