import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/ai_provider.dart';

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

class _Action {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color gradient1;
  final Color gradient2;
  const _Action(
      this.title, this.subtitle, this.icon, this.route, this.gradient1, this.gradient2);
}

const List<_Action> _actions = [
  _Action('Dilekçe Üret', '10+ kategoride AI dilekçe', Icons.description_outlined, '/petition',
      Color(0xFF0077B6), Color(0xFF00A8E1)),
  _Action('E-posta Yaz', 'Resmi/İş/Özel/BAşvuru', Icons.email_outlined, '/email', Color(0xFF028090),
      Color(0xFF48CAE4)),
  _Action('CV Hazırla', 'ATS uyumlu modern CV', Icons.badge_outlined, '/cv', Color(0xFF168AAD),
      Color(0xFF90E0EF)),
  _Action('Belge Tara', 'OCR ile analiz ettir', Icons.document_scanner_outlined, '/scanner',
      Color(0xFF00B4D8), Color(0xFFCAF0F8)),
];

const List<_Stat> _demoStats = [
  _Stat('Dilekçe', '0', Icons.description, AppColors.icePrimary),
  _Stat('E-posta', '0', Icons.email, AppColors.iceAccent),
  _Stat('CV', '0', Icons.badge, AppColors.iceSecondary),
  _Stat('Favori', '0', Icons.favorite, Color(0xFFF472B6)),
];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authNotifierProvider);
    final user = auth.valueOrNull;
    final docs = ref.watch(documentsProvider(null));

    return Scaffold(
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _buildBody(context, ref, user, docs, isDark))
          : GlassBackground.iceLightGradient(child: _buildBody(context, ref, user, docs, isDark)),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, dynamic user,
      AsyncValue<List<Map>> docs, bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final name = (user?.firstName as String?) ?? 'Değerli';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hoş geldin, $name 👋',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: text,
                              )),
                      const SizedBox(height: 4),
                      Text('Bugün ne yapmak istersin?',
                          style: TextStyle(color: sub, fontSize: 14)),
                    ],
                  ),
                ),
                GlassContainer(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 18,
                  onTap: () => context.push('/settings'),
                  child: const Icon(Icons.settings_outlined, size: 24),
                ),
                const SizedBox(width: 10),
                GlassContainer(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 18,
                  onTap: () => context.push('/chat'),
                  child:
                      const Icon(Icons.support_agent_outlined, size: 24, color: AppColors.icePrimary),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Actions
            Row(
              children: [
                Text('Hızlı İşlemler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: text,
                        )),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: _actions.length,
              itemBuilder: (_, i) {
                final a = _actions[i];
                return GlassContainer(
                  onTap: () => context.go(a.route),
                  borderRadius: 24,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [a.gradient1, a.gradient2]),
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 26),
                      ),
                      const Spacer(),
                      Text(a.title,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800, color: text)),
                      const SizedBox(height: 4),
                      Text(a.subtitle,
                          style: TextStyle(color: sub, fontSize: 11, height: 1.35)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Stats
            Row(
              children: [
                Text('İstatistikler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: text,
                        )),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _demoStats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final s = _demoStats[i];
                  return GlassContainer(
                    width: 150,
                    borderRadius: 22,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(s.icon, color: s.color, size: 26),
                        const Spacer(),
                        Text(s.value,
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w800, color: text)),
                        Text(s.label,
                            style: TextStyle(color: sub, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Recent Docs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Son Dokümanlar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: text,
                        )),
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: const Text('Tümü', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            docs.when(
              loading: () => _placeholderRecent(sub, isDark),
              error: (_, __) => _placeholderRecent(sub, isDark),
              data: (list) {
                if (list.isEmpty) return _emptyState(text, sub);
                return Column(
                  children: List.generate(
                    list.length > 4 ? 4 : list.length,
                    (i) {
                      final d = list[i];
                      return _docTile(d, sub, text, context);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _placeholderRecent(Color sub, bool isDark) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.icePrimary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 160, color: sub.withAlpha(40)),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 100, color: sub.withAlpha(25)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(Color text, Color sub) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.icePrimary),
          const SizedBox(height: 12),
          Text('Henüz doküman oluşturmadınız',
              style: TextStyle(fontWeight: FontWeight.w700, color: text, fontSize: 15)),
          const SizedBox(height: 6),
          Text('Hızlı işlemlerden birini seçerek başlayın',
              style: TextStyle(color: sub, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _docTile(Map d, Color sub, Color text, BuildContext context) {
    final title = d['title']?.toString() ?? 'Doküman';
    final type = d['documentType']?.toString() ?? 'petition';
    final createdAt = d['createdAt']?.toString() ?? '';
    IconData icon = Icons.description;
    Color col = AppColors.icePrimary;
    switch (type) {
      case 'email':
        icon = Icons.email;
        col = AppColors.iceAccent;
        break;
      case 'cv':
        icon = Icons.badge;
        col = AppColors.iceSecondary;
        break;
      case 'ocr':
        icon = Icons.document_scanner;
        col = const Color(0xFF168AAD);
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassContainer(
        onTap: () {
          if (type == 'petition') context.go('/petition');
          if (type == 'email') context.go('/email');
          if (type == 'cv') context.go('/cv');
        },
        borderRadius: 18,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: col.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: col, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, color: text)),
                  const SizedBox(height: 4),
                  Text(
                      '${type.toUpperCase()} • ${createdAt.isNotEmpty ? createdAt.substring(0, 10) : ''}',
                      style: TextStyle(color: sub, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.icePrimary),
          ],
        ),
      ),
    );
  }
}
