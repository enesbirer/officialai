import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/pdf_export_utils.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/ai_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';

// Kategori alan tanımı yoksa kullanılacak genel alanlar.
const List<Map<String, dynamic>> _genericFields = [
  {'key': 'muhatap_kurum', 'label': 'Muhatap Kurum / Kişi', 'required': true, 'type': 'text'},
  {'key': 'basvuru_nedeni', 'label': 'Başvuru Nedeni / Konu', 'required': true, 'type': 'text'},
  {'key': 'olay_ve_gerekce', 'label': 'Olayın Açıklaması ve Gerekçesi', 'required': true, 'type': 'longtext'},
  {'key': 'talep', 'label': 'İstediğiniz Sonuç / Talepleriniz', 'required': true, 'type': 'longtext'},
  {'key': 'ad_soyad', 'label': 'Ad Soyad', 'required': true, 'type': 'text'},
  {'key': 'tc_kimlik', 'label': 'T.C. Kimlik Numarası', 'required': true, 'type': 'text'},
  {'key': 'adres', 'label': 'Adresiniz', 'required': true, 'type': 'longtext'},
  {'key': 'telefon', 'label': 'Telefon Numaranız', 'required': false, 'type': 'text'},
  {'key': 'eposta', 'label': 'E-posta Adresiniz', 'required': false, 'type': 'email'},
];

enum _FieldGroup { personal, institution, subject, request }

class _FieldDef {
  final String key;
  final String label;
  final bool required;
  final String type;
  const _FieldDef({
    required this.key,
    required this.label,
    required this.required,
    required this.type,
  });

  factory _FieldDef.fromJson(Map f) => _FieldDef(
        key: f['key'].toString(),
        label: (f['label'] ?? f['key']).toString(),
        required: f['required'] == true,
        type: (f['type'] ?? 'text').toString(),
      );
}

class _WizardStep {
  final String title;
  final String subtitle;
  final List<_FieldDef> fields;
  const _WizardStep({required this.title, required this.subtitle, required this.fields});
}

class PetitionScreen extends ConsumerStatefulWidget {
  const PetitionScreen({super.key});

  @override
  ConsumerState<PetitionScreen> createState() => _PetitionScreenState();
}

class _PetitionScreenState extends ConsumerState<PetitionScreen> {
  // 0 = kategori seçimi, 1..N = alan adımları, N+1 = özet/onay
  int _stepIndex = 0;
  Map<String, dynamic>? _selectedCat;
  List<_WizardStep> _steps = const [];

  final Map<String, TextEditingController> _ctrls = {};
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scroll = ScrollController();

  Map<String, dynamic>? _result;
  String _resultTitle = '';
  final TextEditingController _resultCtrl = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _scroll.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  bool get _isSummary => _selectedCat != null && _stepIndex == _steps.length + 1;
  int get _totalSteps => _steps.length + 2; // + kategori + özet

  _FieldGroup _groupOf(String key) {
    final k = key.toLowerCase();
    if (RegExp(r'ad_soyad|adsoyad|tc_kimlik|kimlik|tckn|telefon|eposta|e-?posta|adres|veli|velayet|davaci|hasta|basvuran|ogrenci_no|protokol_no|siparis_no')
        .hasMatch(k)) {
      return _FieldGroup.personal;
    }
    if (RegExp(r'muhatap|kurum|kurulus|okul|belediye|mahkeme|noter|isveren|satici|firma|davali|hastane')
        .hasMatch(k)) {
      return _FieldGroup.institution;
    }
    if (RegExp(r'talep|istenen|istediginiz|sonuc|dava_talebi|duzeltilmesi|hukuki_dayanak|kanit|sunulacak|sunulan|kanitlar|vekil|tazminat')
        .hasMatch(k)) {
      return _FieldGroup.request;
    }
    return _FieldGroup.subject;
  }

