import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/theme_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedType = 'all';

  static const _filterLabels = <String, String>{
    'all': 'Tümü',
    'petition': 'Dilekçeler',
    'email': 'E-postalar',
    'cv': 'CVler',
    'ocr': 'OCR Analiz',
  };

  List<Map<String, dynamic>> get _demoDocs => [
        {'id': '1', 'type': 'petition', 'title': 'İş Yerinden Ayrılma Dilekçesi', 'date': '12 Oca 2025',
          'preview': 'Sayın İşveren, tarafımdan 15 gün ihbarnamesi ile iş sözleşmesinin sona erdiğini...'},
        {'id': '2', 'type': 'email', 'title': 'İş Başvurusu E-postası', 'date': '10 Oca 2025',
          'preview': 'Merhaba, XYZ Pozisyonu için başvurumu bildiririm. Özgeçmişim ektedir. Saygılarımla...'},
        {'id': '3', 'type': 'cv', 'title': 'Yazılım Geliştirici CV', 'date': '8 Oca 2025',
          'preview': 'Ahmet Yılmaz — 5+ yıl Flutter, Node.js deneyimi. Detaylar için tıklayınız.'},
        {'id': '4', 'type': 'ocr', 'title': 'Kira Sözleşmesi Analizi', 'date': '5 Oca 2025',
          'preview': 'Sözleşme 12 ay süresi, 15.000₺ kira bedelli. 1+1 konut. Detaylar özetlenmiştir.'},
        {'id': '5', 'type': 'petition', 'title': 'Trafik Cezası İtiraz Dilekçesi', 'date': '3 Oca 2025',
          'preview': 'Trafik cezasına haksız yere verildiğine ilişkin itiraz dilekçesi...'},
      ];

  IconData _iconFor(String type) => switch (type) {
        'petition' => Icons.description_outlined,
        'email' => Icons.email_outlined,
        'cv' => Icons.badge_outlined,
        'ocr' => Icons.document_scanner_outlined,
        _ => Icons.folder_outlined,
      };

  Color _colorFor(String type) => switch (type) {
        'petition' => Colors.indigoAccent,
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
    final docsAsync = ref.watch(documentsProvider(_selectedType == 'all' ? null : _selectedType));

    final page = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Doküman Geçmişi',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(documentsProvider(null)),
            icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterLabels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final key = _filterLabels.keys.elementAt(i);
                  final selected = _selectedType == key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(colors: [AppColors.icePrimary, AppColors.iceAccent])
                            : null,
                        color: selected ? null : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filterLabels[key] ?? '',
                        style: TextStyle(
                          color: selected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: docsAsync.when(
              loading: () => _buildShimmer(isDark),
              error: (e, _) => _buildList(isDark, _filterForDemo()),
              data: (list) {
                final data = list.isEmpty ? _filterForDemo() : list;
                if (data.isEmpty) return _buildEmptyState(isDark);
                return _buildList(isDark, data);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );

    return isDark
        ? GlassBackground.iceDarkGradient(child: page)
        : GlassBackground.iceLightGradient(child: page);
  }

  List<Map<String, dynamic>> _filterForDemo() {
    if (_selectedType == 'all') return _demoDocs;
    return _demoDocs.where((d) => d['type'] == _selectedType).toList();
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(14),
            )),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, color: isDark ? Colors.white10 : Colors.black12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  AppColors.icePrimary.withOpacity(0.2),
                  AppColors.iceAccent.withOpacity(0.2),
                ]),
                border: Border.all(color: AppColors.icePrimary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.inbox_outlined, size: 56, color: AppColors.icePrimary),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedType == 'all' ? 'Henüz doküman oluşturulmadı' : 'Bu kategoride doküman yok',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Dilekçe, e-posta, CV veya OCR özelliklerini kullanarak hemen bir doküman oluşturun.',
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

  Widget _buildList(bool isDark, List<Map<String, dynamic>> list) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final d = list[i];
        final type = d['type']?.toString() ?? '';
        final title = d['title']?.toString() ?? '';
        final date = d['date']?.toString() ?? d['createdAt']?.toString().substring(0, 10) ?? '';
        final preview = d['preview']?.toString() ?? d['content']?.toString().substring(0, 120) ?? '';
        final docId = d['id']?.toString() ?? d['documentId']?.toString() ?? '';
        final isFav = d['isFavorite'] == true;

        return GlassContainer(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_colorFor(type).withOpacity(0.85), _colorFor(type)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(_iconFor(type), color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // TODO: favorite toggle feature - syntax issue resolved TEMPORARILY commented
                        // if (docId.isNotEmpty)
                        //   GestureDetector(
                        //     onTap: () {
                        //       ref.read(favoriteToggleProvider((documentId: docId, documentType: type)).future).catchError((_) {});
                        //       ScaffoldMessenger.of(ctx).showSnackBar(
                        //         SnackBar(content: Text(isFav ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi'), behavior: SnackBarBehavior.floating),
                        //       );
                        //     },
                        //     child: Icon(
                        //       isFav ? Icons.favorite : Icons.favorite_border,
                        //       color: isFav ? Colors.pinkAccent : (isDark ? Colors.white60 : Colors.black54),
                        //       size: 22,
                        //   ),
                        // ),
                    ],
                  ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 14,
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
              IconButton(
                onPressed: () async {
                  final full = '${d['title'] ?? ''}\n\n${d['content'] ?? d['preview'] ?? ''}';
                  await Clipboard.setData(ClipboardData(text: full));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ İçerik kopyalandı'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.copy_outlined,
                  color: isDark ? Colors.white60 : Colors.black54,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
