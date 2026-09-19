class AppConfig {
  static const String appName = 'OfficialAI';
  static const String appVersion = '1.0.0';

  static const String defaultLanguage = 'tr';
  static const String defaultTheme = 'dark';

  // Backend base URL - mobil emülatör için 10.0.2.2 (Android), cihaz için bilgisayar LAN IP
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  // Varsayılan: masaüstü/web localhost; Android emülatör için --dart-define=BASE_URL=http://10.0.2.2:3000
  // Production için bu URL'i gerçek backend URL'i ile değiştirin
  // Render deploy URL'i ile güncellendi
  static const String _defaultBaseUrl = 'https://YOUR_RENDER_URL.onrender.com';

  static const String apiVersion = 'v1';

  static String get apiBase => '$baseUrl/api/$apiVersion';

  // Storage keys
  static const String tokenKey = 'officialai_access_token';
  static const String refreshTokenKey = 'officialai_refresh_token';
  static const String userKey = 'officialai_user';
  static const String languageKey = 'officialai_language';
  static const String themeKey = 'officialai_theme';
  static const String onboardingShownKey = 'officialai_onboarding_shown';

  // AI timeout
  static const int aiRequestTimeoutSeconds = 60;

  // RegEx
  static final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final tcKimlikRegex = RegExp(r'^[1-9]\d{10}$');
}
