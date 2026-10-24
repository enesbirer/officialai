import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/ai_provider.dart';

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
}

class _Action {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  const _Action(this.title, this.subtitle, this.icon, this.route);
}

const List<_Action> _actions = [
  _Action('Dilekçe Üret', '10+ kategoride AI dilekçe', Icons.description_outlined, '/petition'),
  _Action('E-posta Yaz', 'Resmi / İş / Özel / Başvuru', Icons.mail_outline_rounded, '/email'),
  _Action('CV Hazırla', 'ATS uyumlu modern CV', Icons.badge_outlined, '/cv'),
  _Action('Belge Tara', 'OCR ile analiz ettir', Icons.document_scanner_outlined, '/scanner'),
];

const List<_Stat> _demoStats = [
  _Stat('Dilekçe', '0', Icons.description_outlined),
  _Stat('E-posta', '0', Icons.mail_outline_rounded),
  _Stat('CV', '0', Icons.badge_outlined),
  _Stat('Favori', '0', Icons.favorite_border),
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
      backgroundColor: Colors.transparent,
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
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final name = (user?.firstName as String?) ?? 'Değerli';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş geldin, $name',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bugün ne yapmak istersin?',
                        style: TextStyle(fontSize: 15, color: sub),
                      ),
                    ],
                  ),
                ),
                _IconButton(
                  icon: Icons.settings_outlined,
                  color: text,
                  onTap: () => context.push('/settings'),
                ),
                const SizedBox(width: 4),
                _IconButton(
                  icon: Icons.support_agent_outlined,
                  color: accent,
                  onTap: () => context.push('/chat'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Hızlı İşlemler
            _sectionTitle('Hızlı İşlemler', text),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: _actions.length,
              itemBuilder: (_, i) {
                final a = _actions[i];
                return GlassContainer(
                  onTap: () => AppNavigation.push(context, a.route),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(a.icon, color: accent, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: sub, fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // İstatistikler
            _sectionTitle('İstatistikler', text),
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: _demoStats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final s = _demoStats[i];
                  return GlassContainer(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(s.icon, color: accent, size: 22),
                        const Spacer(),
                        Text(
                          s.value,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: text,
                          ),
                        ),
                        Text(
                          s.label,
                          style: TextStyle(color: sub, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Son Dokümanlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Son Dokümanlar', text),
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: const Text('Tümü'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            docs.when(
              loading: () => _placeholderRecent(sub),
              error: (_, __) => _placeholderRecent(sub),
              data: (list) {
                if (list.isEmpty) return _emptyState(text, sub, accent);
                final items = list.take(4).toList();
                return GlassContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const GlassDivider(height: 1, indent: 72),
                        _docTile(items[i], sub, text, accent, context),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color text) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: text,
      ),
    );
  }

  Widget _placeholderRecent(Color sub) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(3, (i) {
          return Column(
            children: [
              if (i > 0) const GlassDivider(height: 1, indent: 72),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: sub.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 160,
                            decoration: BoxDecoration(
                              color: sub.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 100,
                            decoration: BoxDecoration(
                              color: sub.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _emptyState(Color text, Color sub, Color accent) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: accent),
          const SizedBox(height: 12),
          Text(
            'Henüz doküman oluşturmadınız',
            style: TextStyle(fontWeight: FontWeight.w600, color: text, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Hızlı işlemlerden birini seçerek başlayın',
            textAlign: TextAlign.center,
            style: TextStyle(color: sub, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _docTile(Map d, Color sub, Color text, Color accent, BuildContext context) {
    final title = d['title']?.toString() ?? 'Doküman';
    final type = d['documentType']?.toString() ?? 'petition';
    final createdAt = d['createdAt']?.toString() ?? '';
    IconData icon = Icons.description_outlined;
    switch (type) {
      case 'email':
        icon = Icons.mail_outline_rounded;
        break;
      case 'cv':
        icon = Icons.badge_outlined;
        break;
      case 'ocr':
        icon = Icons.document_scanner_outlined;
        break;
    }
    return InkWell(
      onTap: () {
        if (type == 'petition') AppNavigation.push(context, '/petition');
        if (type == 'email') AppNavigation.push(context, '/email');
        if (type == 'cv') AppNavigation.push(context, '/cv');
        if (type == 'ocr') AppNavigation.push(context, '/scanner');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${type.toUpperCase()} • ${createdAt.isNotEmpty ? createdAt.substring(0, 10) : ''}',
                    style: TextStyle(color: sub, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: sub, size: 22),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
