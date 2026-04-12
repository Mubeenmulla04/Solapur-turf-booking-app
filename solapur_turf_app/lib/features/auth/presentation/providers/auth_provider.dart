import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/auth_repository.dart';


part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

// ── Auth State ──────────────────────────────────────────────────────────────

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({required User user}) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error({required String message}) = _Error;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is _Authenticated;
  User? get user => mapOrNull(authenticated: (s) => s.user);
  String? get role => user?.role.value;
}

// ── Repository Provider ─────────────────────────────────────────────────────

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(
    AuthRemoteDataSourceImpl(dio),
    storage,
  );
}

// ── Auth Notifier ───────────────────────────────────────────────────────────

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final repo = ref.read(authRepositoryProvider);
    final hasSession = await repo.hasValidSession();
    if (hasSession) {
      // Restore role from secure storage
      final storage = ref.read(tokenStorageProvider);
      final role = await storage.getUserRole() ?? 'USER';
      final userId = await storage.getUserId() ?? '';
      final userName = await storage.getUserName() ?? 'Player';
      
      // Update FCM token in background
      ref.read(notificationServiceProvider).updateFcmToken();

      // We read cached meta — full user object
      return AuthState.authenticated(
        user: User(
          userId: userId,
          email: '',
          fullName: userName,
          role: UserRoleX.fromString(role),
        ),
      );
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    result.fold(
      (failure) => state =
          AsyncValue.data(AuthState.error(message: failure.userMessage)),
      (response) => state =
          AsyncValue.data(AuthState.authenticated(user: response.user)),
    );
  }

  Future<void> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String role = 'USER',
    // Owner-only fields
    String? businessName,
    String? contactNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? stateProvince, // renamed to avoid shadowing Riverpod 'state'
    String? pinCode,
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
    String? gstNumber,
    String? panNumber,
  }) async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).register(
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
          state: stateProvince,
          pinCode: pinCode,
          upiId: upiId,
          bankAccountNumber: bankAccountNumber,
          ifscCode: ifscCode,
          gstNumber: gstNumber,
          panNumber: panNumber,
        );

    result.fold(
      (failure) => state =
          AsyncValue.data(AuthState.error(message: failure.userMessage)),
      (response) {
        // Owner accounts get null token — pending admin approval
        // Still emit authenticated so UI can detect the owner role and show pending dialog
        state = AsyncValue.data(AuthState.authenticated(user: response.user));
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).clearSession();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }
}
