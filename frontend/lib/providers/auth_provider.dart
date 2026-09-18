import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'storage_service_provider.dart';
import '../core/utils/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio, storage);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final hasToken = await _repo.hasToken();
      if (!hasToken) return null;
      return _repo.me();
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.login(email, password));
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final prev = state;
    state = const AsyncValue.loading();
    try {
      final result = await _repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.verifyEmail(email, code));
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    state = const AsyncValue.data(null);
  }

  Future<void> clearAuth() async {
    try {
      await _repo.clearTokens();
    } catch (_) {}
    state = const AsyncValue.data(null);
  }

  bool get isAuthenticated => state.value != null;
}
