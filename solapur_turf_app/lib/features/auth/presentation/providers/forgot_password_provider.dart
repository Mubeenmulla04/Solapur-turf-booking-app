import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../data/services/forgot_password_api_service.dart';

part 'forgot_password_provider.g.dart';

// ── Forgot Password Notifier ────────────────────────────────────────────────

@riverpod
class ForgotPassword extends _$ForgotPassword {
  @override
  Future<void> build() async {
    // Initial state - nothing to load
  }

  /// Request OTP for password reset
  Future<void> requestOtp({required String email}) async {
    state = const AsyncValue.loading();
    
    final apiService = ForgotPasswordApiService(ref.read(apiClientProvider));
    
    final result = await apiService.requestForgotPasswordOtp(email: email);
    
    if (result['success'] == true || result['message'] != null) {
      state = const AsyncValue.data(null);
    } else {
      throw Exception(result['message'] ?? 'Failed to send OTP');
    }
  }

  /// Reset password with OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    
    final apiService = ForgotPasswordApiService(ref.read(apiClientProvider));
    
    final result = await apiService.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    
    if (result['success'] == true || result['message'] != null) {
      state = const AsyncValue.data(null);
    } else {
      throw Exception(result['message'] ?? 'Failed to reset password');
    }
  }
}
