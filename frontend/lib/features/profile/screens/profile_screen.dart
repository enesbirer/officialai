import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final auth = ref.watch(authNotifierProvider);
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    final user = auth.valueOrNull;
    final firstName = user?.firstName ?? 'Kullanıcı';
    final lastName = user?.lastName ?? 'Adı';
    final email = user?.email ?? 'kullanici@officialai.com';
    final initials =
        '${firstName.characters.first.toUpperCase()}${lastName.characters.first.toUpperCase()}';

    final page = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          'Profil',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_outlined, color: text, size: 24),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kullanıcı kartı
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar',
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        auth.when(
                          loading: () => SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                          ),
                          error: (_, __) => Text(
                            'Kullanıcı',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              color: text,
                            ),
                          ),
                          data: (_) => Text(
                            '$firstName $lastName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              color: text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: sub, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.verified_outlined, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Doğrulandı',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // İstatistikler
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _stat(Icons.description_outlined, '12', 'Doküman', accent, sub),
                  _statDivider(isDark),
                  _stat(Icons.favorite_border, '4', 'Favori', accent, sub),
                  _statDivider(isDark),
                  _stat(Icons.auto_awesome_outlined, '38', 'AI Kullanımı', accent, sub),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionHeader('GÖRÜNÜM & DİL', sub),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.contrast_outlined,
                    title: 'Tema',
                    subtitle: theme == ThemeMode.system
                        ? 'Sistem teması'
                        : theme == ThemeMode.dark
                            ? 'Karanlık mod'
                            : 'Aydınlık mod',
                    onTap: () {
                      final next = theme == ThemeMode.light
                          ? ThemeMode.dark
                          : theme == ThemeMode.dark
                              ? ThemeMode.system
                              : ThemeMode.light;
                      ref.read(themeModeProvider.notifier).setTheme(next);
                    },
                    trailing: _themePopup(context, ref, theme, isDark, accent),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.translate_outlined,
                    title: 'Uygulama Dili',
                    subtitle: locale.languageCode == 'tr' ? 'Türkçe' : 'English',
                    onTap: () {
                      final next =
                          locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
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
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionHeader('İÇERİK', sub),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.history_outlined,
                    title: 'Doküman Geçmişi',
                    subtitle: 'Oluşturduğunuz tüm dokümanlar',
                    onTap: () => context.go('/history'),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.favorite_border,
                    title: 'Favorilerim',
                    subtitle: 'Yıldızlı dokümanlar',
                    onTap: () => context.go('/favorites'),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.chat_bubble_outline,
                    title: 'Sohbet Geçmişi',
                    subtitle: 'AI ile konuşmalarınız',
                    onTap: () => AppNavigation.push(context, '/chat'),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Açık',
                    trailing: Switch(value: true, onChanged: (_) {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionHeader('DİĞER', sub),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.settings_outlined,
                    title: 'Ayarlar',
                    subtitle: 'Hakkında, gizlilik, sürüm vb.',
                    onTap: () => context.push('/settings'),
                  ),
                  const GlassDivider(height: 1, indent: 60),
                  _tile(
                    text: text,
                    sub: sub,
                    accent: accent,
                    icon: Icons.help_outline,
                    title: 'Yardım & Destek',
                    subtitle: 'SSS, iletişim',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Çıkış
            GlassContainer(
              padding: EdgeInsets.zero,
              child: ListTile(
                onTap: () => _confirmLogout(context, ref, sub),
                leading: SizedBox(
                  width: 29,
                  height: 29,
                  child: Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                ),
                title: Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );

    return isDark
        ? GlassBackground.iceDarkGradient(child: page)
        : GlassBackground.iceLightGradient(child: page);
  }

  Widget _sectionHeader(String title, Color sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: sub,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color accent, Color sub) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: sub),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      width: 0.5,
      height: 40,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _tile({
    required Color text,
    required Color sub,
    required Color accent,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
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
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(color: sub, fontSize: 13),
            ),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded, size: 22, color: sub),
    );
  }

  Widget _themePopup(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
    bool isDark,
    Color accent,
  ) {
    return PopupMenuButton<ThemeMode>(
      initialValue: current,
      onSelected: (t) => ref.read(themeModeProvider.notifier).setTheme(t),
      color: isDark ? AppColors.darkGlassStrong : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Icon(
          current == ThemeMode.dark
              ? Icons.dark_mode_outlined
              : current == ThemeMode.system
                  ? Icons.brightness_medium_outlined
                  : Icons.light_mode_outlined,
          color: accent,
          size: 18,
        ),
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(Icons.light_mode_outlined, size: 20),
              SizedBox(width: 12),
              Text('Aydınlık'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(Icons.dark_mode_outlined, size: 20),
              SizedBox(width: 12),
              Text('Karanlık'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(Icons.brightness_medium_outlined, size: 20),
              SizedBox(width: 12),
              Text('Sistem'),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    Color sub,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, size: 44, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Çıkış Yap',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Oturumunuz kapatılacak, ancak dokümanlarınız sunucuda kalacaktır.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: sub),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );
  }
}
