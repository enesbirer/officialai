import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Belge (PDF) oluşturma ve dışa aktarma yardımcıları.
///
/// Türkçe karakter (ğ, ş, ı, İ, ç, ö, ü) desteği için Unicode uyumlu
/// Noto Sans yazı tipi kullanılır; yazı tipi indirilemezse varsayılan
/// yazı tipine güvenli biçimde geri dönülür.
class PdfExportUtils {
  static pw.ThemeData? _cachedTheme;
  static bool _themeResolved = false;

  static Future<pw.ThemeData?> _resolveTheme() async {
    if (_themeResolved) return _cachedTheme;
    _themeResolved = true;
    try {
      final regular = await PdfGoogleFonts.notoSansRegular();
      final bold = await PdfGoogleFonts.notoSansBold();
      final italic = await PdfGoogleFonts.notoSansItalic();
      _cachedTheme = pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: italic,
        boldItalic: bold,
      );
    } catch (_) {
      _cachedTheme = null;
    }
    return _cachedTheme;
  }

  static Future<pw.Document> _createDocument() async {
    final theme = await _resolveTheme();
    return theme == null ? pw.Document() : pw.Document(theme: theme);
  }

  /// Belgeyi PDF baytlarına dönüştürür (önizleme/paylaşım için ortak yol).
  ///
  /// [signatureImage] verilirse belgenin sonuna ıslak imza görüntüsü eklenir.
  static Future<Uint8List> buildPdfBytes({
    required String title,
    required String content,
    String? subtitle,
    PdfPageFormat? format,
    Uint8List? signatureImage,
  }) async {
    final doc = await _createDocument();
    final pageFormat = format ?? PdfPageFormat.a4;

    pw.TextStyle baseStyle(double size, {bool bold = false}) {
      return pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(48),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('OfficialAI', style: baseStyle(13, bold: true)),
            pw.SizedBox(height: 2),
            pw.Text(title, style: baseStyle(20, bold: true)),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(subtitle, style: baseStyle(12)),
            ],
            pw.SizedBox(height: 12),
            pw.Container(height: 1.2, color: PdfColors.grey400),
            pw.SizedBox(height: 14),
          ],
        ),
        build: (ctx) => [
          pw.Text(content, style: baseStyle(10.5)),
          if (signatureImage != null && signatureImage.isNotEmpty) ...[
            pw.SizedBox(height: 28),
            pw.Text('İMZA', style: baseStyle(10.5, bold: true)),
            pw.SizedBox(height: 8),
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Image(
                pw.MemoryImage(signatureImage),
                height: 90,
                fit: pw.BoxFit.contain,
              ),
            ),
          ],
        ],
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text('Sayfa ${ctx.pageNumber}/${ctx.pagesCount}', style: baseStyle(9)),
        ),
      ),
    );

    return doc.save();
  }

  static String _safeFileName(String input) {
    final safe = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ğüşıöç\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return safe.isEmpty
        ? 'officialai_document'
        : safe.substring(0, safe.length > 60 ? 60 : safe.length);
  }

  static String _stamp() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  /// Belge için kullanıcı dostu, güvenli bir dosya adı üretir.
  static String buildFileName({
    required String title,
    String documentType = 'document',
  }) {
    return 'officialai_${documentType}_${_safeFileName(title)}_${_stamp()}.pdf';
  }

  /// Belgeyi PDF olarak paylaşır/dışa aktarır (indirme, kaydetme, paylaşma).
  static Future<void> exportAndShare({
    required String title,
    required String content,
    String? subtitle,
    String? shareSubject,
    String documentType = 'document',
    PdfPageFormat? pageFormat,
    Uint8List? signatureImage,
  }) async {
    final bytes = await buildPdfBytes(
      title: title,
      content: content,
      subtitle: subtitle,
      format: pageFormat,
      signatureImage: signatureImage,
    );

    final fileName = buildFileName(title: title, documentType: documentType);

    try {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (_) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }
  }

  /// Hazır PDF baytlarını paylaşır/dışa aktarır.
  static Future<void> sharePdfBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (_) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }
  }

  /// Belgeyi önizler (yazdırma/paylaşma ekranını açar).
  static Future<void> previewPdf({
    required String title,
    required String content,
    String? subtitle,
    PdfPageFormat? pageFormat,
  }) async {
    final bytes = await buildPdfBytes(
      title: title,
      content: content,
      subtitle: subtitle,
      format: pageFormat,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  /// Belge türüne göre uygun alt başlıkla dışa aktarır.
  /// Dilekçe, e-posta, CV ve belge analizi çıktıları için ortak yol.
  static Future<void> exportDocument({
    required String type,
    required String title,
    required String content,
  }) {
    final label = _typeLabels[type] ?? 'Belge';
    return exportAndShare(
      title: title.isEmpty ? label : title,
      subtitle: 'OfficialAI • $label',
      content: content,
      documentType: type.isEmpty ? 'document' : type,
      shareSubject: title.isEmpty ? label : title,
    );
  }

  static const Map<String, String> _typeLabels = {
    'petition': 'Dilekçe / Başvuru',
    'email': 'E-posta',
    'cv': 'Özgeçmiş (CV)',
    'ocr': 'Belge Analizi',
  };
}
