import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
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
      setState(() {
        _hasResult = true;
        final demo = _demoEmail(type, tone, lang);
        _resultSubjectCtrl.text = demo.$1;
        _resultBodyCtrl.text = demo.$2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sunucu yanıtı alınamadı, demo gösteriliyor: ${e.toString().characters.take(50)}'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  (String, String) _demoEmail(String type, String tone, String lang) {
    final isTr = lang == 'Türkçe';
    final greeting = isTr
        ? (_toneIdx == 1 ? 'Merhaba,' : (isTr && _typeIdx == 0 ? 'Sayın Yetkili,' : 'Merhaba,'))
        : (_toneIdx == 1 ? 'Hi there,' : 'Dear Sir/Madam,');
    final signoff =
        isTr ? (_typeIdx == 0 ? 'Saygılarımla,' : 'İyi günler dilerim,') : 'Best regards,';
    final sender =
        _senderCtrl.text.trim().isNotEmpty ? _senderCtrl.text.trim() : (isTr ? '[Ad Soyad]' : '[Your Name]');
    final ctx = _contextCtrl.text.trim().isNotEmpty
        ? _contextCtrl.text.trim()
        : (isTr
            ? '[E-postanın konusunu ve amacını buraya yazın - Bu metin sizin bağlamınıza göre AI tarafından otomatik olarak genişletilecektir.]'
            : '[Write context here - this text will be expanded by AI based on your context]');
    final subject = isTr
        ? '$type Konulu: ${ctx.length > 50 ? '${ctx.substring(0, 50)}...' : ctx}'
        : '$type: ${ctx.length > 60 ? '${ctx.substring(0, 60)}...' : ctx}';
    final body = '''$greeting

$ctx

${tone == 'Kısa ve Net' ? (isTr ? 'Özetle, konuyu kısa ve net şekilde iletmek istedim.' : 'I wanted to communicate this briefly and clearly.') : tone == 'İkna Edici' ? (isTr ? 'Bu konuda sizlerden gerekli hassasiyeti göstererek yardımcı olmanızı rica ederim. Konunun takipçisi olacağım.' : 'I kindly request you to consider this matter and assist. I will follow up accordingly.') : (isTr ? 'Konunun değerlendirilmesini ve en kısa sürede geri dönüş yapılmasını temenni ederim.' : 'I kindly request your consideration and a prompt reply.')}

$signoff
$sender
''';
    return (subject, body);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: '${_resultSubjectCtrl.text}\n\n${_resultBodyCtrl.text}'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta panoya kopyalandı ✓'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(
        title: const Text('E-posta Üretici'),
        leading: IconButton(onPressed: () => context.go('/dashboard'), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [
          IconButton(onPressed: () => setState(() {
            _hasResult = false;
            _contextCtrl.clear();
            _recipientCtrl.clear();
            _senderCtrl.clear();
            _resultSubjectCtrl.clear();
            _resultBodyCtrl.clear();
            ref.read(emailGenerationProvider.notifier).reset();
          }), icon: const Icon(Icons.refresh_rounded)),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: _hasResult ? _resultSection(text, sub, loading) : _formSection(text, sub, loading),
      ),
    );
  }

  Widget _chips(List<String> options, int selected, ValueChanged<int> onTap, Color text) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final sel = i == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: sel ? AppColors.icePrimary.withAlpha(85) : AppColors.darkGlass,
              border: Border.all(
                color: sel ? AppColors.icePrimary : AppColors.darkBorder.withAlpha(140),
                width: sel ? 1.4 : 0.8,
              ),
            ),
            child: Text(
              options[i],
              style: TextStyle(
                color: sel ? Colors.white : text,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
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
          _headerCard('E-posta Tipi', 'E-postan amacını seçin', text, sub),
          _chips(_types, _typeIdx, (i) => setState(() => _typeIdx = i), text),
          const SizedBox(height: 20),
          _headerCard('Ton', 'İletişim tarzını seçin', text, sub),
          _chips(_tones, _toneIdx, (i) => setState(() => _toneIdx = i), text),
          const SizedBox(height: 20),
          _headerCard('Dil', 'Hedef dili seçin', text, sub),
          _chips(_languages, _langIdx, (i) => setState(() => _langIdx = i), text),
          const SizedBox(height: 24),
          GlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                CustomTextField(
                  controller: _recipientCtrl,
                  label: 'Alıcı (opsiyonel)',
                  hint: 'alici@ornek.com',
                  prefixIcon: Icons.person_search_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _senderCtrl,
                  label: 'Gönderen Adı (opsiyonel)',
                  hint: 'Ahmet Yılmaz',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
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
          PrimaryButton(text: 'E-posta Oluştur', icon: Icons.auto_awesome_rounded, loading: loading, onPressed: _generate),
        ],
      ),
    );
  }

  Widget _headerCard(String title, String subtitle, Color text, Color sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: text)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: sub, fontSize: 12)),
      ]),
    );
  }

  Widget _resultSection(Color text, Color sub, bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 28),
              const SizedBox(width: 10),
              Text('E-postanız Hazır!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: text)),
            ],
          ),
        ),
        GlassContainer(
          borderRadius: 22,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              CustomTextField(
                controller: _resultSubjectCtrl,
                label: 'Konu',
                prefixIcon: Icons.short_text_rounded,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _resultBodyCtrl,
                label: 'E-posta Gövdesi',
                prefixIcon: null,
                minLines: 16,
                maxLines: 30,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: PrimaryButton(text: 'Kopyala', icon: Icons.copy_all_rounded, variant: PrimaryButtonVariant.glass, onPressed: _copy)),
            const SizedBox(width: 10),
            Expanded(child: PrimaryButton(text: 'Favori', icon: Icons.favorite_border_rounded, variant: PrimaryButtonVariant.outlined, onPressed: _fav)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: PrimaryButton(text: 'PDF', icon: Icons.picture_as_pdf_outlined, variant: PrimaryButtonVariant.glass, onPressed: _exportPdf)),
            const SizedBox(width: 10),
            Expanded(child: PrimaryButton(text: 'Paylaş', icon: Icons.share_rounded, onPressed: _share)),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Yeni E-posta',
          icon: Icons.edit_note_rounded,
          variant: PrimaryButtonVariant.glass,
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
