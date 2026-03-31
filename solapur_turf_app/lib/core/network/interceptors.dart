import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'token_storage.dart';

/// Injects the Bearer token into every outgoing request automatically.
/// If no token is stored, the request goes through without Authorization header
/// (so public endpoints like /auth/login still work).
class AuthInterceptor extends Interceptor {
  final TokenStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Handles 401 Unauthorized responses globally.
///
/// When a 401 is received:
/// 1. Clears all stored tokens (user is effectively logged out)
/// 2. Throws [UnauthorizedException] so the Riverpod auth state can react
///    and redirect the user to the login screen.
///
/// To use: Listen to authStateProvider changes and navigate to login
/// whenever the state transitions to unauthenticated.
class UnauthorizedInterceptor extends Interceptor {
  final TokenStorage _storage;
  final void Function()? onUnauthorized; // Optional callback to trigger logout

  UnauthorizedInterceptor(this._storage, {this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear tokens without awaiting — fire and forget
      _storage.clearAll().then((_) {
        // Trigger navigation callback if provided
        onUnauthorized?.call();
      });
    }
    handler.next(err);
  }
}

/// Retries failed network requests with exponential backoff.
/// Only retries on network errors (connection refused, timeout) — NOT on 4xx/5xx.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor(this._dio, {this.maxRetries = AppConstants.maxRetryAttempts});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final opts = err.requestOptions;
    final retryCount = (opts.extra['retry_count'] as int?) ?? 0;

    final isRetryable = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (isRetryable && retryCount < maxRetries) {
      opts.extra['retry_count'] = retryCount + 1;
      // Exponential backoff: 1s → 2s → 3s
      await Future.delayed(Duration(seconds: retryCount + 1));
      try {
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } catch (_) {
        // Fall through to original error on retry failure
      }
    }
    handler.next(err);
  }
}

/// Converts [DioException] to typed [AppException] subclasses.
/// This runs AFTER UnauthorizedInterceptor, so 401 is already handled.
///
/// The converted exception is stored in DioException.error and DioException.message
/// so that catch blocks in data sources can access it via e.error as AppException.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = AppException.fromDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
        message: appException.message,
      ),
    );
  }
}

/// A simple RAM-based API Cache for GET requests.
/// Prevents the frontend from spamming the backend over static list queries.
class CacheInterceptor extends Interceptor {
  final Map<String, _CacheEntry> _cache = {};
  final Duration maxAge; // How long to store the cache

  CacheInterceptor({this.maxAge = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method != 'GET') {
      return handler.next(options);
    }

    // Force network fetch and bypass cache if requested
    if (options.extra['refresh'] == true) {
      return handler.next(options);
    }

    // Build unique cache key using endpoint + query params
    final key = '${options.uri}';
    final entry = _cache[key];

    if (entry != null && DateTime.now().isBefore(entry.expiration)) {
      // CACHE HIT: Return instantly without network request (O(1) resolution)
      return handler.resolve(Response(
        requestOptions: options,
        data: entry.data,
        statusCode: 200,
        statusMessage: 'OK (Cached)',
      ));
    }

    // CACHE MISS: Proceed to network
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final key = '${response.requestOptions.uri}';
      _cache[key] = _CacheEntry(
        data: response.data,
        expiration: DateTime.now().add(maxAge),
      );
    }
    handler.next(response);
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiration;

  _CacheEntry({required this.data, required this.expiration});
}

