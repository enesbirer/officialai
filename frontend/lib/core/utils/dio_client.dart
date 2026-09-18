import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../../providers/storage_service_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBase,
    connectTimeout: Duration(seconds: AppConfig.aiRequestTimeoutSeconds),
    receiveTimeout: Duration(seconds: AppConfig.aiRequestTimeoutSeconds + 30),
    sendTimeout: const Duration(seconds: 60),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(AppConfig.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            final refreshToken = await storage.read(AppConfig.refreshTokenKey);
            if (refreshToken != null) {
              final newToken = await _refresh(dio, refreshToken);
              if (newToken != null) {
                await storage.write(AppConfig.tokenKey, newToken['access']!);
                if (newToken['refresh'] != null) {
                  await storage.write(AppConfig.refreshTokenKey, newToken['refresh']!);
                }
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer ${newToken['access']}';
                try {
                  final retry = await dio.fetch<void>(opts);
                  return handler.resolve(retry);
                } catch (_) {}
              }
            }
          } catch (_) {}
          try {
            await storage.delete(AppConfig.tokenKey);
            await storage.delete(AppConfig.refreshTokenKey);
          } catch (_) {}
        }
        return handler.next(e);
      },
    ),
  );

  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: false,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  ));

  return dio;
});

Future<Map<String, String>?> _refresh(Dio dio, String refreshToken) async {
  try {
    final resp = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = resp.data?['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return {
      'access': data['accessToken'] as String? ?? '',
      'refresh': data['refreshToken'] as String? ?? refreshToken,
    };
  } catch (e) {
    return null;
  }
}

Future<bool> isConnected() async {
  try {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
    await dio.head('https://www.google.com');
    return true;
  } catch (_) {
    return false;
  }
}
