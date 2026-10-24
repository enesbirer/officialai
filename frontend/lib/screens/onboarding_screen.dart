import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../providers/theme_provider.dart';
import '../providers/storage_service_provider.dart';
import '../widgets/primary_button.dart';

class _OnboardItem {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardItem(this.icon, this.title, this.description);
}

const List<_OnboardItem> _items = [
  _OnboardItem(
    Icons.description_outlined,
    'Akıllı Dilekçe Üretimi',
    '10+ kategoride profesyonel Türkçe dilekçe oluştur. İş, kira, trafik, vergi, sağlık ve daha fazlası tek tıkla hazır.',
  ),
  _OnboardItem(
    Icons.mail_outline_rounded,
    'E-posta & CV Oluşturucu',
    'Resmi, iş, akademik veya başvuru e-postalarını ve ATS uyumlu özgeçmişleri yapay zeka ile tasarla.',
  ),
  _OnboardItem(
    Icons.document_scanner_outlined,
    'OCR & Akıllı Sohbet',
    'Belgelerini tara, yapay zeka ile analiz ettir. Uzman desteğiyle her konuda sohbet et.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final storage = ref.read(storageServiceProvider);
    storage.saveData(AppConfig.onboardingShownKey, true);
    ref.read(onboardingShownProvider.notifier).state = true;
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_index < _items.length - 1) {
      _ctrl.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _buildBody(text, sub))
          : GlassBackground.iceLightGradient(child: _buildBody(text, sub)),
    );
  }

  Widget _buildBody(Color text, Color sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: text,
                    ),
                  ),
                  if (_index < _items.length - 1)
                    TextButton(
                      onPressed: _skip,
                      child: const Text('Atla'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          alignment: Alignment.center,
                          child: Icon(item.icon, size: 68, color: accent),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: sub,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _index == i ? accent : accent.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: _index == _items.length - 1 ? 'Başla' : 'İleri',
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}
