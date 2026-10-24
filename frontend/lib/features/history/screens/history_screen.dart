import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/pdf_export_utils.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/primary_button.dart';
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

  IconData _iconFor(String type) => switch (type) {
        'petition' => Icons.description_outlined,
        'email' => Icons.mail_outline_rounded,
        'cv' => Icons.badge_outlined,
        'ocr' => Icons.document_scanner_outlined,
        _ => Icons.folder_outlined,
      };

  String _typeLabelFor(String type) => switch (type) {
        'petition' => 'Dilekçe',
        'email' => 'E-posta',
        'cv' => 'CV',
        'ocr' => 'OCR Analiz',
        _ => 'Doküman',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final docsAsync = ref.watch(documentsProvider(_selectedType == 'all' ? null : _selectedType));

    return isDark
        ? GlassBackground.iceDarkGradient(child: _buildPage(isDark, docsAsync))
        : GlassBackground.iceLightGradient(child: _buildPage(isDark, docsAsync));
  }

  Widget _buildPage(bool isDark, AsyncValue<List<Map<String, dynamic>>> docsAsync) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Scaffold(
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
          'Doküman Geçmişi',
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
            onPressed: () => ref.invalidate(documentsProvider(null)),
            icon: Icon(Icons.refresh_rounded, color: text, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? accent
                            : (isDark ? AppColors.darkFill : AppColors.lightFill),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _filterLabels[key] ?? '',
                        style: TextStyle(
                          color: selected ? Colors.white : sub,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 15,
                          letterSpacing: -0.2,
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
              error: (e, _) => _buildErrorState(isDark, e),
              data: (list) {
                if (list.isEmpty) return _buildEmptyState(isDark);
                return _buildList(isDark, list);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Future<void> _export(Map<String, dynamic> d) async {
    final title = d['title']?.toString() ?? 'Belge';
    final content = (d['content'] ?? '').toString();
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu belgeye ait içerik bulunamadı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await PdfExportUtils.exportDocument(
        type: d['type']?.toString() ?? 'document',
        title: title,
        content: content,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyErrorMessage(e, action: 'PDF oluşturma')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _sectionHeader(Color sub) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        'DOKÜMANLAR',
        style: TextStyle(
          color: sub,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(6, (i) {
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
                                width: 180,
                                decoration: BoxDecoration(
                                  color: sub.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 12,
                                width: 110,
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
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.inbox_outlined, size: 44, color: accent),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedType == 'all' ? 'Henüz doküman oluşturulmadı' : 'Bu kategoride doküman yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dilekçe, e-posta, CV veya OCR özelliklerini kullanarak hemen bir doküman oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Object error) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: accent),
            const SizedBox(height: 16),
            Text(
              'Dokümanlar yüklenemedi',
              textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              friendlyErrorMessage(error, action: 'Doküman listesi'),
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                text: 'Tekrar Dene',
                icon: Icons.refresh_rounded,
                variant: PrimaryButtonVariant.outlined,
                onPressed: () => ref.invalidate(documentsProvider(null)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool isDark, List<Map<String, dynamic>> list) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        _sectionHeader(sub),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const GlassDivider(height: 1, indent: 72),
                _docRow(list[i], isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _docRow(Map<String, dynamic> d, bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    final type = d['type']?.toString() ?? '';
    final title = d['title']?.toString() ?? '';
    final date = d['date']?.toString() ?? d['createdAt']?.toString().substring(0, 10) ?? '';
    final preview = d['preview']?.toString() ?? d['content']?.toString().substring(0, 120) ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
            child: Icon(_iconFor(type), color: accent, size: 22),
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
                    color: text,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_typeLabelFor(type)} • $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: sub, fontSize: 13),
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: sub, fontSize: 13, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _export(d),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.picture_as_pdf_outlined, color: sub, size: 20),
              ),
            ),
          ),
          Semantics(
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () async {
                final full = '${d['title'] ?? ''}\n\n${d['content'] ?? d['preview'] ?? ''}';
                await Clipboard.setData(ClipboardData(text: full));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('İçerik kopyalandı'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.copy_outlined, color: sub, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
