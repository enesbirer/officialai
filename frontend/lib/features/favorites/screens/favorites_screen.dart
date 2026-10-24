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

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  IconData _iconFor(String type) => switch (type) {
        'petition' => Icons.description_outlined,
        'email' => Icons.mail_outline_rounded,
        'cv' => Icons.badge_outlined,
        'ocr' => Icons.document_scanner_outlined,
        _ => Icons.favorite_outline,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final favAsync = ref.watch(favoritesProvider);

    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

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
          'Favorilerim',
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
            onPressed: () => ref.invalidate(favoritesProvider),
            icon: Icon(Icons.refresh_rounded, color: text, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: favAsync.when(
        loading: () => _buildShimmer(isDark),
        error: (e, _) => _buildError(isDark, e),
        data: (list) {
          if (list.isEmpty) return _buildEmpty(isDark);
          return _buildList(context, isDark, list);
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );

    return isDark
        ? GlassBackground.iceDarkGradient(child: page)
        : GlassBackground.iceLightGradient(child: page);
  }

  Future<void> _export(Map<String, dynamic> f) async {
    final title = (f['title'] ?? '').toString();
    final content = (f['content'] ?? '').toString();
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
        type: (f['type'] ?? f['documentType'] ?? 'document').toString(),
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

  Widget _buildError(bool isDark, Object error) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: accent),
            const SizedBox(height: 16),
            Text(
              'Favoriler yüklenemedi',
              style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              friendlyErrorMessage(error, action: 'Favori listesi'),
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
                onPressed: () => ref.invalidate(favoritesProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final placeholder = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: placeholder,
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.favorite_border_rounded, size: 44, color: accent),
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz favori yok',
              style: TextStyle(
                color: text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Oluşturduğunuz dokümanları favorilere ekleyerek hızlıca erişebilirsiniz.',
              style: TextStyle(
                color: sub,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isDark, List<Map<String, dynamic>> list) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(favoritesProvider),
      color: accent,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                color: AppColors.error,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
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
                          title.isEmpty ? 'Favori Doküman' : title,
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_outlined, size: 13, color: sub),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: TextStyle(fontSize: 13, color: sub),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: sub,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Icon(Icons.favorite_rounded, color: accent, size: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _export(f),
                              icon: Icon(Icons.picture_as_pdf_outlined, size: 20, color: sub),
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final full = '$title\n\n$preview';
                                await Clipboard.setData(ClipboardData(text: full));
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kopyalandı'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.copy_outlined, size: 20, color: sub),
                            ),
                          ),
                        ],
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
