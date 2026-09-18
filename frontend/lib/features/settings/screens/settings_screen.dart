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

    final page = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ayarlar',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.icePrimary, AppColors.iceAccent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OfficialAI',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Sürüm 1.0.0 (Build 100)',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Amazon Appstore Edition',
                          style: TextStyle(
                            color: AppColors.icePrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _h(isDark, '⚙️ Genel Ayarlar'),
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
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.translate_outlined,
                    'Uygulama Dili',
                    locale.languageCode == 'tr' ? 'Türkçe 🇹🇷' : 'English 🇬🇧',
                    onTap: () {
                      final next = locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
                      ref.read(localeProvider.notifier).setLocale(next);
                    },
                    trailing: Switch(
                      value: locale.languageCode == 'tr',
                      activeColor: AppColors.icePrimary,
                      onChanged: (v) {
                        final next = v ? const Locale('tr') : const Locale('en');
                        ref.read(localeProvider.notifier).setLocale(next);
                      },
                    ),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.notifications_active_outlined,
                    'Bildirimler',
                    'Açık',
                    trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.icePrimary),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.wifi_protected_setup_outlined,
                    'Sadece Wi-Fi ile Yükle',
                    'Kapalı',
                    trailing: Switch(value: false, onChanged: (_) {}, activeColor: AppColors.icePrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _h(isDark, '🔒 Gizlilik & Güvenlik'),
                  _item(
                    isDark,
                    Icons.privacy_tip_outlined,
                    'Gizlilik Politikası',
                    'Son güncelleme: Ocak 2025',
                    trailing: Icon(Icons.launch, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.verified_user_outlined,
                    'Kullanım Şartları',
                    'v1.0',
                    trailing: Icon(Icons.launch, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.data_object_outlined,
                    'Verilerim',
                    'Yerel + Sunucu',
                    trailing: Icon(Icons.arrow_forward_ios, size: 15, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.delete_sweep_outlined,
                    'Önbelleği Temizle',
                    '~4.2 MB',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Önbellek temizlendi'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.icePrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _h(isDark, '💡 OfficialAI Hakkında'),
                  _item(
                    isDark,
                    Icons.info_outline,
                    'Hakkımızda',
                    'AI destekli resmi evrak asistanı',
                    trailing: Icon(Icons.arrow_forward_ios, size: 15, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.star_rate_outlined,
                    'Uygulamayı Puanla',
                    'Amazon Appstore',
                    trailing: Icon(Icons.launch, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.share_outlined,
                    'Arkadaşlarınla Paylaş',
                    'Ücretsiz OfficialAI\'ı tanıt',
                  ),
                  const GlassDivider(),
                  _item(
                    isDark,
                    Icons.contact_support_outlined,
                    'İletişim & Destek',
                    'support@officialai.app',
                    trailing: Icon(Icons.email_outlined, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.icePrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome_sharp, color: AppColors.icePrimary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OfficialAI Pro',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Amazon Appstore’da tamamen ücretsiz!',
                              style: TextStyle(
                                color: AppColors.icePrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Sınırsız Dilekçe, E-posta ve CV oluşturma\n• Sınırsız OCR belge tarama & analiz\n• Sınırsız AI sohbet\n• Reklamsız kullanım',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'Ücretsiz Kullan (Premium)',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Bu sürüm zaten ücretsiz ve premiumdur 🎉'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green.withOpacity(0.9),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.all(14),
              backgroundColor: Colors.transparent,
              border: Border.all(color: AppColors.icePrimary.withOpacity(0.25)),
              child: Text(
                'OfficialAI © 2025 — Tüm hakları saklıdır. '
                'Uygulama Amazon Appstore, Google Play ve diğer platformlarda ücretsiz olarak yayınlanmaktadır. '
                'Ücretsiz katman: Google Gemini (15 RPM), Google ML Kit Text Recognition, Local Storage.',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontSize: 11,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        t,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontWeight: FontWeight.w800,
          fontSize: 14,
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.icePrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.icePrimary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.black54,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white38 : Colors.black45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      dense: true,
    );
  }
}
