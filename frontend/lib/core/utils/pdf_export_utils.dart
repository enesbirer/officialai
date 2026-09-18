import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportUtils {
  static Future<Uint8List> _buildPdfBytes({
    required String title,
    required String body,
    String? subtitle,
    PdfPageFormat? format,
  }) async {
    final doc = pw.Document();
    final pageFormat = format ?? PdfPageFormat.a4;

    pw.TextStyle baseStyle(double size, {bool bold = false}) {
      return pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );
    }

    final headerStyle = baseStyle(20, bold: true);
    final subtitleStyle = baseStyle(12);
    final bodyStyle = baseStyle(10.5);

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(48),
        header: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OfficialAI', style: baseStyle(13, bold: true)),
              pw.SizedBox(height: 2),
              pw.Text(title, style: headerStyle),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(subtitle, style: subtitleStyle),
              ],
              pw.SizedBox(height: 12),
              pw.Container(height: 1.2, color: PdfColors.grey400),
              pw.SizedBox(height: 14),
            ],
          );
        },
        build: (ctx) => [
          pw.Text(body, style: bodyStyle),
        ],
        footer: (ctx) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'Sayfa ${ctx.pageNumber}/${ctx.pagesCount}',
              style: baseStyle(9),
            ),
          );
        },
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

  static Future<void> exportAndShare({
    required String title,
    required String content,
    String? subtitle,
    String? shareSubject,
    String documentType = 'document',
    PdfPageFormat? pageFormat,
  }) async {
    final bytes = await _buildPdfBytes(
      title: title,
      body: content,
      subtitle: subtitle,
      format: pageFormat,
    );

    final now = DateTime.now();
    final stamp = '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';

    final fileName =
        'officialai_${documentType}_${_safeFileName(title)}_$stamp.pdf';

    try {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (_) {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }
  }

  static Future<void> previewPdf({
    required String title,
    required String content,
    String? subtitle,
    PdfPageFormat? pageFormat,
  }) async {
    final bytes = await _buildPdfBytes(
      title: title,
      body: content,
      subtitle: subtitle,
      format: pageFormat,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
}
