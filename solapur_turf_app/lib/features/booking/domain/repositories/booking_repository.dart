import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, CreateBookingResult>> createBooking({
    required String turfId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String paymentMethod,
  });

  Future<Either<Failure, void>> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String signature,
    required String orderId,
  });

  Future<Either<Failure, List<Booking>>> getMyBookings({int page, int limit});
  Future<Either<Failure, Booking>> getBookingById(String bookingId);
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, void>> reportPaymentFailure({
    required String orderId,
    required String paymentId,
    required String errorCode,
    required String errorMessage,
  });
}
