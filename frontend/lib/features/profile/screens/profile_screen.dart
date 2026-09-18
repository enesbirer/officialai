import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/primary_button.dart';
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

    final user = auth.valueOrNull;
    final firstName = user?.firstName ?? 'Kullanıcı';
    final lastName = user?.lastName ?? 'Adı';
    final email = user?.email ?? 'kullanici@officialai.com';
    final initials = '${firstName.characters.first.toUpperCase()}${lastName.characters.first.toUpperCase()}';

    final page = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profil',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar',
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.icePrimary, AppColors.iceAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.icePrimary.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        auth.when(
                          loading: () => const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.icePrimary),
                          ),
                          error: (_, __) => Text(
                            'Kullanıcı',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          data: (_) => Text(
                            '$firstName $lastName',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.verified_outlined, size: 13, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Doğrulandı',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 18),
            _statRow(isDark, [
              const _Stat(Icons.description_outlined, '12', 'Doküman', Colors.indigo),
              _statDivider(isDark),
              const _Stat(Icons.favorite_outline, '4', 'Favori', Colors.pinkAccent),
              _statDivider(isDark),
              const _Stat(Icons.auto_awesome_outlined, '38', 'AI Kullanımı', Colors.teal),
            ]),
            const SizedBox(height: 18),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _sectionHeader(isDark, '🎨 Görünüm & Dil'),
                  _tile(
                    isDark,
                    icon: Icons.dark_mode_outlined,
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
                    trailing: _themePopup(context, ref, theme, isDark),
                  ),
                  const GlassDivider(),
                  _tile(
                    isDark,
                    icon: Icons.translate,
                    title: 'Uygulama Dili',
                    subtitle: locale.languageCode == 'tr' ? 'Türkçe 🇹🇷' : 'English 🇬🇧',
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
                      activeColor: AppColors.icePrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _sectionHeader(isDark, '🗂️ İçerik'),
                  _tile(
                    isDark,
                    icon: Icons.history_outlined,
                    title: 'Doküman Geçmişi',
                    subtitle: 'Oluşturduğunuz tüm dokümanlar',
                    onTap: () {
                      // Bottom nav ile zaten erişilebilir
                    },
                  ),
                  const GlassDivider(),
                  _tile(
                    isDark,
                    icon: Icons.favorite_border,
                    title: 'Favorilerim',
                    subtitle: 'Yıldızlı dokümanlar',
                  ),
                  const GlassDivider(),
                  _tile(
                    isDark,
                    icon: Icons.chat_bubble_outline,
                    title: 'Sohbet Geçmişi',
                    subtitle: 'AI ile konuşmalarınız',
                  ),
                  const GlassDivider(),
                  _tile(
                    isDark,
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Açık',
                    trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.icePrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _sectionHeader(isDark, '🔗 Diğer'),
                  _tile(
                    isDark,
                    icon: Icons.settings_outlined,
                    title: 'Ayarlar',
                    subtitle: 'Hakkında, gizlilik, sürüm vb.',
                    onTap: () => context.push('/settings'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 15, color: isDark ? Colors.white38 : Colors.black45),
                  ),
                  const GlassDivider(),
                  _tile(
                    isDark,
                    icon: Icons.help_outline,
                    title: 'Yardım & Destek',
                    subtitle: 'SSS, iletişim',
                    trailing: Icon(Icons.arrow_forward_ios, size: 15, color: isDark ? Colors.white38 : Colors.black45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              text: '🚪 Çıkış Yap',
              icon: Icons.logout_outlined,
              variant: PrimaryButtonVariant.outlined,
              color: Colors.redAccent,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.transparent,
                    content: GlassContainer(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            'Çıkış yapmak istediğinize emin misiniz?',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Oturumunuz kapatılacak, ancak dokümanlarınız sunucuda kalacaktır.',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  text: 'İptal',
                                  variant: PrimaryButtonVariant.glass,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: PrimaryButton(
                                  text: 'Çıkış',
                                  color: Colors.redAccent,
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await ref.read(authNotifierProvider.notifier).logout();
                                    if (context.mounted) context.go('/login');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

  Widget _statRow(bool isDark, List<Widget> children) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(width: 1, height: 42, color: isDark ? Colors.white12 : Colors.black12);
  }

  Widget _sectionHeader(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _tile(
    bool isDark, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.icePrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.icePrimary, size: 20),
      ),
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white38 : Colors.black45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      dense: true,
    );
  }

  Widget _themePopup(BuildContext context, WidgetRef ref, ThemeMode current, bool isDark) {
    return PopupMenuButton<ThemeMode>(
      initialValue: current,
      onSelected: (t) => ref.read(themeModeProvider.notifier).setTheme(t),
      color: isDark ? const Color(0xFF1f2a3a) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.icePrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          current == ThemeMode.dark
              ? Icons.dark_mode
              : current == ThemeMode.system
                  ? Icons.brightness_medium
                  : Icons.light_mode,
          color: AppColors.icePrimary,
          size: 18,
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: const [
              Icon(Icons.light_mode, color: Colors.amber, size: 18),
              SizedBox(width: 10),
              Text('Aydınlık'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: const [
              Icon(Icons.dark_mode, color: Colors.deepPurpleAccent, size: 18),
              SizedBox(width: 10),
              Text('Karanlık'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: const [
              Icon(Icons.brightness_medium, color: AppColors.icePrimary, size: 18),
              SizedBox(width: 10),
              Text('Sistem'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _Stat(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
