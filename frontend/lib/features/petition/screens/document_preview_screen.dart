import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/pdf_export_utils.dart';
import '../../../widgets/primary_button.dart';
import '../widgets/document_email_dialog.dart';
import '../widgets/signature_pad_sheet.dart';

/// Oluşturulan belgeyi uygulama içinde PDF olarak gösterir; kullanıcı
/// imzalayabilir, indirebilir/paylaşabilir ve e-posta ile gönderebilir.
class DocumentPreviewScreen extends ConsumerStatefulWidget {
  const DocumentPreviewScreen({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    this.documentType = 'document',
    this.startWithSignature = false,
  });

  final String title;
  final String content;
  final String? subtitle;
  final String documentType;

  /// Ekran açılır açılmaz imza çizim alanını açar.
  final bool startWithSignature;

  @override
  ConsumerState<DocumentPreviewScreen> createState() =>
      _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends ConsumerState<DocumentPreviewScreen> {
  Uint8List? _signature;
  bool _busy = false;
  int _pdfVersion = 0;

  String get _displayTitle => widget.title.trim().isEmpty ? 'Belge' : widget.title.trim();

  @override
  void initState() {
    super.initState();
    if (widget.startWithSignature) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openSignature());
    }
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) {
    return PdfExportUtils.buildPdfBytes(
      title: _displayTitle,
      content: widget.content,
      subtitle: widget.subtitle,
      format: format,
      signatureImage: _signature,
    );
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : null,
      ),
    );
  }

  Future<void> _openSignature() async {
    final bytes = await SignaturePadSheet.show(context);
    if (!mounted || bytes == null) return;
    setState(() {
      _signature = bytes;
      _pdfVersion++;
    });
    _snack('İmza belgeye eklendi', error: false);
  }

  void _removeSignature() {
    setState(() {
      _signature = null;
      _pdfVersion++;
    });
  }

  Future<void> _download() async {
    setState(() => _busy = true);
    try {
      final bytes = await _buildPdf(PdfPageFormat.a4);
      await PdfExportUtils.sharePdfBytes(
        bytes: bytes,
        fileName: PdfExportUtils.buildFileName(
          title: _displayTitle,
          documentType: widget.documentType,
        ),
      );
    } catch (e) {
      _snack(friendlyErrorMessage(e, action: 'PDF oluşturma'), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendEmail() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _buildPdf(PdfPageFormat.a4);
      if (!mounted) return;
      setState(() => _busy = false);
      await showDocumentEmailDialog(
        context: context,
        ref: ref,
        title: _displayTitle,
        content: widget.content,
        pdfBytes: bytes,
      );
    } catch (e) {
      _snack(friendlyErrorMessage(e, action: 'E-posta gönderme'), error: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgStart : AppColors.lightBgStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => AppNavigation.back(context),
        ),
        title: Text(
          'PDF Önizleme',
          style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_signature != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bu belge imzalandı',
                      style: TextStyle(color: sub, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: PdfPreview(
              key: ValueKey(_pdfVersion),
              build: _buildPdf,
              initialPageFormat: PdfPageFormat.a4,
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              useActions: false,
              pdfFileName: PdfExportUtils.buildFileName(
                title: _displayTitle,
                documentType: widget.documentType,
              ),
              loadingWidget: const Center(child: CircularProgressIndicator()),
              onError: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    friendlyErrorMessage(error, action: 'PDF görüntüleme'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: sub, fontSize: 14, height: 1.4),
                  ),
                ),
              ),
            ),
          ),
          GlassContainer(
            borderRadius: 20,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: _signature == null ? 'İmzala' : 'İmzayı Kaldır',
                        icon: _signature == null
                            ? Icons.draw_outlined
                            : Icons.delete_outline_rounded,
                        variant: PrimaryButtonVariant.glass,
                        onPressed: _busy
                            ? null
                            : (_signature == null ? _openSignature : _removeSignature),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'İndir / Paylaş',
                        icon: Icons.picture_as_pdf_outlined,
                        variant: PrimaryButtonVariant.glass,
                        loading: _busy,
                        onPressed: _busy ? null : _download,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'E-posta Olarak Gönder',
                  icon: Icons.mail_outline_rounded,
                  variant: PrimaryButtonVariant.outlined,
                  loading: _busy,
                  onPressed: _busy ? null : _sendEmail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
