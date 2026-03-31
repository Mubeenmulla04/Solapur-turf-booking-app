import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/turf_model.dart';

abstract class TurfRemoteDataSource {
  Future<List<TurfListingModel>> getTurfs({
    String? city,
    String? sportType,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page,
    int limit,
  });

  Future<TurfListingModel> getTurfById(String turfId);

  Future<List<AvailabilitySlotModel>> getAvailableSlots({
    required String turfId,
    required String date,
  });
}

class TurfRemoteDataSourceImpl implements TurfRemoteDataSource {
  final Dio _dio;

  TurfRemoteDataSourceImpl(this._dio);

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

  /// Unwraps list data for `ApiResponse<List<T>>`
  List<T> _unwrapList<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    var body = response.data;
    if (body is String) { body = Map<String, dynamic>.from(body as Map); }
    final data = body['data'];
    if (data == null) {
      throw const ServerException('Server returned empty response data.');
    }
    
    // Sometimes wrapped dynamically under 'content' inside data objects in edge cases, check both.
    final list = (data is Map && data.containsKey('content')) ? data['content'] as List<dynamic> : data as List<dynamic>;
    
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TurfListingModel>> getTurfs({
    String? city,
    String? sportType,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (city != null) 'city': city,
        if (sportType != null) 'sportType': sportType,
        if (search != null) 'search': search,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null) 'sortBy': sortBy,
      };
      final response = await _dio.get(
        '/turfs',
        queryParameters: params,
        options: Options(extra: {'refresh': true}), // Force bypass of CacheInterceptor
      );
      return _unwrapList(response, TurfListingModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<TurfListingModel> getTurfById(String turfId) async {
    try {
      final response = await _dio.get('/turfs/$turfId');
      return _unwrap(response, TurfListingModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<List<AvailabilitySlotModel>> getAvailableSlots({
    required String turfId,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/slots/available',
        queryParameters: {'turfId': turfId, 'date': date},
      );
      return _unwrapList(response, AvailabilitySlotModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
