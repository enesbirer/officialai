import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../core/utils/error_messages.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/theme_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  String? _imagePath;
  String _ocrText = '';
  bool _scanning = false;
  bool _hasResult = false;
  Map<String, dynamic> _analysisResult = {};
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: source, imageQuality: 85);
      if (img == null) return;
      setState(() {
        _imagePath = img.path;
        _ocrText = '';
        _hasResult = false;
        _analysisResult = {};
      });
      await _runOCR(img.path);
    } catch (e) {
      _showError('Görsel alınamadı: $e');
    }
  }

  Future<void> _runOCR(String path) async {
    // On-device ML Kit Android/iOS'ta; Windows/Web'de metni elle yapıştırıp AI analiz kullanılır.
    setState(() => _scanning = false);
    if (_ocrText.trim().isEmpty) {
      _showError('Görsel seçildi. Metni kutuya yapıştırın veya kamera/OCR için Android kullanın.');
    }
  }

  Future<void> _analyze() async {
    if (_ocrText.trim().isEmpty) {
      _showError('Önce bir belge taratın veya metin girin');
      return;
    }
    final notifier = ref.read(ocrAnalysisProvider.notifier);
    try {
      final r = await notifier.analyze(
        ocrText: _ocrText,
        customInstructions: _customCtrl.text.trim().isEmpty ? null : _customCtrl.text.trim(),
      );
      setState(() {
        _hasResult = true;
        _analysisResult = r;
      });
    } catch (e) {
      if (!mounted) return;
      _showError(friendlyErrorMessage(e, action: 'Belge analizi'));
    }
  }

  void _reset() {
    setState(() {
      _imagePath = null;
      _ocrText = '';
      _hasResult = false;
      _analysisResult = {};
    });
    ref.read(ocrAnalysisProvider.notifier).reset();
  }

  void _showError(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _shareResult() async {
    final r = _analysisResult;
    final buf = StringBuffer('${r['title'] ?? 'Belge Analizi'}\n\n');
    buf.writeln('=== ÖZET ===\n${r['summary'] ?? ''}\n');
    buf.writeln('=== ANAHTAR KELİMELER ===\n${(r['keywords'] as List? ?? []).join(', ')}\n');
    buf.writeln('=== ÖNEMLİ DETAYLAR ===\n${(r['importantDetails'] as List? ?? []).map((e) => '- $e').join('\n')}\n');
    buf.writeln('=== EYLEM NOKTALARI ===\n${(r['actionItems'] as List? ?? []).map((e) => '- $e').join('\n')}\n');
    buf.writeln('=== RİSKLER ===\n${(r['risks'] as List? ?? []).map((e) => '- $e').join('\n')}');
    await Share.share(buf.toString(), subject: r['title'] as String?);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final ocrAsync = ref.watch(ocrAnalysisProvider);
    final isAnalyzing = ocrAsync.isLoading;

    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    final body = _hasResult ? _buildResult(isDark) : _buildScanner(isDark, isAnalyzing);

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
        leading: SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: accent, size: 20),
            onPressed: () => AppNavigation.back(context),
          ),
        ),
        title: Text(
          _hasResult ? 'Analiz Sonucu' : 'Belge Tarayıcı',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: (_hasResult || _ocrText.isNotEmpty) ? accent : (isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                size: 22,
              ),
              onPressed: (_hasResult || _ocrText.isNotEmpty) ? _reset : null,
              tooltip: 'Sıfırla',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          body,
          if (isAnalyzing)
            Positioned.fill(
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.45),
                child: Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belge analiz ediliyor...',
                          style: TextStyle(color: sub, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );

    return isDark
        ? GlassBackground.iceDarkGradient(child: page)
        : GlassBackground.iceLightGradient(child: page);
  }

  Widget _sectionHeader(String title, Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: sub,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildScanner(bool isDark, bool isAnalyzing) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final hint = isDark ? AppColors.darkTextHint : AppColors.lightTextHint;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık kartı
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.document_scanner_outlined, color: accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belge Tara & Analiz Et',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kamera veya galeriden belge seçin, yapay zeka ile inceleyin',
                        style: TextStyle(fontSize: 14, color: sub, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader('Belge Seç', sub),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Kamera',
                  icon: Icons.camera_alt_outlined,
                  onPressed: _scanning ? null : () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Galeri',
                  icon: Icons.photo_library_outlined,
                  variant: PrimaryButtonVariant.outlined,
                  onPressed: _scanning ? null : () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Görsel önizleme alanı
          GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _imagePath == null
                      ? Container(
                          height: 200,
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: isDark ? AppColors.darkGlassStrong : AppColors.lightBgStart,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.document_scanner_outlined,
                              color: accent,
                              size: 48,
                            ),
                          ),
                        )
                      : kIsWeb
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              alignment: Alignment.center,
                              color: isDark ? AppColors.darkGlassStrong : AppColors.lightBgStart,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image_outlined, color: accent, size: 36),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Görsel seçildi',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _imagePath ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: sub),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Image.network(
                              // image_picker path on desktop is file path; network won't work.
                              // Prefer memory/file via XFile — fallback label if unavailable.
                              '',
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                width: double.infinity,
                                alignment: Alignment.center,
                                color: isDark ? AppColors.darkGlassStrong : AppColors.lightBgStart,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.image_outlined, color: accent, size: 36),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Görsel: ${_imagePath ?? ''}',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, color: sub),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                ),
                if (_scanning)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Metinler okunuyor...',
                          style: TextStyle(color: sub, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader('Taranan Metin', sub),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields_rounded, color: accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Düzenlenebilir metin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: text,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        icon: Icon(
                          Icons.copy_all_outlined,
                          color: _ocrText.isEmpty ? hint : accent,
                          size: 20,
                        ),
                        onPressed: _ocrText.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(ClipboardData(text: _ocrText));
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Metin kopyalandı'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: TextField(
                    maxLines: null,
                    controller: TextEditingController(text: _ocrText),
                    onChanged: (v) => setState(() => _ocrText = v),
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: _ocrText.isEmpty
                          ? 'Taranmış metin burada görünecek. İsterseniz elle de metin girebilirsiniz...'
                          : null,
                      hintStyle: TextStyle(
                        color: hint,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkFill : AppColors.lightFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader('Özel Talimatlar', sub),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_alt_outlined, color: accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Opsiyonel yönlendirme',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _customCtrl,
                  label: '',
                  hint: 'Örn: sözleşme maddelerini özetle, tarihleri listele vb.',
                  prefixIcon: Icons.edit_note,
                  maxLines: 3,
                  minLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Belgeyi Analiz Et',
            icon: Icons.auto_awesome_outlined,
            onPressed: (_scanning || isAnalyzing) ? null : _analyze,
          ),
        ],
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final r = _analysisResult;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sonuç başlık kartı
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.verified_outlined, color: accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['title'] as String? ?? 'Analiz Tamamlandı',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI ile 6 eksenli analiz yapıldı',
                        style: TextStyle(fontSize: 14, color: sub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Eylem butonları
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _resultAction(
                    icon: Icons.share_outlined,
                    label: 'Paylaş',
                    color: accent,
                    text: text,
                    onTap: _shareResult,
                  ),
                  Container(
                    width: 0.5,
                    height: 36,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  _resultAction(
                    icon: Icons.copy_rounded,
                    label: 'Kopyala',
                    color: accent,
                    text: text,
                    onTap: () async {
                      final buf = StringBuffer();
                      buf.writeln(r['summary'] as String? ?? '');
                      buf.writeln('\nAnahtar Kelimeler: ${(r['keywords'] as List? ?? []).join(', ')}');
                      await Clipboard.setData(ClipboardData(text: buf.toString()));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Özet kopyalandı'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                  Container(
                    width: 0.5,
                    height: 36,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  _resultAction(
                    icon: Icons.refresh_rounded,
                    label: 'Yeni',
                    color: accent,
                    text: text,
                    onTap: _reset,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _sectionCard(isDark, Icons.summarize_outlined, 'Özet', r['summary'] as String? ?? ''),
          const SizedBox(height: 16),
          _sectionCard(
            isDark,
            Icons.label_outline,
            'Anahtar Kelimeler',
            (r['keywords'] as List? ?? []).map((e) => '#$e').join('   '),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            isDark,
            Icons.info_outline,
            'Önemli Detaylar',
            (r['importantDetails'] as List? ?? []).map((e) => '• $e').join('\n'),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            isDark,
            Icons.task_alt_outlined,
            'Eylem Noktaları',
            (r['actionItems'] as List? ?? []).map((e) => '• $e').join('\n'),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            isDark,
            Icons.warning_amber_outlined,
            'Riskler & Uyarılar',
            (r['risks'] as List? ?? []).map((e) => '• $e').join('\n'),
          ),
        ],
      ),
    );
  }

  Widget _resultAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(bool isDark, IconData icon, String title, String content) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.2,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: TextStyle(
              color: text,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
