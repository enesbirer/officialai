import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  Box? _hiveBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      _hiveBox = await Hive.openBox(AppConstants.hiveBoxName);
      _initialized = true;
    } catch (e) {
      print('StorageService init hatası: $e');
      // Hive başarısız olursa secure storage kullanmaya devam et
      _initialized = true;
    }
  }

  // ========== Secure String Storage (access tokens, refresh tokens vb.) ==========

  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _secureStorage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  // ========== Secure Storage - Legacy Token Helpers ==========

  Future<void> saveToken(String token) async {
    await write(AppConstants.secureStorageKey, token);
  }

  Future<String?> getToken() async {
    return read(AppConstants.secureStorageKey);
  }

  Future<void> deleteToken() async {
    await delete(AppConstants.secureStorageKey);
  }

  // ========== Hive Storage - Key / Value (preferences, küçük objeler) ==========

  void saveData(String key, dynamic value) {
    if (_hiveBox != null) {
      _hiveBox!.put(key, value);
    }
  }

  dynamic getData(String key) {
    if (_hiveBox != null) {
      return _hiveBox!.get(key);
    }
    return null;
  }

  void deleteData(String key) {
    if (_hiveBox != null) {
      _hiveBox!.delete(key);
    }
  }

  Future<bool> containsKey(String key) async {
    if (_hiveBox != null) {
      return _hiveBox!.containsKey(key);
    }
    return false;
  }

  // ========== JSON Storage (user objesi, küçük kompleks nesneler) ==========

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    if (_hiveBox != null) {
      final encoded = jsonEncode(value);
      _hiveBox!.put(key, encoded);
    }
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    if (_hiveBox != null) {
      final raw = _hiveBox!.get(key) as String?;
      if (raw == null || raw.isEmpty) return null;
      try {
        return Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    if (_hiveBox != null) {
      await _hiveBox!.clear();
    }
  }
}
