import 'package:freezed_annotation/freezed_annotation.dart';
import 'exceptions.dart';

part 'failures.freezed.dart';

/// Domain-level failures — the clean architecture layer between
/// repositories (data layer) and use-cases/notifiers (domain/presentation).
///
/// Every AppException caught in a repository is converted to a Failure
/// and returned via Either<Failure, T> or thrown for AsyncValue.guard().
@freezed
class Failure with _$Failure {
  /// No internet / connection timeout / DNS failure
  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  /// 400 Bad Request — validation errors
  const factory Failure.validation({
    required String message,
    @Default([]) List<String> errors, // individual field errors from backend
  }) = ValidationFailure;

  /// 401 Unauthorized — session expired, token invalid
  const factory Failure.unauthorized({
    required String message,
  }) = UnauthorizedFailure;

  /// 403 Forbidden — not enough permission
  const factory Failure.forbidden({
    required String message,
  }) = ForbiddenFailure;

  /// 404 Not Found
  const factory Failure.notFound({
    required String message,
  }) = NotFoundFailure;

  /// 409 Conflict — booking conflict, duplicate, etc.
  const factory Failure.conflict({
    required String message,
  }) = ConflictFailure;

  /// 5xx Server errors — backend crashed or DB error
  const factory Failure.server({
    required int statusCode,
    required String message,
  }) = ServerFailure;

  /// Unexpected / unknown errors
  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}

// ── Extension: convert AppException → Failure ────────────────────────────────

extension AppExceptionToFailure on AppException {
  /// Converts any typed [AppException] to the correct [Failure] variant.
  ///
  /// Usage in repository:
  ///   on AppException catch (e) { return Left(e.toFailure()); }
  Failure toFailure() {
    if (this is UnauthorizedException) {
      return Failure.unauthorized(message: message);
    } else if (this is ForbiddenException) {
      return Failure.forbidden(message: message);
    } else if (this is NotFoundException) {
      return Failure.notFound(message: message);
    } else if (this is ConflictException) {
      return Failure.conflict(message: message);
    } else if (this is ValidationException) {
      return Failure.validation(
        message: message,
        errors: errors ?? [],
      );
    } else if (this is NetworkException) {
      return Failure.network(message: message);
    } else if (this is ServerException) {
      return Failure.server(
        statusCode: statusCode ?? 500,
        message: message,
      );
    }
    return Failure.unknown(message: message);
  }
}

// ── Extension: user-facing message ───────────────────────────────────────────

extension FailureMessage on Failure {
  /// Returns a user-friendly message for display in the UI.
  String get userMessage => when(
        network: (msg) => 'No internet connection. Please check your network.',
        validation: (msg, errors) =>
            errors.isNotEmpty ? errors.first : msg,
        unauthorized: (msg) => msg,
        forbidden: (msg) => msg,
        notFound: (msg) => msg,
        conflict: (msg) => msg,
        server: (code, msg) => 'Something went wrong. Please try again.',
        unknown: (msg) => 'Something went wrong. Please try again.',
      );

  /// True if this failure should log the user out and redirect to login.
  bool get requiresRelogin => maybeWhen(
        unauthorized: (_) => true,
        orElse: () => false,
      );

  /// True if this failure should show a retry button.
  bool get canRetry => maybeWhen(
        network: (_) => true,
        server: (_, __) => true,
        orElse: () => false,
      );
}
