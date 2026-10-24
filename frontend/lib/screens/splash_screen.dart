import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../providers/auth_provider.dart';
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
    // Auth provider yüklenmesini bekleme - backend cold start sorunu nedeniyle
    // await Future.doWhile(() async {
    //   final s = ref.read(authNotifierProvider);
    //   if (s.isLoading) {
    //     await Future.delayed(const Duration(milliseconds: 200));
    //     return true;
    //   }
    //   return false;
    // });
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
      backgroundColor: Colors.transparent,
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _buildBody())
          : GlassBackground.iceLightGradient(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Destekli Resmi Belge Asistanı',
                    style: TextStyle(fontSize: 16, color: subColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            FadeTransition(
              opacity: _fade,
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'v${AppConfig.appVersion}',
                style: TextStyle(fontSize: 13, color: subColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
