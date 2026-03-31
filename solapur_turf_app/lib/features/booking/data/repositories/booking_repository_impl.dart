import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;

  BookingRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CreateBookingResult>> createBooking({
    required String turfId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String paymentMethod,
  }) async {
    try {
      final model = await _remote.createBooking(
        turfId: turfId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        paymentMethod: paymentMethod,
      );
      return Right(model.toDomain());
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    try {
      await _remote.verifyPayment(
        bookingId: bookingId,
        paymentId: paymentId,
        signature: signature,
        orderId: orderId,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> reportPaymentFailure({
    required String orderId,
    required String paymentId,
    required String errorCode,
    required String errorMessage,
  }) async {
    try {
      await _remote.reportPaymentFailure(
        orderId: orderId,
        paymentId: paymentId,
        errorCode: errorCode,
        errorMessage: errorMessage,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final models = await _remote.getMyBookings(page: page, limit: limit);
      return Right(models.map((m) => m.toDomain()).toList());
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    try {
      final model = await _remote.getBookingById(bookingId);
      return Right(model.toDomain());
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await _remote.cancelBooking(bookingId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(AppException e) {
    if (e.statusCode == 409) return Failure.validation(message: e.message);
    if (e.statusCode == null) return Failure.network(message: e.message);
    return Failure.server(statusCode: e.statusCode!, message: e.message);
  }
}
