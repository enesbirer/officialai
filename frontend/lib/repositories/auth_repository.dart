import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final Dio dio;
  final StorageService storage;
  AuthRepository(this.dio, this.storage);

  Future<UserModel> login(String email, String password) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email.trim(), 'password': password},
    );
    final payload = Map<String, dynamic>.from(r.data?['data'] ?? {});
    await _persistTokens(payload);
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (userJson != null) return UserModel.fromJson(userJson);
    throw Exception('User data missing');
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email.trim(),
        'password': password,
        if (firstName != null && firstName.isNotEmpty) 'firstName': firstName.trim(),
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName.trim(),
      },
    );
    final payload = Map<String, dynamic>.from(r.data?['data'] ?? {});
    return payload;
  }

  Future<UserModel> verifyEmail(String email, String code) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/auth/verify-email',
      data: {'email': email, 'code': code},
    );
    final payload = Map<String, dynamic>.from(r.data?['data'] ?? {});
    await _persistTokens(payload);
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (userJson != null) return UserModel.fromJson(userJson);
    throw Exception('User data missing');
  }

  Future<void> logout() async {
    try {
      await dio.post<Map<String, dynamic>>('/auth/logout');
    } catch (_) {}
    await storage.delete(AppConfig.tokenKey);
    await storage.delete(AppConfig.refreshTokenKey);
    await storage.delete(AppConfig.userKey);
  }

  Future<UserModel?> me() async {
    try {
      final r = await dio.get<Map<String, dynamic>>('/users/profile');
      final payload = r.data?['data'] as Map<String, dynamic>?;
      if (payload != null) {
        await storage.writeJson(AppConfig.userKey, payload);
        return UserModel.fromJson(payload);
      }
    } catch (_) {}
    final cached = await storage.readJson(AppConfig.userKey);
    if (cached != null) return UserModel.fromJson(cached);
    return null;
  }

  Future<void> _persistTokens(Map<String, dynamic> payload) async {
    final access = payload['accessToken'] as String?;
    final refresh = payload['refreshToken'] as String?;
    final user = payload['user'] as Map<String, dynamic>?;
    if (access != null) await storage.write(AppConfig.tokenKey, access);
    if (refresh != null) await storage.write(AppConfig.refreshTokenKey, refresh);
    if (user != null) await storage.writeJson(AppConfig.userKey, user);
  }

  Future<bool> hasToken() async {
    final t = await storage.read(AppConfig.tokenKey);
    return t != null && t.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await storage.delete(AppConfig.tokenKey);
    await storage.delete(AppConfig.refreshTokenKey);
    await storage.delete(AppConfig.userKey);
  }
}
