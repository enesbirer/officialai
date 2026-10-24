import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/primary_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    final page = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.clamp),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1C1C1E) : Colors.white).withValues(alpha: 0.82),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Ayarlar',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Uygulama künyesi
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OfficialAI',
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sürüm 1.0.0 (Build 100)',
                          style: TextStyle(color: sub, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Amazon Appstore Edition',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _h(isDark, 'GENEL AYARLAR'),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _item(
                    isDark,
                    Icons.dark_mode_outlined,
                    'Uygulama Teması',
                    theme == ThemeMode.system
                        ? 'Sistem ile aynı'
                        : theme == ThemeMode.dark
                            ? 'Karanlık Mod'
                            : 'Aydınlık Mod',
                    onTap: () {
                      final next = theme == ThemeMode.light
                          ? ThemeMode.dark
                          : theme == ThemeMode.dark
                              ? ThemeMode.system
                              : ThemeMode.light;
                      ref.read(themeModeProvider.notifier).setTheme(next);
                    },
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.translate_outlined,
                    'Uygulama Dili',
                    locale.languageCode == 'tr' ? 'Türkçe' : 'English',
                    onTap: () {
                      final next = locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
                      ref.read(localeProvider.notifier).setLocale(next);
                    },
                    trailing: Switch(
                      value: locale.languageCode == 'tr',
                      onChanged: (v) {
                        final next = v ? const Locale('tr') : const Locale('en');
                        ref.read(localeProvider.notifier).setLocale(next);
                      },
                    ),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.notifications_outlined,
                    'Bildirimler',
                    'Açık',
                    trailing: Switch(value: true, onChanged: (_) {}),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.wifi_protected_setup_outlined,
                    'Sadece Wi-Fi ile Yükle',
                    'Kapalı',
                    trailing: Switch(value: false, onChanged: (_) {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _h(isDark, 'GİZLİLİK & GÜVENLİK'),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _item(
                    isDark,
                    Icons.privacy_tip_outlined,
                    'Gizlilik Politikası',
                    'Son güncelleme: Ocak 2025',
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.verified_user_outlined,
                    'Kullanım Şartları',
                    'v1.0',
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.data_object_outlined,
                    'Verilerim',
                    'Yerel + Sunucu',
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.delete_sweep_outlined,
                    'Önbelleği Temizle',
                    '~4.2 MB',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Önbellek temizlendi'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _h(isDark, 'OFFICIALAI HAKKINDA'),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _item(
                    isDark,
                    Icons.info_outline,
                    'Hakkımızda',
                    'AI destekli resmi evrak asistanı',
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.star_rate_outlined,
                    'Uygulamayı Puanla',
                    'Amazon Appstore',
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.share_outlined,
                    'Arkadaşlarınla Paylaş',
                    'Ücretsiz OfficialAI\'ı tanıt',
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _item(
                    isDark,
                    Icons.contact_support_outlined,
                    'İletişim & Destek',
                    'support@officialai.app',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pro avantajları
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.auto_awesome, color: accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OfficialAI Pro',
                              style: TextStyle(
                                color: text,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Amazon Appstore\'da tamamen ücretsiz!',
                              style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '• Sınırsız Dilekçe, E-posta ve CV oluşturma\n'
                    '• Sınırsız OCR belge tarama & analiz\n'
                    '• Sınırsız AI sohbet\n'
                    '• Reklamsız kullanım',
                    style: TextStyle(
                      color: sub,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Ücretsiz Kullan (Premium)',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Bu sürüm zaten ücretsiz ve premiumdur.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            GlassContainer(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              border: Border.all(color: accent.withValues(alpha: 0.25)),
              child: Text(
                'OfficialAI © 2025 — Tüm hakları saklıdır. '
                'Uygulama Amazon Appstore, Google Play ve diğer platformlarda ücretsiz olarak yayınlanmaktadır. '
                'Ücretsiz katman: Google Gemini (15 RPM), Google ML Kit Text Recognition, Local Storage.',
                style: TextStyle(
                  color: sub,
                  fontSize: 12,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    return isDark
        ? GlassBackground.iceDarkGradient(child: page)
        : GlassBackground.iceLightGradient(child: page);
  }

  Widget _h(bool isDark, String t) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        t,
        style: TextStyle(
          color: sub,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _item(
    bool isDark,
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: accent, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w400,
          fontSize: 17,
          letterSpacing: -0.2,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: sub, fontSize: 13),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, size: 22, color: sub),
    );
  }
}
