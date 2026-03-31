import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(identifier: email, password: password);
      final domain = model.toDomain();
      await saveSession(domain);
      return Right(domain);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
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
      final model = await _remote.register(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
        role: role,
        businessName: businessName,
        contactNumber: contactNumber,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pinCode: pinCode,
        upiId: upiId,
        bankAccountNumber: bankAccountNumber,
        ifscCode: ifscCode,
        gstNumber: gstNumber,
        panNumber: panNumber,
      );
      final domain = model.toDomain();
      // Skip saving session for owners — they must wait for admin approval
      // Their token is null until approved
      if (role != 'OWNER' && (domain.accessToken?.isNotEmpty ?? false)) {
        await saveSession(domain);
      }
      return Right(domain);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    try {
      final token = await _remote.refreshToken(refreshToken);
      return Right(token);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<void> saveSession(AuthResponse response) async {
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _storage.saveUserMeta(
      userId: response.user.userId,
      role: response.user.role.value,
      name: response.user.fullName,
    );
  }

  @override
  Future<void> clearSession() => _storage.clearAll();

  @override
  Future<bool> hasValidSession() => _storage.hasValidToken();

  @override
  Future<User?> getCachedUser() async => null; // Hydrated from token payload
}
