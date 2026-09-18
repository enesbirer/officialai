import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../services/storage_service.dart';
import 'storage_service_provider.dart';

// =============== THEME MODE PROVIDER ===============

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final raw = _storage.getData(AppConfig.themeKey) as String?;
    switch (raw) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
        break;
    }
    // Eğer storage'da kayıtlı yoksa varsayılan dark (AppConfig.defaultTheme='dark')
    if (raw == null || raw.isEmpty) {
      switch (AppConfig.defaultTheme) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    switch (mode) {
      case ThemeMode.light:
        _storage.saveData(AppConfig.themeKey, 'light');
        break;
      case ThemeMode.dark:
        _storage.saveData(AppConfig.themeKey, 'dark');
        break;
      case ThemeMode.system:
        _storage.saveData(AppConfig.themeKey, 'system');
        break;
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(storageServiceProvider));
});

// =============== LOCALE PROVIDER ===============

class LocaleNotifier extends StateNotifier<Locale> {
  final StorageService _storage;

  LocaleNotifier(this._storage) : super(const Locale('tr')) {
    _load();
  }

  Future<void> _load() async {
    final raw = _storage.getData(AppConfig.languageKey) as String?;
    if (raw == 'en') {
      state = const Locale('en');
    } else if (raw == 'tr') {
      state = const Locale('tr');
    } else {
      final defaultLang = AppConfig.defaultLanguage;
      state = Locale(defaultLang);
      _storage.saveData(AppConfig.languageKey, defaultLang);
    }
  }

  Future<void> setLocale(Object langOrLocale) async {
    final lang = langOrLocale is Locale
        ? langOrLocale.languageCode
        : langOrLocale.toString();
    if (lang != 'tr' && lang != 'en') return;
    state = Locale(lang);
    _storage.saveData(AppConfig.languageKey, lang);
  }

  String get languageCode => state.languageCode;
  bool get isTurkish => state.languageCode == 'tr';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.watch(storageServiceProvider));
});

// =============== ONBOARDING STATE ===============

final onboardingShownProvider = StateProvider<bool>((ref) => false);
