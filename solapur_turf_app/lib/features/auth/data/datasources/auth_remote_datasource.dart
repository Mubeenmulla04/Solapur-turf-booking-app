import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String identifier, // email OR phone — must match backend LoginRequest.identifier
    required String password,
  });

  Future<AuthResponseModel> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String role,
    String? businessName,
    String? contactNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
    String? gstNumber,
    String? panNumber,
  });

  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  /// Unwraps the standard ApiResponse<T> envelope from the backend.
  /// Backend now returns: { success, message, data: {...}, timestamp }
  /// We extract the 'data' field and pass it to fromJson.
  T _unwrap<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = response.data as Map<String, dynamic>;
    final data = body['data'];
    if (data == null) {
      throw const ServerException('Server returned empty response data.');
    }
    return fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.endpointLogin,
        data: {
          'identifier': identifier, // ← MUST match LoginRequest.identifier in backend
          'password': password,
        },
      );
      return _unwrap(response, AuthResponseModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String role = 'USER',
    String? businessName,
    String? contactNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
    String? gstNumber,
    String? panNumber,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'phone': phone,
        'password': password,
        'fullName': fullName,
        'role': role,
      };
      // Append owner fields only when provided
      if (businessName      != null) body['businessName']      = businessName;
      if (contactNumber     != null) body['contactNumber']     = contactNumber;
      if (addressLine1      != null) body['addressLine1']      = addressLine1;
      if (addressLine2      != null) body['addressLine2']      = addressLine2;
      if (city              != null) body['city']              = city;
      if (state             != null) body['state']             = state;
      if (pinCode           != null) body['pinCode']           = pinCode;
      if (upiId             != null) body['upiId']             = upiId;
      if (bankAccountNumber != null) body['bankAccountNumber'] = bankAccountNumber;
      if (ifscCode          != null) body['ifscCode']          = ifscCode;
      if (gstNumber         != null) body['gstNumber']         = gstNumber;
      if (panNumber         != null) body['panNumber']         = panNumber;

      final response = await _dio.post(AppConstants.endpointRegister, data: body);
      return _unwrap(response, AuthResponseModel.fromJson);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      return data?['accessToken'] as String? ??
          (throw const ServerException('No access token in refresh response'));
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
