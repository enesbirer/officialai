import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/theme_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final List<Map<String, dynamic>> _demoFavs = [
    {'id': 'f1', 'documentId': '1', 'type': 'petition', 'title': 'İşten Çıkış Dilekçesi - 2025',
      'preview': 'Profesyonel formatta hazırlanmış, resmi dilde dilekçe örneği...', 'date': '15 Ocak 2025'},
    {'id': 'f2', 'documentId': '2', 'type': 'cv', 'title': 'Yazılım Uzmanı CV (ATS)',
      'preview': 'Ahmet Yılmaz - 7 yıl deneyim, Flutter, Node.js uzmanlığı...', 'date': '12 Ocak 2025'},
    {'id': 'f3', 'documentId': '3', 'type': 'email', 'title': 'İş Başvurusu - XYZ Şirketi',
      'preview': 'Sayın İnsan Kaynakları Müdürlüğü, Pozisyon için başvurumu...', 'date': '10 Ocak 2025'},
  ];

  IconData _iconFor(String type) => switch (type) {
        'petition' => Icons.description_outlined,
        'email' => Icons.email_outlined,
        'cv' => Icons.badge_outlined,
        'ocr' => Icons.document_scanner_outlined,
        _ => Icons.favorite_outline,
      };

  Color _colorFor(String type) => switch (type) {
        'petition' => Colors.indigo,
        'email' => Colors.teal,
        'cv' => Colors.deepPurple,
        'ocr' => Colors.orangeAccent,
        _ => AppColors.icePrimary,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final favAsync = ref.watch(favoritesProvider);

    final page = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Favorilerim',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(favoritesProvider),
            icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
      body: favAsync.when(
        loading: () => _buildShimmer(isDark),
        error: (e, _) => _buildList(context, isDark, _demoFavs),
        data: (list) {
          final data = list.isEmpty ? _demoFavs : list;
          if (data.isEmpty) return _buildEmpty(isDark);
          return _buildList(context, isDark, data);
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );

    return isDark
        ? GlassBackground.iceDarkGradient(child: page)
        : GlassBackground.iceLightGradient(child: page);
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(14),
            )),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 10),
                  Container(height: 12, width: 150, color: isDark ? Colors.white10 : Colors.black12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  Colors.pinkAccent.withOpacity(0.2),
                  Colors.redAccent.withOpacity(0.2),
                ]),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.favorite_border, size: 60, color: Colors.pinkAccent),
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz favori yok',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Oluşturduğunuz dokümanları favorilere ekleyerek hızlıca erişebilirsiniz.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isDark, List<Map<String, dynamic>> list) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(favoritesProvider),
      color: AppColors.icePrimary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final f = list[i];
          final type = (f['type'] ?? f['documentType'] ?? '').toString();
          final title = (f['title'] ?? '').toString();
          final preview = (f['preview'] ?? f['content']?.toString().substring(0, 120) ?? '').toString();
          final date = (f['date'] ?? f['createdAt']?.toString().substring(0, 10) ?? '').toString();
          final docId = (f['documentId'] ?? f['id'] ?? '').toString();

          return Dismissible(
            key: ValueKey('fav-${f['id'] ?? docId}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            confirmDismiss: (_) async {
              if (docId.isEmpty) return true;
              try {
                await ref.read(
                  favoriteToggleProvider((documentId: docId, documentType: type)).future,
                );
                return true;
              } catch (_) {
                return true;
              }
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _colorFor(type).withOpacity(0.9),
                        _colorFor(type),
                      ]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(_iconFor(type), color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'Favori Doküman' : title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 13,
                              color: isDark ? Colors.white38 : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white38 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      const Icon(Icons.favorite, color: Colors.pinkAccent, size: 24),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: () async {
                          final full = '$title\n\n$preview';
                          await Clipboard.setData(ClipboardData(text: full));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✓ Kopyalandı'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.copy_outlined,
                          size: 20,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