  List<_WizardStep> _buildSteps(List<Map<String, dynamic>> rawFields) {
    final fields = rawFields.map(_FieldDef.fromJson).toList();
    if (fields.isEmpty) return const [];

    final personal = <_FieldDef>[];
    final institution = <_FieldDef>[];
    final subject = <_FieldDef>[];
    final request = <_FieldDef>[];

    for (final f in fields) {
      switch (_groupOf(f.key)) {
        case _FieldGroup.personal:
          personal.add(f);
          break;
        case _FieldGroup.institution:
          institution.add(f);
          break;
        case _FieldGroup.request:
          request.add(f);
          break;
        case _FieldGroup.subject:
          subject.add(f);
          break;
      }
    }

    return [
      if (personal.isNotEmpty)
        _WizardStep(
          title: 'Kişisel Bilgiler',
          subtitle: 'Kimlik ve iletişim bilgileriniz',
          fields: personal,
        ),
      if (institution.isNotEmpty)
        _WizardStep(
          title: 'Muhatap / Kurum',
          subtitle: 'Dilekçenin hitap edeceği kurum veya kişi',
          fields: institution,
        ),
      if (subject.isNotEmpty)
        _WizardStep(
          title: 'Konu ve Ayrıntılar',
          subtitle: 'Olayın ve konunun açıklaması',
          fields: subject,
        ),
      if (request.isNotEmpty)
        _WizardStep(
          title: 'Talep ve Dayanak',
          subtitle: 'İstediğiniz sonuç ve dayanaklar',
          fields: request,
        ),
    ];
  }

