import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

/// API service for forgot password operations
class ForgotPasswordApiService {
  final Dio _dio;

  ForgotPasswordApiService(this._dio);

  /// Request OTP for password reset
  /// Sends OTP to the user's registered email
  Future<Map<String, dynamic>> requestForgotPasswordOtp({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/request',
        data: {'email': email},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found with this email');
      } else if (e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to send OTP. Please try again.');
    } catch (e) {
      throw Exception('Failed to send OTP. Please check your connection.');
    }
  }

  /// Reset password using OTP
  /// Verifies OTP and sets new password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/reset',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      } else if (e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to reset password. Please try again.');
    } catch (e) {
      throw Exception('Failed to reset password. Please check your connection.');
    }
  }
}
