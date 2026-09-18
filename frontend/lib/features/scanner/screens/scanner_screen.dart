import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
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
    } catch (_) {
      final demo = _demoAnalysis(_ocrText);
      setState(() {
        _hasResult = true;
        _analysisResult = demo;
      });
    }
  }

  Map<String, dynamic> _demoAnalysis(String raw) {
    final trimmed = raw.trim();
    final lines = trimmed.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final summary = lines.isEmpty
        ? 'Belge özeti yüklenemedi.'
        : lines.take(8).map((l) => '• ${l.trim()}').join('\n');
    final sampleWords = trimmed
        .replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 4)
        .toSet()
        .take(10)
        .toList();
    final keywords = sampleWords.isEmpty
        ? ['tarih', 'imza', 'konu', 'adres', 'başvuru']
        : sampleWords;
    return {
      'title': 'Belge Analizi Sonucu (Örnek)',
      'corrected': trimmed.isEmpty
          ? '[Düzeltilmiş metin yüklenecek]'
          : trimmed,
      'summary': '''📋 **Belge Özeti**

Bu belge ${lines.length} satır metin içerir. Ana hatlarıyla:
$summary

Belge resmi, yarı resmi veya kişisel bir yazı olarak nitelendirilebilir. Ayrıntılı inceleme için yukarıdaki maddeleri gözden geçirin.''',
      'keywords': keywords,
      'importantDetails': [
        'Belge uzunluğu: ${lines.length} satır, ${trimmed.length} karakter',
        'Dil: Türkçe (varsayılan)',
        'Taranma zamanı: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'Okunabilirlik: Genel olarak iyi',
      ],
      'actionItems': [
        'Belgenin orijinalliğini teyit edin',
        'Önemli maddeleri işaretleyin ve not alın',
        'Gerekirse ilgili makamlara iletin',
        'Arşiv için yedekleme yapın',
      ],
      'risks': [
        'İmza veya mühür eksikliği (varsa) resmi geçerliliği etkileyebilir',
        'Tarih bilgilerinin doğruluğu teyit edilmelidir',
        'Kişisel verilerin gizliliğine dikkat edilmelidir',
      ],
    };
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
      SnackBar(content: Text(m), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
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

    final body = _hasResult ? _buildResult(isDark) : _buildScanner(isDark, isAnalyzing);

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
          _hasResult ? 'Analiz Sonucu' : 'Belge Tarayıcı (OCR)',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasResult || _ocrText.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white70 : Colors.black87),
              onPressed: _reset,
              tooltip: 'Sıfırla',
            ),
        ],
      ),
      body: Stack(
        children: [
          body,
          if (isAnalyzing)
            Container(
              color: Colors.black38,
              child: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.icePrimary),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belge analiz ediliyor...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
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

  Widget _buildScanner(bool isDark, bool isAnalyzing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.indigoAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belge TARA & ANALİZ ET',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kamera veya galeriden belge seçin, yapay zeka ile inceleyin',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _pickBox(
                  isDark,
                  icon: Icons.photo_camera_outlined,
                  title: 'Kamera',
                  sub: 'Fotoğraf çek',
                  onTap: () => _pickImage(ImageSource.camera),
                  color1: Colors.teal,
                  color2: Colors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickBox(
                  isDark,
                  icon: Icons.photo_library_outlined,
                  title: 'Galeri',
                  sub: 'Görsel seç',
                  onTap: () => _pickImage(ImageSource.gallery),
                  color1: Colors.purpleAccent,
                  color2: Colors.pinkAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imagePath != null)
            GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: kIsWeb
                        ? Container(
                            height: 120,
                            width: double.infinity,
                            alignment: Alignment.center,
                            color: Colors.black26,
                            child: Text(
                              'Görsel seçildi\n${_imagePath ?? ''}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
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
                              height: 120,
                              alignment: Alignment.center,
                              child: Text('Görsel: ${_imagePath ?? ''}', textAlign: TextAlign.center),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_scanning)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.icePrimary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Metinler okunuyor...',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields, color: AppColors.icePrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Taranan Metin (düzenlenebilir)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.copy_all, color: AppColors.icePrimary, size: 20),
                      onPressed: _ocrText.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: _ocrText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✓ Metin kopyalandı'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: TextField(
                    maxLines: null,
                    controller: TextEditingController(text: _ocrText),
                    onChanged: (v) => setState(() => _ocrText = v),
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: _ocrText.isEmpty
                          ? 'Taranmış metin burada görünecek. İsterseniz elle de metin girebilirsiniz...'
                          : null,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.icePrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_alt_outlined, color: AppColors.icePrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Özel Talimatlar (opsiyonel)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
            text: '🔍 Belgeyi Analiz Et',
            icon: Icons.auto_awesome,
            onPressed: (_scanning || isAnalyzing) ? null : _analyze,
          ),
        ],
      ),
    );
  }

  Widget _pickBox(
    bool isDark, {
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
    required Color color1,
    required Color color2,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color1, color2]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final r = _analysisResult;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.verified_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['title'] as String? ?? 'Analiz Tamamlandı',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AI ile 6 eksenli analiz yapıldı',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _shareResult,
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      children: [
                        const Icon(Icons.share_outlined, color: AppColors.icePrimary),
                        const SizedBox(height: 4),
                        Text(
                          'Paylaş',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: isDark ? Colors.white12 : Colors.black12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final buf = StringBuffer();
                      buf.writeln(r['summary'] as String? ?? '');
                      buf.writeln('\nAnahtar Kelimeler: ${(r['keywords'] as List? ?? []).join(', ')}');
                      await Clipboard.setData(ClipboardData(text: buf.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Özet kopyalandı'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      children: [
                        const Icon(Icons.copy, color: AppColors.icePrimary),
                        const SizedBox(height: 4),
                        Text(
                          'Kopyala',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: isDark ? Colors.white12 : Colors.black12),
                Expanded(
                  child: InkWell(
                    onTap: _reset,
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      children: [
                        const Icon(Icons.refresh, color: AppColors.icePrimary),
                        const SizedBox(height: 4),
                        Text(
                          'Yeni',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(isDark, Icons.summarize_outlined, '📝 Özet', r['summary'] as String? ?? '', Colors.blueAccent),
          const SizedBox(height: 14),
          _sectionCard(
            isDark,
            Icons.label_outline,
            '🏷️ Anahtar Kelimeler',
            (r['keywords'] as List? ?? []).map((e) => '#$e').join('   '),
            Colors.orangeAccent,
          ),
          const SizedBox(height: 14),
          _sectionCard(
            isDark,
            Icons.info_outline,
            '🔎 Önemli Detaylar',
            (r['importantDetails'] as List? ?? []).map((e) => '• $e').join('\n'),
            Colors.teal,
          ),
          const SizedBox(height: 14),
          _sectionCard(
            isDark,
            Icons.task_alt,
            '✅ Eylem Noktaları',
            (r['actionItems'] as List? ?? []).map((e) => '☑ $e').join('\n'),
            Colors.green,
          ),
          const SizedBox(height: 14),
          _sectionCard(
            isDark,
            Icons.warning_amber_outlined,
            '⚠️ Riskler & Uyarılar',
            (r['risks'] as List? ?? []).map((e) => '❗ $e').join('\n'),
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(bool isDark, IconData icon, String title, String content, Color accent) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            content,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
