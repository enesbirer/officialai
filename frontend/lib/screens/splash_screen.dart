import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/storage_service_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
    );
    _anim.forward();
    _startDecision();
  }

  Future<void> _startDecision() async {
    // Auth provider yüklenmesini bekle (async loading state tamamlanana kadar)
    await Future.doWhile(() async {
      final s = ref.read(authNotifierProvider);
      if (s.isLoading) {
        await Future.delayed(const Duration(milliseconds: 200));
        return true;
      }
      return false;
    });
    // Minimum 2s göster
    await Future.delayed(const Duration(milliseconds: 1600));
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final storage = ref.read(storageServiceProvider);
    final onboardRaw = storage.getData(AppConfig.onboardingShownKey);
    final onboardingShown = onboardRaw == true || onboardRaw == '1';

    final authState = ref.read(authNotifierProvider);
    final user = authState.valueOrNull;
    final loggedIn = user != null;

    String destination;
    if (!onboardingShown) {
      destination = '/onboarding';
    } else if (loggedIn) {
      destination = '/dashboard';
    } else {
      destination = '/login';
    }
    if (mounted) context.go(destination);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _buildBody())
          : GlassBackground.iceLightGradient(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: GlassContainer(
                  borderRadius: 36,
                  padding: const EdgeInsets.all(28),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.icePrimary, AppColors.iceSecondary],
                      ),
                    ),
                    child: const Icon(
                      Icons.document_scanner,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI Destekli Resmi Belge Asistanı',
                    style: TextStyle(fontSize: 16, color: subColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 72),
            FadeTransition(
              opacity: _fade,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.icePrimary),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'v${AppConfig.appVersion}',
                style: TextStyle(fontSize: 12, color: subColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
