import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<CreateBookingResponseModel> createBooking({
    required String turfId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String paymentMethod,
  });

  Future<List<BookingModel>> getMyBookings({int page, int limit});
  Future<BookingModel> getBookingById(String bookingId);
  Future<void> cancelBooking(String bookingId);
  Future<void> reportPaymentFailure({
    required String orderId,
    required String paymentId,
    required String errorCode,
    required String errorMessage,
  });
  Future<void> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String signature,
    required String orderId,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _dio;

  BookingRemoteDataSourceImpl(this._dio);

  /// Unwraps the standard ApiResponse<T> envelope from the backend.
  T _unwrap<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    var body = response.data;
    if (body is String) { body = Map<String, dynamic>.from(body as Map); }
    final data = body['data'];
    if (data == null) {
      throw const ServerException('Server returned empty response data.');
    }
    return fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CreateBookingResponseModel> createBooking({
    required String turfId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post('/bookings', data: {
        'turfId': turfId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
        'paymentMethod': paymentMethod,
      });
      return _unwrap(response, CreateBookingResponseModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<void> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    try {
      await _dio.post('/payments/verify', data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      });
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<void> reportPaymentFailure({
    required String orderId,
    required String paymentId,
    required String errorCode,
    required String errorMessage,
  }) async {
    try {
      await _dio.post('/payments/failure', data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'errorCode': errorCode,
        'errorDescription': errorMessage,
      });
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<List<BookingModel>> getMyBookings({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get('/bookings/my-bookings',
          queryParameters: {'page': page, 'limit': limit});
      
      final body = response.data as Map<String, dynamic>;
      final data = body['data']; // The PageResponse instance
      if (data == null) throw const ServerException('Empty page data');

      final list = data['content'] as List<dynamic>; // Actual list
      return list
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final response = await _dio.get('/bookings/$bookingId');
      return _unwrap(response, BookingModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _dio.post('/bookings/$bookingId/cancel');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
