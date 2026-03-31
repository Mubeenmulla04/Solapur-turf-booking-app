import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide constants — updated to load from .env file
class AppConstants {
  AppConstants._();

  // ── Environment ────────────────────────────────────────────────────────────
  // Loads from .env, providing simple config switching for production/local.
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080/api');

  // ── Network ────────────────────────────────────────────────────────────────
  static Duration get connectTimeout => Duration(milliseconds: int.parse(dotenv.get('CONNECT_TIMEOUT', fallback: '30000')));
  static Duration get receiveTimeout => Duration(milliseconds: int.parse(dotenv.get('RECEIVE_TIMEOUT', fallback: '30000')));
  static const int maxRetryAttempts = 3;

  // ── API Endpoints ──────────────────────────────────────────────────────────
  static const String endpointLogin          = '/auth/login';
  static const String endpointRegister       = '/auth/register';
  static const String endpointMyBookings     = '/bookings/my-bookings';
  static const String endpointTurfs          = '/turfs';
  static const String endpointHealth         = '/health';

  // ── Razorpay ───────────────────────────────────────────────────────────────
  static String get razorpayKeyId => dotenv.get('RAZORPAY_KEY_ID', fallback: 'rzp_test_1DP5mmOlF5G5ag');
  static const String razorpayAppName = 'Solapur Turf Booking';
  static const String razorpayCurrency = 'INR';

  // ── Logging ────────────────────────────────────────────────────────────────
  static bool get enableLogging => dotenv.get('ENABLE_LOGGING', fallback: 'true').toLowerCase() == 'true';
  static bool get compactLogging => dotenv.get('COMPACT_LOGGING', fallback: 'true').toLowerCase() == 'true';

  // ── Business Logic ─────────────────────────────────────────────────────────
  static const double platformCommissionRate = 0.15;
  static const double cashBookingAdvanceAmount = 50.0;
  static const double tournamentCommissionPerTeam = 50.0;
  static const int maxTeamMembers = 25;
  static const int teamCodeLength = 8;

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;

  // ── Booking Polling ────────────────────────────────────────────────────────
  static const int bookingPollMaxAttempts = 30;
  static const Duration bookingPollInterval = Duration(seconds: 2);
  static const int paymentVerifyMaxRetries = 3;

  // ── Storage Keys ───────────────────────────────────────────────────────────
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
}
