import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pdf_export_utils.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/theme_provider.dart';

class CVScreen extends ConsumerStatefulWidget {
  const CVScreen({super.key});

  @override
  ConsumerState<CVScreen> createState() => _CVScreenState();
}

class _CVScreenState extends ConsumerState<CVScreen> {
  int _currentStep = 0;
  String? _selectedTemplateId;
  bool _hasResult = false;
  String _resultTitle = '';
  String _resultContent = '';
  String? _resultDocId;

  // Step 1 - Personal Info
  final _formKey1 = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  // Step 2 - Education (dynamic list)
  final List<Map<String, TextEditingController>> _education = [];

  // Step 3 - Experience (dynamic list)
  final List<Map<String, TextEditingController>> _experience = [];

  // Step 4 - Skills
  final List<String> _skills = [];
  final _skillCtrl = TextEditingController();
  final List<String> _languages = [];
  final _languageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addEducation();
    _addExperience();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _summaryCtrl.dispose();
    _linkedinCtrl.dispose();
    _skillCtrl.dispose();
    _languageCtrl.dispose();
    for (final e in _education) {
      for (final c in e.values) {
        c.dispose();
      }
    }
    for (final x in _experience) {
      for (final c in x.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addEducation() {
    _education.add({
      'school': TextEditingController(),
      'degree': TextEditingController(),
      'field': TextEditingController(),
      'start': TextEditingController(),
      'end': TextEditingController(),
      'gpa': TextEditingController(),
    });
  }

  void _removeEducation(int idx) {
    if (_education.length > 1) {
      for (final c in _education[idx].values) {
        c.dispose();
      }
      _education.removeAt(idx);
    }
  }

  void _addExperience() {
    _experience.add({
      'company': TextEditingController(),
      'position': TextEditingController(),
      'start': TextEditingController(),
      'end': TextEditingController(),
      'description': TextEditingController(),
    });
  }

  void _removeExperience(int idx) {
    if (_experience.length > 1) {
      for (final c in _experience[idx].values) {
        c.dispose();
      }
      _experience.removeAt(idx);
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _formKey1.currentState?.validate() ?? false;
    }
    return true;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
      }
    } else {
      _generateCV();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _generateCV() async {
    if (!_validateCurrentStep()) return;

    final personalInfo = {
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'summary': _summaryCtrl.text.trim(),
      'linkedin': _linkedinCtrl.text.trim(),
    };

    final education = _education.map((e) {
      return {
        'school': e['school']?.text.trim() ?? '',
        'degree': e['degree']?.text.trim() ?? '',
        'field': e['field']?.text.trim() ?? '',
        'start': e['start']?.text.trim() ?? '',
        'end': e['end']?.text.trim() ?? '',
        'gpa': e['gpa']?.text.trim() ?? '',
      };
    }).toList();

    final experience = _experience.map((x) {
      return {
        'company': x['company']?.text.trim() ?? '',
        'position': x['position']?.text.trim() ?? '',
        'start': x['start']?.text.trim() ?? '',
        'end': x['end']?.text.trim() ?? '',
        'description': x['description']?.text.trim() ?? '',
      };
    }).toList();

    final skills = [..._skills];
    if (_languages.isNotEmpty) {
      skills.add('Diller: ${_languages.join(', ')}');
    }

    final notifier = ref.read(cvGenerationProvider.notifier);
    try {
      final result = await notifier.generate(
        personalInfo: personalInfo,
        education: education,
        experience: experience,
        skills: skills,
        templateId: _selectedTemplateId,
      );
      setState(() {
        _hasResult = true;
        _resultTitle = (result['title'] as String?) ??
            '${personalInfo['firstName']} ${personalInfo['lastName']} - Özgeçmiş';
        _resultContent = (result['content'] as String?) ?? '';
        _resultDocId = result['documentId'] as String?;
      });
    } catch (_) {
      final demo = _demoCV(personalInfo, education, experience, skills);
      setState(() {
        _hasResult = true;
        _resultTitle = '${personalInfo['firstName'] ?? 'Ad'} ${personalInfo['lastName'] ?? 'Soyad'} - Özgeçmiş (Örnek)';
        _resultContent = demo;
        _resultDocId = null;
      });
    }
  }

  String _demoCV(
    Map<String, dynamic> p,
    List<Map<String, dynamic>> edu,
    List<Map<String, dynamic>> exp,
    List<String> sk,
  ) {
    final name = '${p['firstName'] ?? 'Ad Soyad'}';
    final contact = [
      if ((p['email'] as String?)?.isNotEmpty == true) '📧 ${p['email']}',
      if ((p['phone'] as String?)?.isNotEmpty == true) '📱 ${p['phone']}',
      if ((p['location'] as String?)?.isNotEmpty == true) '📍 ${p['location']}',
      if ((p['linkedin'] as String?)?.isNotEmpty == true) '💼 ${p['linkedin']}',
    ].join('   |   ');

    final summary = (p['summary'] as String?)?.isNotEmpty == true
        ? p['summary'] as String
        : '${name} isimli, sonuç odaklı ve sürekli gelişen profesyonel. Kariyer hedefleri doğrultusunda, sahip olduğu teknik ve yönetsel becerileri kullanarak kuruma değer katmayı amaçlamaktadır. Güçlü iletişim, problem çözme ve takım çalışması becerileriyle öne çıkar.';

    final educationBlock = edu.isEmpty
        ? '- Üniversite Adı — Lisans, Bölüm (2018 - 2022)'
        : edu.map((e) {
            final s = e['school']?.toString().isNotEmpty == true ? e['school'] : 'Üniversite Adı';
            final d = e['degree']?.toString().isNotEmpty == true ? e['degree'] : 'Lisans';
            final f = e['field']?.toString().isNotEmpty == true ? e['field'] : 'Bölüm';
            final a = e['start']?.toString().isNotEmpty == true ? e['start'] : '2018';
            final b = e['end']?.toString().isNotEmpty == true ? e['end'] : '2022';
            final g = e['gpa']?.toString().isNotEmpty == true ? ' — GPA: ${e['gpa']}' : '';
            return '- $s — $d, $f ($a - $b)$g';
          }).join('\n');

    final experienceBlock = exp.isEmpty
        ? '''- Şirket Adı — Pozisyon (2022 - Günümüz)
  • Şirket içinde X projesinin A, B, C sorumluluklarını üstlenerek %30 verimlilik artışı sağlandı.
  • Takım liderliği ile Y sayıda personelin yönetimi ve Z hedeflerinin gerçekleştirilmesi.
  • Süreç iyileştirmeleriyle maliyet optimizasyonu ve müşteri memnuniyeti artışı.'''
        : exp.map((e) {
            final c = e['company']?.toString().isNotEmpty == true ? e['company'] : 'Şirket Adı';
            final p2 = e['position']?.toString().isNotEmpty == true ? e['position'] : 'Pozisyon';
            final a = e['start']?.toString().isNotEmpty == true ? e['start'] : '2022';
            final b = e['end']?.toString().isNotEmpty == true ? e['end'] : 'Günümüz';
            final desc = e['description']?.toString().isNotEmpty == true ? e['description'] : 'Şirket içinde önemli projelerde yer alarak sürekli gelişim gösterildi ve takım hedeflerine katkı sağlandı. Proje yönetimi ve süreç iyileştirmeleriyle olumlu sonuçlar alındı.';
            return '- $c — $p2 ($a - $b)\n  • $desc';
          }).join('\n\n');

    final skillsBlock = sk.isEmpty
        ? '- Teknik: Microsoft Office, Proje Yönetimi, Veri Analizi\n- Yönetsel: Takım Liderliği, İletişim, Zaman Yönetimi\n- Yazılım: Excel, PowerPoint, Word, SQL (Temel)'
        : sk.map((s) => '- $s').join('\n');

    return '''═══════════════════════════════════════════
  $name
═══════════════════════════════════════════

$contact

───────────────────────────────────────────
  👤 KİŞİSEL ÖZET
───────────────────────────────────────────
$summary

───────────────────────────────────────────
  🎓 EĞİTİM BİLGİLERİ
───────────────────────────────────────────
$educationBlock

───────────────────────────────────────────
  💼 İŞ DENEYİMİ
───────────────────────────────────────────
$experienceBlock

───────────────────────────────────────────
  ⚡ YETENEKLER & BECERİLER
───────────────────────────────────────────
$skillsBlock

───────────────────────────────────────────
  📜 SERTİFİKALAR & PROJELER
───────────────────────────────────────────
- [Sertifika Adı] — Kurum (2023)
- [Proje Adı] — Proje Tanımı, Kısa Açıklama
- [Diğer Sertifika] — Kurum (2022)

───────────────────────────────────────────
  📧 REFERANSLAR
───────────────────────────────────────────
- Referans 1: Pozisyon, Şirket — iletisim@referans.com
- Referans 2: Pozisyon, Şirket — iletisim2@referans.com

═══════════════════════════════════════════
  Bu özgeçmiş OfficialAI tarafından hazırlanmıştır.
═══════════════════════════════════════════''';
  }

  void _resetForm() {
    setState(() {
      _hasResult = false;
      _currentStep = 0;
      _resultTitle = '';
      _resultContent = '';
      _resultDocId = null;
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _locationCtrl.clear();
      _summaryCtrl.clear();
      _linkedinCtrl.clear();
      _skills.clear();
      _languages.clear();
      for (final e in _education) {
        for (final c in e.values) {
          c.dispose();
        }
      }
      for (final x in _experience) {
        for (final c in x.values) {
          c.dispose();
        }
      }
      _education.clear();
      _experience.clear();
      _addEducation();
      _addExperience();
    });
    ref.read(cvGenerationProvider.notifier).reset();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: '$_resultTitle\n\n$_resultContent'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ CV panoya kopyalandı'),
          backgroundColor: AppColors.icePrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareContent() async {
    await Share.share('$_resultTitle\n\n$_resultContent', subject: _resultTitle);
  }

  Future<void> _toggleFavorite() async {
    if (_resultDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilmiş doküman için favori eklenebilir')),
      );
      return;
    }
    await ref.read(favoriteToggleProvider((
      documentId: _resultDocId!,
      documentType: 'cv',
    )).future);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Favoriler güncellendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final cvAsync = ref.watch(cvGenerationProvider);
    final templatesAsync = ref.watch(templatesProvider);

    final body = _hasResult ? _buildResult(context, isDark) : _buildForm(context, isDark, templatesAsync);

    return isDark
        ? GlassBackground.iceDarkGradient(child: _buildScaffold(context, isDark, body, cvAsync))
        : GlassBackground.iceLightGradient(child: _buildScaffold(context, isDark, body, cvAsync));
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    Widget body,
    AsyncValue<Map<String, dynamic>?> cvAsync,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _hasResult ? 'CV Sonucu' : 'CV Oluşturucu',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasResult)
            IconButton(
              onPressed: _resetForm,
              icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white70 : Colors.black87),
              tooltip: 'Yeni CV',
            ),
        ],
      ),
      body: Stack(
        children: [
          body,
          if (cvAsync.isLoading)
            Container(
              color: Colors.black38,
              child: Center(
                child: GlassContainer(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.icePrimary),
                    ),
                  ),
                    const SizedBox(height: 16),
                    Text(
                      'CV hazırlanıyor...',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI size özel formatlanıyor...',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                      ),
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
  }

  Widget _buildForm(
    BuildContext context,
    bool isDark,
    AsyncValue<List<Map<String, dynamic>>> templatesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepperHeader(isDark),
          const SizedBox(height: 20),
          _buildStepIndicator(isDark),
          const SizedBox(height: 20),
          IndexedStack(
            index: _currentStep,
            children: [
              _buildStep1(isDark),
              _buildStep2(isDark),
              _buildStep3(isDark),
              _buildStep4(isDark, templatesAsync),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                flex: _currentStep > 0 ? 1 : 0,
                child: _currentStep > 0
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: PrimaryButton(
                          text: 'Geri',
                          variant: PrimaryButtonVariant.glass,
                          onPressed: _prevStep,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  text: _currentStep == 3 ? '✓ CV Oluştur' : 'İleri',
                  icon: _currentStep == 3 ? Icons.auto_awesome : Icons.arrow_forward,
                  onPressed: _nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.icePrimary, AppColors.iceAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profesyonel CV',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ATS uyumlu, yapay zeka destekli özgeçmişinizi 4 adımda hazırlayın',
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
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = ['Kişisel', 'Eğitim', 'Deneyim', 'Yetenek'];
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i <= _currentStep;
        final isCurrent = i == _currentStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? const LinearGradient(
                          colors: [AppColors.icePrimary, AppColors.iceAccent],
                        )
                      : null,
                  color: active ? null : (isDark ? Colors.white10 : Colors.black12),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.icePrimary
                        : (isDark ? Colors.white.withOpacity(0.20) : Colors.black12),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                    fontSize: 14,
                  ),
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: i < _currentStep
                          ? const LinearGradient(
                              colors: [AppColors.icePrimary, AppColors.iceAccent],
                            )
                          : null,
                      color: i < _currentStep ? null : (isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ============ STEP 1: Kişisel ============
  Widget _buildStep1(bool isDark) {
    return Form(
      key: _formKey1,
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 Kişisel Bilgiler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Temel iletişim bilgilerinizi doldurun',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameCtrl,
                    label: 'Ad',
                    hint: 'Adınız',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Ad gerekli' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameCtrl,
                    label: 'Soyad',
                    hint: 'Soyadınız',
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Soyad gerekli' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _emailCtrl,
              label: 'E-posta',
              hint: 'ornek@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'E-posta gerekli';
                final email = v!.trim();
                final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailReg.hasMatch(email)) return 'Geçerli bir e-posta girin';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _phoneCtrl,
                    label: 'Telefon',
                    hint: '+90 5XX XXX XX XX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _locationCtrl,
                    label: 'Konum',
                    hint: 'Şehir, Ülke',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _linkedinCtrl,
              label: 'LinkedIn (opsiyonel)',
              hint: 'linkedin.com/in/kullanici',
              prefixIcon: Icons.link_outlined,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _summaryCtrl,
              label: 'Kendinizi Tanıtın (Profesyonel Özet)',
              hint: 'Deneyimleriniz, hedefleriniz ve uzmanlık alanlarınız hakkında kısa bir özet...',
              prefixIcon: Icons.edit_note,
              maxLines: 5,
              minLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  // ============ STEP 2: Eğitim ============
  Widget _buildStep2(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎓 Eğitim Bilgileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _addEducation()),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.icePrimary),
                label: Text(
                  'Ekle',
                  style: TextStyle(
                    color: AppColors.icePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Lise, üniversite veya yüksek lisans bilgilerinizi ekleyin',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_education.length, (idx) {
            final e = _education[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '📘 Eğitim #${idx + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (_education.length > 1)
                          IconButton(
                            onPressed: () => setState(() => _removeEducation(idx)),
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: e['school']!,
                      label: 'Okul / Üniversite',
                      hint: 'Üniversite Adı',
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: e['degree']!,
                            label: 'Derece',
                            hint: 'Lisans / Y.Lisans',
                            prefixIcon: Icons.menu_book_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: e['field']!,
                            label: 'Bölüm',
                            hint: 'Bölüm Adı',
                            prefixIcon: Icons.lightbulb_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: e['start']!,
                            label: 'Başlangıç',
                            hint: '2018',
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: e['end']!,
                            label: 'Bitiş',
                            hint: '2022 / Günümüz',
                            prefixIcon: Icons.event_available_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: e['gpa']!,
                            label: 'GPA (ops.)',
                            hint: '3.50',
                            prefixIcon: Icons.star_border,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============ STEP 3: Deneyim ============
  Widget _buildStep3(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '💼 İş Deneyimi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _addExperience()),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.icePrimary),
                label: Text(
                  'Ekle',
                  style: TextStyle(
                    color: AppColors.icePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'İş deneyimlerinizi (eski tarihten yeni tarihe doğru) ekleyin',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_experience.length, (idx) {
            final x = _experience[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '🏢 Deneyim #${idx + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (_experience.length > 1)
                          IconButton(
                            onPressed: () => setState(() => _removeExperience(idx)),
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: x['company']!,
                            label: 'Şirket',
                            hint: 'Şirket Adı',
                            prefixIcon: Icons.apartment_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: x['position']!,
                            label: 'Pozisyon',
                            hint: 'Ünvan',
                            prefixIcon: Icons.work_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: x['start']!,
                            label: 'Başlangıç',
                            hint: 'Oca 2022',
                            prefixIcon: Icons.calendar_month_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: x['end']!,
                            label: 'Bitiş',
                            hint: 'Günümüz',
                            prefixIcon: Icons.event,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: x['description']!,
                      label: 'Görev Tanımı & Başarılar',
                      hint: 'Sorumluluklarınız, başarılarınız, projeleriniz... (STAR formatı önerilir)',
                      prefixIcon: Icons.notes,
                      maxLines: 5,
                      minLines: 3,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============ STEP 4: Yetenekler ============
  Widget _buildStep4(bool isDark, AsyncValue<List<Map<String, dynamic>>> templatesAsync) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚡ Yetenekler & Beceriler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Teknik, yönetsel ve sosyal becerilerinizi ekleyin',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _skillCtrl,
                      label: 'Yetenek Ekle',
                      hint: 'örn: Proje Yönetimi, Flutter, Excel...',
                      prefixIcon: Icons.bolt_outlined,
                      onFieldSubmitted: (v) {
                        final val = v.trim();
                        if (val.isNotEmpty && !_skills.contains(val)) {
                          setState(() {
                            _skills.add(val);
                            _skillCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: PrimaryButton(
                      text: 'Ekle',
                      onPressed: () {
                        final val = _skillCtrl.text.trim();
                        if (val.isNotEmpty && !_skills.contains(val)) {
                          setState(() {
                            _skills.add(val);
                            _skillCtrl.clear();
                          });
                        }
                      },
                      variant: PrimaryButtonVariant.outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.icePrimary.withOpacity(0.25), AppColors.iceAccent.withOpacity(0.25)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.icePrimary.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _skills.remove(s)),
                            child: const Icon(Icons.close, size: 16, color: AppColors.icePrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              if (_skills.isEmpty)
                Text(
                  'Henüz yetenek eklenmedi. Örnek: Flutter, Node.js, Proje Yönetimi, İngilizce',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌍 Yabancı Diller',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _languageCtrl,
                      label: 'Dil Ekle',
                      hint: 'örn: İngilizce (C1), Almanca (B2)',
                      prefixIcon: Icons.translate,
                      onFieldSubmitted: (v) {
                        final val = v.trim();
                        if (val.isNotEmpty && !_languages.contains(val)) {
                          setState(() {
                            _languages.add(val);
                            _languageCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: PrimaryButton(
                      text: 'Ekle',
                      onPressed: () {
                        final val = _languageCtrl.text.trim();
                        if (val.isNotEmpty && !_languages.contains(val)) {
                          setState(() {
                            _languages.add(val);
                            _languageCtrl.clear();
                          });
                        }
                      },
                      variant: PrimaryButtonVariant.outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_languages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _languages.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.withOpacity(0.25), Colors.cyan.withOpacity(0.25)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.teal.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _languages.remove(s)),
                            child: const Icon(Icons.close, size: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📑 CV Şablonu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              templatesAsync.when(
                data: (templates) {
                  final list = templates.isEmpty
                      ? [
                          {'id': 'tpl_modern', 'name': 'Modern ATS', 'description': 'Profesyonel ve modern tasarım'},
                          {'id': 'tpl_classic', 'name': 'Klasik', 'description': 'Geleneksel, zamansız görünüm'},
                          {'id': 'tpl_creative', 'name': 'Yaratıcı', 'description': 'Farklı görünüm isteyenler'},
                        ]
                      : templates;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(list.length, (i) {
                      final t = list[i];
                      final selected = _selectedTemplateId == (t['id'] as String?);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTemplateId = t['id'] as String?),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 76) / 2,
                          constraints: const BoxConstraints(minWidth: 140, maxWidth: 170),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: selected
                                ? const LinearGradient(
                                    colors: [AppColors.icePrimary, AppColors.iceAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: selected ? null : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                            border: Border.all(
                              color: selected
                                  ? AppColors.icePrimary.withOpacity(0.5)
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: selected ? Colors.white : AppColors.icePrimary,
                                size: 26,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (t['name'] as String?) ?? 'Şablon',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (t['description'] as String?) ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selected
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  final list = [
                    {'id': 'tpl_modern', 'name': 'Modern ATS', 'description': 'Profesyonel ve modern tasarım'},
                    {'id': 'tpl_classic', 'name': 'Klasik', 'description': 'Geleneksel görünüm'},
                  ];
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(list.length, (i) {
                      final t = list[i];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTemplateId = t['id'] as String?),
                        child: Container(
                          width: MediaQuery.of(context).size.width > 320 ? 150 : 140,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.description_outlined, color: AppColors.icePrimary, size: 26),
                              const SizedBox(height: 8),
                              Text(t['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ SONUÇ ============
  Widget _buildResult(BuildContext context, bool isDark) {
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
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CV Hazır!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ATS uyumlu özgeçmişiniz başarılı şekilde oluşturuldu',
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
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: _actionChip(Icons.copy_all_outlined, 'Kopyala', _copyToClipboard, isDark),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                Expanded(
                  child: _actionChip(Icons.favorite_border, 'Favori', _toggleFavorite, isDark),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                Expanded(
                  child: _actionChip(Icons.share_outlined, 'Paylaş', _shareContent, isDark),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                Expanded(
                  child: _actionChip(
                    Icons.picture_as_pdf_outlined,
                    'PDF',
                    () async {
                      final text = _resultContent.trim();
                      if (text.isEmpty) return;
                      try {
                        await PdfExportUtils.exportAndShare(
                          title: _resultTitle.isEmpty ? 'CV / Özgeçmiş' : _resultTitle,
                          subtitle: 'OfficialAI • ATS Optimize Özgeçmiş',
                          content: text,
                          documentType: 'cv',
                          shareSubject: _resultTitle.isEmpty ? 'OfficialAI CV' : _resultTitle,
                        );
                      } catch (_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PDF oluşturulamadı, lütfen tekrar deneyin')),
                          );
                        }
                      }
                    },
                    isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.darkGlassStrong, AppColors.darkGlassStrong.withOpacity(0.6)]
                          : [Colors.white, Colors.white70],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.icePrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _resultTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.icePrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  _resultContent,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.65,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: '🔄 Yeni CV Oluştur',
            icon: Icons.refresh,
            onPressed: _resetForm,
            variant: PrimaryButtonVariant.glass,
          ),
        ],
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.icePrimary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
