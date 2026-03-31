import 'package:dio/dio.dart';

/// Typed exceptions that mirror the backend's error response format:
/// { timestamp, status, error, message, path, errors? }
///
/// The hierarchy lets callers catch specific types:
///   on UnauthorizedException → redirect to login
///   on ForbiddenException    → show access denied
///   on NotFoundException     → show not found
///   on ConflictException     → show conflict message
///   on ValidationException   → show field errors
///   on ServerException       → show retry button
///   on NetworkException      → show no internet message
///   on AppException          → generic fallback
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final List<String>? errors; // filled from backend 'errors' list on validation failures

  const AppException(this.message, {this.statusCode, this.errors});

  /// Maps a [DioException] to the correct typed [AppException].
  factory AppException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection. Please check your network.');
      case DioExceptionType.badResponse:
        return AppException.fromResponse(e.response);
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      default:
        return AppException.unknown(e.message ?? 'An unexpected error occurred.');
    }
  }

  /// Maps a [Response] with an error status code to a typed [AppException].
  /// Parses the backend's standard ErrorResponse JSON format.
  factory AppException.fromResponse(Response? response) {
    if (response == null) {
      return const NetworkException('No response from server.');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = 'Server error ($statusCode)';
    List<String>? errors;

    if (data is Map<String, dynamic>) {
      // Parse backend ErrorResponse: { message, errors }
      message = data['message']?.toString() ?? message;
      final rawErrors = data['errors'];
      if (rawErrors is List) {
        errors = rawErrors.map((e) => e.toString()).toList();
      }
    }

    // Map status code to typed exception
    switch (statusCode) {
      case 400:
        return ValidationException(message, statusCode: statusCode, errors: errors);
      case 401:
        return UnauthorizedException(message, statusCode: statusCode);
      case 403:
        return ForbiddenException(message, statusCode: statusCode);
      case 404:
        return NotFoundException(message, statusCode: statusCode);
      case 409:
        return ConflictException(message, statusCode: statusCode);
      case 500:
      case 502:
      case 503:
        return ServerException(message, statusCode: statusCode);
      default:
        return ServerException(message, statusCode: statusCode);
    }
  }

  factory AppException.unknown(String message) => ServerException(message);

  @override
  String toString() => '${runtimeType}: $message (status: $statusCode)';
}

// ── Typed Exception Subclasses ───────────────────────────────────────────────

/// 400 Bad Request — validation errors from @Valid or ValidationException
/// Flutter: display errors list under corresponding form fields
class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode, super.errors});
}

/// 401 Unauthorized — token missing, expired, or invalid
/// Flutter: clear token + navigate to Login screen
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode});
}

/// 403 Forbidden — authenticated but not permitted
/// Flutter: show "Access Denied" page or snackbar
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.statusCode});
}

/// 404 Not Found — resource doesn't exist
/// Flutter: show "Not Found" message or navigate back
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode});
}

/// 409 Conflict — duplicate resource or booking conflict
/// Flutter: show exact backend message (e.g., "Slot already booked")
class ConflictException extends AppException {
  const ConflictException(super.message, {super.statusCode});
}

/// 500 / 502 / 503 — backend crashed or is down
/// Flutter: show "Something went wrong, please try again" with retry button
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Network-level error — no connectivity, timeout, etc.
/// Flutter: show "No internet connection" message
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}
