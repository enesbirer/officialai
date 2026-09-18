import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../screens/splash_screen.dart';
import '../../../screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/petition/screens/petition_screen.dart';
import '../../features/email/screens/email_screen.dart';
import '../../features/cv/screens/cv_screen.dart';
import '../../features/scanner/screens/scanner_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../providers/storage_service_provider.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue>(authNotifierProvider, (_, __) => notifyListeners());
    ref.listen<bool>(onboardingShownProvider, (_, __) => notifyListeners());
  }
}

const List<String> _publicRoutes = [
  '/',
  '/login',
  '/register',
  '/onboarding',
];

bool _isProtected(String loc) => !_publicRoutes.contains(loc);

String? _redirectLogic(Ref ref, GoRouterState state) {
  final authState = ref.read(authNotifierProvider);
  final storage = ref.read(storageServiceProvider);

  final loading = authState.isLoading;
  final user = authState.valueOrNull;
  final loggedIn = user != null;

  final location = state.matchedLocation;

  // Splash hiçbir zaman redirect edilmesin, kendi karar versin
  if (location == '/') return null;

  // Onboarding kontrolü
  final onboardingShownRaw = storage.getData(AppConfig.onboardingShownKey);
  final onboardingShown = onboardingShownRaw == true || onboardingShownRaw == '1';
  if (!onboardingShown && location != '/onboarding') {
    return '/onboarding';
  }
  if (onboardingShown && location == '/onboarding') {
    return loggedIn ? '/dashboard' : '/login';
  }

  // Auth korumalı rotalar
  if (_isProtected(location) && !loggedIn && !loading) {
    return '/login';
  }

  // Giriş yapmış kullanıcı login/register'a gitmemeli
  if ((location == '/login' || location == '/register') && loggedIn) {
    return '/dashboard';
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = RouterRefreshNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: listenable,
    redirect: (context, state) => _redirectLogic(ref, state),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/petition',
        builder: (context, state) => const PetitionScreen(),
      ),
      GoRoute(
        path: '/email',
        builder: (context, state) => const EmailScreen(),
      ),
      GoRoute(
        path: '/cv',
        builder: (context, state) => const CVScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.matchedLocation}'),
      ),
    ),
  );
});
