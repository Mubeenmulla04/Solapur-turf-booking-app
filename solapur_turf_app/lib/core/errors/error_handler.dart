import 'package:flutter/material.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Centralized UI error handler.
///
/// Usage in any widget:
///   ErrorHandler.handle(context, failure, ref: ref);
///
/// Usage in ref.listen:
///   ref.listen(someProvider, (_, next) {
///     next.whenOrNull(error: (e, _) => ErrorHandler.handleException(context, e));
///   });
class ErrorHandler {
  ErrorHandler._();

  // ── Handle Failure (from clean arch domain layer) ─────────────────────────

  static void handle(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    VoidCallback? onLogin,
  }) {
    failure.when(
      // 401 → must log in again
      unauthorized: (message) {
        _showDialog(
          context,
          title: 'Session Expired',
          message: message,
          icon: Icons.lock_outline,
          iconColor: Colors.orange,
          action: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLogin?.call();
            },
            child: const Text('Login Again'),
          ),
        );
      },

      // 403 → permission denied
      forbidden: (message) {
        _showSnackBar(
          context,
          message: message,
          icon: Icons.block,
          color: Colors.deepOrange,
        );
      },

      // 404 → resource gone
      notFound: (message) {
        _showSnackBar(
          context,
          message: message,
          icon: Icons.search_off,
          color: Colors.grey.shade700,
        );
      },

      // 409 → conflict (booking taken, duplicate, etc.)
      conflict: (message) {
        _showSnackBar(
          context,
          message: message,
          icon: Icons.warning_amber_outlined,
          color: Colors.amber.shade800,
        );
      },

      // 400 → validation errors
      validation: (message, errors) {
        if (errors.isNotEmpty) {
          _showDialog(
            context,
            title: 'Please fix the following',
            message: errors.join('\n• '),
            icon: Icons.edit_note,
            iconColor: Colors.red,
          );
        } else {
          _showSnackBar(
            context,
            message: message,
            icon: Icons.error_outline,
            color: Colors.red,
          );
        }
      },

      // No internet
      network: (message) {
        _showSnackBar(
          context,
          message: 'No internet connection',
          icon: Icons.wifi_off,
          color: Colors.blueGrey,
          action: onRetry != null
              ? SnackBarAction(label: 'Retry', onPressed: onRetry)
              : null,
        );
      },

      // 500
      server: (statusCode, message) {
        _showSnackBar(
          context,
          message: 'Something went wrong. Please try again.',
          icon: Icons.cloud_off,
          color: Colors.red.shade700,
          action: onRetry != null
              ? SnackBarAction(label: 'Retry', onPressed: onRetry)
              : null,
        );
      },

      // Unknown
      unknown: (message) {
        _showSnackBar(
          context,
          message: 'An unexpected error occurred.',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      },
    );
  }

  // ── Handle raw AppException (from data sources / notifiers) ──────────────

  static void handleException(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
    VoidCallback? onLogin,
  }) {
    if (error is AppException) {
      handle(context, error.toFailure(), onRetry: onRetry, onLogin: onLogin);
    } else {
      _showSnackBar(
        context,
        message: 'An unexpected error occurred.',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: action,
      ),
    );
  }

  static void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    Widget? action,
  }) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 36),
        title: Text(title),
        content: Text(message),
        actions: [
          if (action != null) action,
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
