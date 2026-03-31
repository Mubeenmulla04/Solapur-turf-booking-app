import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class to prevent duplicate API calls (Double-clicks / Spamming).
///
/// Usage:
///   final _debouncer = Debouncer(milliseconds: 500);
///
///   onPressed: () {
///       _debouncer.run(() {
///           ref.read(bookingProvider.notifier).createBooking(...);
///       });
///   }
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
