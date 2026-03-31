import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResponse>> register({
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

  Future<Either<Failure, String>> refreshToken(String refreshToken);

  Future<void> saveSession(AuthResponse response);
  Future<void> clearSession();
  Future<bool> hasValidSession();
  Future<User?> getCachedUser();
}
