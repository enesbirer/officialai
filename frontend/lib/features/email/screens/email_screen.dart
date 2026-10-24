import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/pdf_export_utils.dart';
import '../../../providers/ai_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';

const List<String> _types = ['Resmi', 'İş', 'Özel', 'Akademik', 'Başvuru'];
const List<String> _tones = ['Resmi', 'Dost Canlısı', 'Kısa ve Net', 'İkna Edici'];
const List<String> _languages = ['Türkçe', 'İngilizce'];

class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  int _typeIdx = 0;
  int _toneIdx = 0;
  int _langIdx = 0;

  final _recipientCtrl = TextEditingController();
  final _senderCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  final _resultSubjectCtrl = TextEditingController();
  final _resultBodyCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _hasResult = false;

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _senderCtrl.dispose();
    _contextCtrl.dispose();
    _resultSubjectCtrl.dispose();
    _resultBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final type = _types[_typeIdx];
    final tone = _tones[_toneIdx];
    final lang = _languages[_langIdx];
    try {
      final r = await ref.read(emailGenerationProvider.notifier).generate(
            type: type,
            tone: tone,
            language: lang,
            context: _contextCtrl.text.trim(),
            recipient: _recipientCtrl.text.trim().isEmpty ? null : _recipientCtrl.text.trim(),
            senderName: _senderCtrl.text.trim().isEmpty ? null : _senderCtrl.text.trim(),
          );
      if (mounted) {
        setState(() {
          _hasResult = true;
          _resultSubjectCtrl.text = r['subject']?.toString() ?? '';
          _resultBodyCtrl.text = r['content']?.toString() ?? '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyErrorMessage(e, action: 'E-posta oluşturma')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: '${_resultSubjectCtrl.text}\n\n${_resultBodyCtrl.text}'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta panoya kopyalandı'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _share() async {
    await Share.share('${_resultSubjectCtrl.text}\n\n${_resultBodyCtrl.text}', subject: _resultSubjectCtrl.text);
  }

  Future<void> _exportPdf() async {
    final subject = _resultSubjectCtrl.text.trim();
    final body = _resultBodyCtrl.text.trim();
    final combined = body.isEmpty ? '' : (subject.isEmpty ? body : '$subject\n\n$body');
    if (combined.isEmpty) return;
    try {
      await PdfExportUtils.exportAndShare(
        title: subject.isEmpty ? 'Resmi E-posta' : subject,
        subtitle: 'OfficialAI • E-posta Taslağı',
        content: combined,
        documentType: 'email',
        shareSubject: subject.isEmpty ? 'OfficialAI E-posta' : subject,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF oluşturulamadı, lütfen tekrar deneyin')),
        );
      }
    }
  }

  Future<void> _fav() async {
    final s = ref.read(emailGenerationProvider);
    final docId = s.valueOrNull?['emailId']?.toString() ?? '';
    if (docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sunucuda kaydedilmeden favorilere eklenemez'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    ref.read(favoriteToggleProvider((documentId: docId, documentType: 'email')));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final loading = ref.watch(emailGenerationProvider).isLoading;

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
          'E-posta Üretici',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: text,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => AppNavigation.back(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: text),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _hasResult = false;
              _contextCtrl.clear();
              _recipientCtrl.clear();
              _senderCtrl.clear();
              _resultSubjectCtrl.clear();
              _resultBodyCtrl.clear();
              ref.read(emailGenerationProvider.notifier).reset();
            }),
            icon: Icon(Icons.refresh_rounded, size: 22, color: text),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _body(text, sub, loading))
          : GlassBackground.iceLightGradient(child: _body(text, sub, loading)),
    );
  }

  Widget _body(Color text, Color sub, bool loading) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: _hasResult ? _resultSection(text, sub, loading) : _formSection(text, sub, loading),
      ),
    );
  }

  Widget _chips(List<String> options, int selected, ValueChanged<int> onTap, Color text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final fill = isDark ? AppColors.darkFill : AppColors.lightFill;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final sel = i == selected;
        return Semantics(
          button: true,
          selected: sel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: sel ? accent : fill,
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    color: sel ? Colors.white : text,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _formSection(Color text, Color sub, bool loading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard('E-posta Tipi', 'E-postanın amacını seçin', text, sub),
          _chips(_types, _typeIdx, (i) => setState(() => _typeIdx = i), text),
          const SizedBox(height: 24),
          _headerCard('Ton', 'İletişim tarzını seçin', text, sub),
          _chips(_tones, _toneIdx, (i) => setState(() => _toneIdx = i), text),
          const SizedBox(height: 24),
          _headerCard('Dil', 'Hedef dili seçin', text, sub),
          _chips(_languages, _langIdx, (i) => setState(() => _langIdx = i), text),
          const SizedBox(height: 24),
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  controller: _recipientCtrl,
                  label: 'Alıcı (opsiyonel)',
                  hint: 'alici@ornek.com',
                  prefixIcon: Icons.person_search_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _senderCtrl,
                  label: 'Gönderen Adı (opsiyonel)',
                  hint: 'Ahmet Yılmaz',
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _contextCtrl,
                  label: 'Bağlam / Konu *',
                  hint: 'Ne hakkında e-posta yazmak istiyorsunuz? Detaylı anlatın...',
                  prefixIcon: Icons.edit_note_rounded,
                  maxLines: 8,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Bağlam gerekli';
                    if (v.trim().length < 10) return 'En az 10 karakter girin';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'E-posta Oluştur',
            icon: Icons.auto_awesome_rounded,
            loading: loading,
            borderRadius: 14,
            onPressed: _generate,
          ),
        ],
      ),
    );
  }

  Widget _headerCard(String title, String subtitle, Color text, Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: sub,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: sub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultSection(Color text, Color sub, bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'E-postanız Hazır',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
        ),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _resultSubjectCtrl,
                label: 'Konu',
                prefixIcon: Icons.short_text_rounded,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: text),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _resultBodyCtrl,
                label: 'E-posta Gövdesi',
                prefixIcon: null,
                minLines: 16,
                maxLines: 30,
                style: TextStyle(fontSize: 16, height: 1.5, color: text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Kopyala',
                icon: Icons.copy_all_rounded,
                variant: PrimaryButtonVariant.glass,
                borderRadius: 14,
                onPressed: _copy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Favori',
                icon: Icons.favorite_border_rounded,
                variant: PrimaryButtonVariant.outlined,
                borderRadius: 14,
                onPressed: _fav,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'PDF',
                icon: Icons.picture_as_pdf_outlined,
                variant: PrimaryButtonVariant.glass,
                borderRadius: 14,
                onPressed: _exportPdf,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Paylaş',
                icon: Icons.share_rounded,
                borderRadius: 14,
                onPressed: _share,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Yeni E-posta',
          icon: Icons.edit_note_rounded,
          variant: PrimaryButtonVariant.glass,
          borderRadius: 14,
          onPressed: loading
              ? null
              : () => setState(() {
                    _hasResult = false;
                    ref.read(emailGenerationProvider.notifier).reset();
                  }),
        ),
      ],
    );
  }
}
