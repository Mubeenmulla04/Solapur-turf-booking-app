import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

part 'booking_provider.freezed.dart';
part 'booking_provider.g.dart';

// ── Repository ────────────────────────────────────────────────────────────────

@riverpod
BookingRepository bookingRepository(Ref ref) =>
    BookingRepositoryImpl(
      BookingRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );


// ── Create Booking State ──────────────────────────────────────────────────────

@freezed
class BookingFlowState with _$BookingFlowState {
  const factory BookingFlowState.idle() = _Idle;
  const factory BookingFlowState.creating() = _Creating;
  const factory BookingFlowState.awaitingPayment(
      CreateBookingResult result) = _AwaitingPayment;
  const factory BookingFlowState.verifying() = _Verifying;
  const factory BookingFlowState.success(Booking booking) = _Success;
  const factory BookingFlowState.error(String message) = _FlowError;
}

@riverpod
class BookingNotifier extends _$BookingNotifier {
  @override
  BookingFlowState build() => const BookingFlowState.idle();

  Future<void> createBooking({
    required String turfId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String paymentMethod,
  }) async {
    state = const BookingFlowState.creating();
    final result = await ref.read(bookingRepositoryProvider).createBooking(
          turfId: turfId,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
          paymentMethod: paymentMethod,
        );
    result.fold(
      (f) => state = BookingFlowState.error(f.userMessage),
      (data) => state = BookingFlowState.awaitingPayment(data),
    );
  }

  Future<void> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    state = const BookingFlowState.verifying();
    // Retry up to 3 times
    for (var i = 0; i < 3; i++) {
      final result = await ref.read(bookingRepositoryProvider).verifyPayment(
            bookingId: bookingId,
            paymentId: paymentId,
            signature: signature,
            orderId: orderId,
          );
      final stop = result.fold(
        (f) {
          if (i == 2) state = BookingFlowState.error(f.userMessage);
          return i == 2; // stop on last attempt
        },
        (_) {
          // If verification succeeded, fetch the booking details again to show success
          return false; // will continue to the success part below
        },
      );

      if (result.isRight()) {
        final bookingResult = await ref.read(bookingRepositoryProvider).getBookingById(bookingId);
        bookingResult.fold(
          (f) => state = BookingFlowState.error(f.userMessage),
          (booking) => state = BookingFlowState.success(booking),
        );
        break;
      }
      if (stop) break;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> reportPaymentFailure({
    required String orderId,
    required String paymentId,
    required String errorCode,
    required String errorMessage,
  }) async {
    await ref.read(bookingRepositoryProvider).reportPaymentFailure(
          orderId: orderId,
          paymentId: paymentId,
          errorCode: errorCode,
          errorMessage: errorMessage,
        );
    state = BookingFlowState.error(errorMessage);
  }

  Future<void> cancelBooking(String bookingId) async {
    await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
    state = const BookingFlowState.idle();
  }

  void reset() => state = const BookingFlowState.idle();
}

// ── My Bookings ───────────────────────────────────────────────────────────────

@riverpod
Future<List<Booking>> myBookings(Ref ref) async {
  final result =
      await ref.watch(bookingRepositoryProvider).getMyBookings();
  return result.fold((f) => throw f, (data) => data);
}