  void _selectCat(Map<String, dynamic> cat) {
    final rawFields = (cat['fields'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final effective = rawFields.isEmpty ? _genericFields : rawFields;
    setState(() {
      _selectedCat = cat;
      _steps = _buildSteps(effective);
      _stepIndex = 1;
      _errorText = null;
      _ctrls.clear();
      for (final f in effective) {
        _ctrls[f['key'].toString()] = TextEditingController();
      }
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(0,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _next() {
    if (_stepIndex >= 1 && _stepIndex <= _steps.length) {
      if (!(_formKey.currentState?.validate() ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen zorunlu alanları doldurun.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    setState(() {
      _errorText = null;
      _stepIndex++;
    });
    _scrollToTop();
  }

  void _handleBack() {
    if (_result != null) {
      setState(() {
        _result = null;
        _stepIndex = _steps.length + 1;
      });
      _scrollToTop();
      return;
    }
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
      _scrollToTop();
      return;
    }
    AppNavigation.back(context);
  }

  Future<void> _generate() async {
    if (_selectedCat == null) return;
    final answers = <String, dynamic>{};
    _ctrls.forEach((k, v) => answers[k] = v.text.trim());

    setState(() => _errorText = null);
    try {
      final catId = _selectedCat!['id'].toString();
      final res = await ref.read(petitionGenerationProvider.notifier).generate(
            categoryId: catId,
            answers: answers,
          );
      if (!mounted) return;
      setState(() {
        _result = res;
        _resultTitle = (res['title']?.toString() ?? '').trim();
        _resultCtrl.text = res['content']?.toString() ?? '';
      });
      _scrollToTop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = friendlyErrorMessage(e, action: 'Dilekçe oluşturma');
      });
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _resultCtrl.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dilekçe panoya kopyalandı'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _share() async {
    await Share.share(_resultCtrl.text, subject: 'OfficialAI Dilekçe');
  }

  Future<void> _exportPdf() async {
    final text = _resultCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      await PdfExportUtils.exportAndShare(
        title: _resultTitle.isEmpty ? 'Resmi Dilekçe' : _resultTitle,
        subtitle: 'OfficialAI • Dilekçe / Başvuru',
        content: text,
        documentType: 'petition',
        shareSubject: _resultTitle.isEmpty ? 'OfficialAI Dilekçe' : _resultTitle,
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

  Future<void> _favorite() async {
    final docId = _result?['petitionId']?.toString() ?? '';
    if (docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dilekçe sunucuda kaydedilmeden favorilere eklenemez'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await ref.read(favoriteToggleProvider((documentId: docId, documentType: 'petition')).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilere eklendi / çıkarıldı'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyErrorMessage(e, action: 'Favori işlemi')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _restart() {
    setState(() {
      _stepIndex = 0;
      _selectedCat = null;
      _steps = const [];
      _result = null;
      _resultTitle = '';
      _errorText = null;
      _resultCtrl.clear();
      _ctrls.forEach((_, c) => c.dispose());
      _ctrls.clear();
      ref.read(petitionGenerationProvider.notifier).reset();
    });
    _scrollToTop();
  }

  IconData _iconFor(Map cat) {
    final s = '${cat['icon'] ?? ''} ${cat['name'] ?? ''}'.toLowerCase();
    if (s.contains('trafik') || s.contains('ceza') || s.contains('car')) {
      return Icons.directions_car_outlined;
    }
    if (s.contains('kira') || s.contains('tapu') || s.contains('home')) {
      return Icons.home_outlined;
    }
    if (s.contains('eğitim') || s.contains('ogren') || s.contains('öğren') || s.contains('school')) {
      return Icons.school_outlined;
    }
    if (s.contains('sağlık') || s.contains('hasta') || s.contains('hastane')) {
      return Icons.local_hospital_outlined;
    }
    if (s.contains('vergi') || s.contains('sgk')) return Icons.receipt_long_outlined;
    if (s.contains('tüketici') || s.contains('şikayet')) return Icons.shopping_bag_outlined;
    if (s.contains('belediye')) return Icons.location_city_outlined;
    if (s.contains('dava') || s.contains('mahkeme') || s.contains('hukuk')) return Icons.gavel_outlined;
    if (s.contains('iş') || s.contains('isveren') || s.contains('iade') || s.contains('work')) {
      return Icons.work_outline_rounded;
    }
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cats = ref.watch(categoriesProvider);
    final generating = ref.watch(petitionGenerationProvider).isLoading;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return PopScope(
      canPop: _result == null && _stepIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
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
          leading: IconButton(
            onPressed: _handleBack,
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
          ),
          title: Text(
            'Dilekçe Üretici',
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 17,
              letterSpacing: -0.2,
            ),
          ),
          centerTitle: true,
        ),
        body: isDark
            ? GlassBackground.iceDarkGradient(child: _body(text, sub, cats, generating, isDark))
            : GlassBackground.iceLightGradient(child: _body(text, sub, cats, generating, isDark)),
      ),
    );
  }

  Widget _body(Color text, Color sub, AsyncValue<List<Map>> cats, bool generating, bool isDark) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            if (_result == null) ...[
              _progressHeader(text, sub, isDark),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                child: _result != null
                    ? _resultBody(text, sub, generating)
                    : _stepIndex == 0
                        ? _catList(cats, text, sub)
                        : _isSummary
                            ? _summaryBody(text, sub, generating)
                            : _fieldStepBody(text, sub, isDark),
              ),
            ),
            if (_result == null && _stepIndex > 0) ...[
              const SizedBox(height: 12),
              _navButtons(generating, isDark),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- İlerleme göstergesi ----------
  Widget _progressHeader(Color text, Color sub, bool isDark) {
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    if (_selectedCat == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('DİLEKÇE TÜRÜ', sub),
          Text(
            'Hangi konuda dilekçe oluşturmak istiyorsunuz?',
            style: TextStyle(color: sub, fontSize: 14),
          ),
        ],
      );
    }

    final current = _stepIndex + 1;
    final total = _totalSteps;
    final label = _stepIndex == 0
        ? 'Kategori'
        : _isSummary
            ? 'Özet ve Onay'
            : _steps[_stepIndex - 1].title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adım $current / $total',
              style: TextStyle(color: sub, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 6,
            backgroundColor: sub.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }

  // ---------- Adım: kategori ----------
  Widget _catList(AsyncValue<List<Map>> cats, Color text, Color sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    if (cats.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('KATEGORİ SEÇİN', sub),
          const SizedBox(height: 8),
          ...List.generate(5, (_) => _catSkeleton(sub)),
        ],
      );
    }

    if (cats.hasError && !cats.isLoading) {
      return _centeredState(
        icon: Icons.cloud_off_outlined,
        title: 'Kategoriler yüklenemedi',
        message: friendlyErrorMessage(cats.error!, action: 'Kategori listesi'),
        actionLabel: 'Tekrar Dene',
        onAction: () => ref.invalidate(categoriesProvider),
        sub: sub,
      );
    }

    final list = (cats.valueOrNull ?? const []).cast<Map<String, dynamic>>();
    if (list.isEmpty) {
      return _centeredState(
        icon: Icons.inbox_outlined,
        title: 'Kategori bulunamadı',
        message: 'Şu anda kullanılabilir dilekçe türü yok. Lütfen daha sonra tekrar deneyin.',
        sub: sub,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('KATEGORİ SEÇİN', sub),
        const SizedBox(height: 4),
        ...list.map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassContainer(
              borderRadius: 14,
              onTap: () => _selectCat(c),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(_iconFor(c), color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['name']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c['description']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: sub, fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: sub, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _catSkeleton(Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        borderRadius: 14,
        padding: const EdgeInsets.all(14),
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
                    width: 120,
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
    );
  }

  // ---------- Adım: alanlar ----------
  Widget _fieldStepBody(Color text, Color sub, bool isDark) {
    final step = _steps[_stepIndex - 1];
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(step.title.toUpperCase(), sub),
          Text(
            step.subtitle,
            style: TextStyle(color: sub, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...step.fields.map(_fieldWidget).toList(),
        ],
      ),
    );
  }

  Widget _fieldWidget(_FieldDef f) {
    final ctrl = _ctrls[f.key] ??= TextEditingController();
    final isLong = f.type == 'longtext';
    final isEmail = f.type == 'email';
    final isPhone = f.key.toLowerCase().contains('telefon');
    final isTc = f.key.toLowerCase().contains('tc_kimlik') || f.key.toLowerCase().contains('kimlik');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomTextField(
        controller: ctrl,
        label: f.required ? '${f.label} *' : f.label,
        hint: f.label,
        prefixIcon: isLong
            ? Icons.notes_rounded
            : isEmail
                ? Icons.alternate_email_rounded
                : isPhone
                    ? Icons.phone_outlined
                    : isTc
                        ? Icons.badge_outlined
                        : Icons.edit_note_rounded,
        maxLines: isLong ? 5 : 1,
        minLines: isLong ? 3 : 1,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhone
                ? TextInputType.phone
                : isLong
                    ? TextInputType.multiline
                    : TextInputType.text,
        textInputAction: isLong ? TextInputAction.newline : TextInputAction.next,
        validator: (v) {
          final value = v?.trim() ?? '';
          if (f.required && value.isEmpty) {
            return '${f.label} alanı zorunludur';
          }
          if (isEmail && value.isNotEmpty && !AppConfig.emailRegex.hasMatch(value)) {
            return 'Geçerli bir e-posta adresi girin';
          }
          if (isTc && value.isNotEmpty && !RegExp(r'^\d{11}$').hasMatch(value)) {
            return 'T.C. kimlik numarası 11 haneli olmalıdır';
          }
          if (isPhone && value.isNotEmpty && value.replaceAll(RegExp(r'\D'), '').length < 10) {
            return 'Geçerli bir telefon numarası girin';
          }
          return null;
        },
      ),
    );
  }

  // ---------- Adım: özet ve onay ----------
  Widget _summaryBody(Color text, Color sub, bool generating) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('ÖZET VE ONAY', sub),
        Text(
          'Bilgileri kontrol edin. Düzeltmek için ilgili adıma dokunun.',
          style: TextStyle(color: sub, fontSize: 14),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _steps.length; i++) ...[
          _summaryCard(_steps[i], i + 1, text, sub, accent),
          const SizedBox(height: 12),
        ],
        if (_errorText != null) ...[
          const SizedBox(height: 4),
          _errorBanner(_errorText!),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          text: 'Dilekçeyi Oluştur',
          icon: Icons.auto_awesome_rounded,
          loading: generating,
          onPressed: generating ? null : _generate,
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Oluşturma birkaç saniye sürebilir.',
            style: TextStyle(color: sub, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(_WizardStep step, int stepNo, Color text, Color sub, Color accent) {
    return GlassContainer(
      borderRadius: 14,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => setState(() => _stepIndex = stepNo),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_outlined, size: 16, color: accent),
                  const SizedBox(width: 4),
                  Text('Düzenle', style: TextStyle(color: accent, fontSize: 13)),
                ],
              ),
            ),
          ),
          const GlassDivider(height: 1, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(
              children: [
                for (final f in step.fields) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            f.label,
                            style: TextStyle(color: sub, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _valueFor(f.key),
                            style: TextStyle(color: text, fontSize: 14, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _valueFor(String key) {
    final value = _ctrls[key]?.text.trim() ?? '';
    if (value.isEmpty) return '—';
    return value;
  }

  Widget _errorBanner(String message) {
    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Alt butonlar ----------
  Widget _navButtons(bool generating, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: 'Geri',
            icon: Icons.arrow_back_rounded,
            variant: PrimaryButtonVariant.glass,
            onPressed: generating ? null : _handleBack,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            text: _isSummary ? 'Dilekçeyi Oluştur' : 'Devam',
            icon: _isSummary ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
            loading: generating,
            onPressed: generating ? null : (_isSummary ? _generate : _next),
          ),
        ),
      ],
    );
  }

  // ---------- Sonuç ----------
  Widget _resultBody(Color text, Color sub, bool generating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Dilekçeniz hazır',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Düzenleyebilir, kopyalayabilir, PDF olarak indirebilir veya paylaşabilirsiniz.',
          style: TextStyle(color: sub, fontSize: 13),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: 14,
          padding: const EdgeInsets.all(12),
          child: CustomTextField(
            controller: _resultCtrl,
            maxLines: 25,
            minLines: 18,
            expands: false,
            prefixIcon: null,
            label: 'Dilekçe İçeriği',
            style: TextStyle(color: text, fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Kopyala',
                icon: Icons.copy_all_rounded,
                variant: PrimaryButtonVariant.glass,
                onPressed: _copy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Favori',
                icon: Icons.favorite_border_rounded,
                variant: PrimaryButtonVariant.outlined,
                onPressed: _favorite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'PDF İndir',
                icon: Icons.picture_as_pdf_outlined,
                variant: PrimaryButtonVariant.glass,
                onPressed: _exportPdf,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Paylaş',
                icon: Icons.ios_share_rounded,
                onPressed: _share,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Yeni Dilekçe Oluştur',
          icon: Icons.refresh_rounded,
          variant: PrimaryButtonVariant.glass,
          loading: generating,
          onPressed: _restart,
        ),
      ],
    );
  }

  // ---------- Ortak: bölüm başlığı ----------
  Widget _sectionHeader(String title, Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: sub,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _centeredState({
    required IconData icon,
    required String title,
    required String message,
    required Color sub,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 48, color: accent),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: text),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: sub, fontSize: 14, height: 1.4),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                text: actionLabel,
                icon: Icons.refresh_rounded,
                variant: PrimaryButtonVariant.outlined,
                onPressed: onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
