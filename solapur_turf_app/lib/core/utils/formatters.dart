import 'package:intl/intl.dart';

/// Utility formatters for currency, dates, and display strings.
class AppFormatters {
  AppFormatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('dd MMM yyyy', 'en_IN');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a', 'en_IN');
  static final _timeFormat = DateFormat('hh:mm a', 'en_IN');
  static final _shortDateFormat = DateFormat('EEE, dd MMM', 'en_IN');

  /// ₹1,000 → "₹1,000"
  static String formatCurrency(num amount) =>
      _currencyFormat.format(amount);

  /// 2024-03-01 → "01 Mar 2024"
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// 2024-03-01T14:30 → "01 Mar 2024, 02:30 PM"
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// "14:00:00" → "02:00 PM"
  static String formatTimeString(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final dt = DateTime(2000, 1, 1, hour, minute);
    return _timeFormat.format(dt);
  }

  /// "14:00:00" → 840 (total minutes from midnight)
  static int parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return (h * 60) + m;
  }

  /// "2024-03-01" → "Mon, 01 Mar"
  static String formatShortDate(DateTime date) =>
      _shortDateFormat.format(date);

  /// Duration in hours → "2h 30m" or "1h"
  static String formatDuration(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Capitalizes first letter of each word
  static String toTitleCase(String value) => value
      .toLowerCase()
      .split('_')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
      .join(' ');
}
