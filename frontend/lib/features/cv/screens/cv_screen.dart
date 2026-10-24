import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../core/utils/error_messages.dart';
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyErrorMessage(e, action: 'CV oluşturma')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          content: const Text('CV panoya kopyalandı'),
          backgroundColor: AppColors.accent,
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
        const SnackBar(content: Text('Favoriler güncellendi')),
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
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
          tooltip: 'Geri',
          onPressed: () => AppNavigation.back(context),
        ),
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
          _hasResult ? 'CV Sonucu' : 'CV Oluşturucu',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasResult)
            IconButton(
              onPressed: _resetForm,
              icon: Icon(Icons.refresh_rounded, color: text, size: 24),
              tooltip: 'Yeni CV',
            ),
        ],
      ),
      body: Stack(
        children: [
          body,
          if (cvAsync.isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CV hazırlanıyor...',
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'AI size özel formatlanıyor...',
                          style: TextStyle(color: sub, fontSize: 13),
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
  }

  Widget _buildForm(
    BuildContext context,
    bool isDark,
    AsyncValue<List<Map<String, dynamic>>> templatesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepperHeader(isDark),
          const SizedBox(height: 24),
          _buildStepIndicator(isDark),
          const SizedBox(height: 24),
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
                  text: _currentStep == 3 ? 'CV Oluştur' : 'İleri',
                  icon: _currentStep == 3 ? Icons.auto_awesome : Icons.arrow_forward_rounded,
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
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
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
            child: Icon(Icons.description_outlined, color: accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profesyonel CV',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ATS uyumlu, yapay zeka destekli özgeçmişinizi 4 adımda hazırlayın',
                  style: TextStyle(fontSize: 13, height: 1.3, color: sub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final inactive = isDark ? AppColors.darkFill : AppColors.lightFill;
    final connector = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final steps = ['Kişisel', 'Eğitim', 'Deneyim', 'Yetenek'];
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i <= _currentStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? accent : inactive,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: active ? Colors.white : sub,
                  ),
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 1,
                    color: i < _currentStep ? accent : connector,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _stepTitle(IconData icon, String title, bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _entryIcon(IconData icon, bool isDark) {
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: accent, size: 22),
    );
  }

  // ============ STEP 1: Kişisel ============
  Widget _buildStep1(bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final multilineStyle = TextStyle(color: text, fontSize: 16, height: 1.5);

    return Form(
      key: _formKey1,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle(Icons.person_outline_rounded, 'Kişisel Bilgiler', isDark),
            const SizedBox(height: 4),
            Text(
              'Temel iletişim bilgilerinizi doldurun',
              style: TextStyle(fontSize: 13, color: sub),
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
              prefixIcon: Icons.edit_note_rounded,
              maxLines: 5,
              minLines: 4,
              style: multilineStyle,
            ),
          ],
        ),
      ),
    );
  }

  // ============ STEP 2: Eğitim ============
  Widget _buildStep2(bool isDark) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.school_outlined, color: accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Eğitim Bilgileri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _addEducation()),
                  icon: Icon(Icons.add_rounded, color: accent, size: 20),
                  label: Text(
                    'Ekle',
                    style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Lise, üniversite veya yüksek lisans bilgilerinizi ekleyin',
              style: TextStyle(fontSize: 13, color: sub),
            ),
          ),
          ...List.generate(_education.length, (idx) {
            final e = _education[idx];
            return Column(
              children: [
                if (idx > 0) const GlassDivider(height: 1, indent: 60),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _entryIcon(Icons.menu_book_outlined, isDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Eğitim #${idx + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          if (_education.length > 1)
                            IconButton(
                              onPressed: () => setState(() => _removeEducation(idx)),
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                              tooltip: 'Sil',
                              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: e['school']!,
                        label: 'Okul / Üniversite',
                        hint: 'Üniversite Adı',
                        prefixIcon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 14),
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
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 14),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: e['end']!,
                              label: 'Bitiş',
                              hint: '2022',
                              prefixIcon: Icons.event_available_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: e['gpa']!,
                              label: 'GPA (ops.)',
                              hint: '3.50',
                              prefixIcon: Icons.star_border_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ============ STEP 3: Deneyim ============
  Widget _buildStep3(bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final multilineStyle = TextStyle(color: text, fontSize: 16, height: 1.5);

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.work_outline_rounded, color: accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'İş Deneyimi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: text,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _addExperience()),
                  icon: Icon(Icons.add_rounded, color: accent, size: 20),
                  label: Text(
                    'Ekle',
                    style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'İş deneyimlerinizi (eski tarihten yeni tarihe doğru) ekleyin',
              style: TextStyle(fontSize: 13, color: sub),
            ),
          ),
          ...List.generate(_experience.length, (idx) {
            final x = _experience[idx];
            return Column(
              children: [
                if (idx > 0) const GlassDivider(height: 1, indent: 60),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _entryIcon(Icons.apartment_outlined, isDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Deneyim #${idx + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                color: text,
                              ),
                            ),
                          ),
                          if (_experience.length > 1)
                            IconButton(
                              onPressed: () => setState(() => _removeExperience(idx)),
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                              tooltip: 'Sil',
                              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
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
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 14),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: x['end']!,
                              label: 'Bitiş',
                              hint: 'Günümüz',
                              prefixIcon: Icons.event_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: x['description']!,
                        label: 'Görev Tanımı & Başarılar',
                        hint: 'Sorumluluklarınız, başarılarınız, projeleriniz... (STAR formatı önerilir)',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 5,
                        minLines: 3,
                        style: multilineStyle,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ============ STEP 4: Yetenekler ============
  Widget _buildStep4(bool isDark, AsyncValue<List<Map<String, dynamic>>> templatesAsync) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stepTitle(Icons.bolt_outlined, 'Yetenekler & Beceriler', isDark),
              const SizedBox(height: 6),
              Text(
                'Teknik, yönetsel ve sosyal becerilerinizi ekleyin',
                style: TextStyle(fontSize: 13, color: sub),
              ),
              const SizedBox(height: 16),
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
                      expanded: false,
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
              const SizedBox(height: 16),
              if (_skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((s) => _buildChip(s, isDark, () {
                        setState(() => _skills.remove(s));
                      })).toList(),
                ),
              if (_skills.isEmpty)
                Text(
                  'Henüz yetenek eklenmedi. Örnek: Flutter, Node.js, Proje Yönetimi, İngilizce',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
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
              _stepTitle(Icons.translate_rounded, 'Yabancı Diller', isDark),
              const SizedBox(height: 16),
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
                      expanded: false,
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
              const SizedBox(height: 16),
              if (_languages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _languages.map((s) => _buildChip(s, isDark, () {
                        setState(() => _languages.remove(s));
                      })).toList(),
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
              _stepTitle(Icons.description_outlined, 'CV Şablonu', isDark),
              const SizedBox(height: 16),
              templatesAsync.when(
                data: (templates) {
                  final list = templates.isEmpty
                      ? <Map<String, dynamic>>[
                          {'id': 'tpl_modern', 'name': 'Modern ATS', 'description': 'Profesyonel ve modern tasarım'},
                          {'id': 'tpl_classic', 'name': 'Klasik', 'description': 'Geleneksel, zamansız görünüm'},
                          {'id': 'tpl_creative', 'name': 'Yaratıcı', 'description': 'Farklı görünüm isteyenler'},
                        ]
                      : templates;
                  return _buildTemplateList(list, isDark);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) {
                  final list = <Map<String, dynamic>>[
                    {'id': 'tpl_modern', 'name': 'Modern ATS', 'description': 'Profesyonel ve modern tasarım'},
                    {'id': 'tpl_classic', 'name': 'Klasik', 'description': 'Geleneksel görünüm'},
                  ];
                  return _buildTemplateList(list, isDark);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isDark, VoidCallback onRemove) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.close_rounded, size: 16, color: accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(List<Map<String, dynamic>> list, bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final width = ((MediaQuery.of(context).size.width - 76) / 2).clamp(140.0, 170.0).toDouble();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: list.map((t) {
        final selected = _selectedTemplateId == (t['id'] as String?);
        return SizedBox(
          width: width,
          child: GlassContainer(
            onTap: () => setState(() => _selectedTemplateId = t['id'] as String?),
            padding: const EdgeInsets.all(14),
            backgroundColor: selected ? accent.withValues(alpha: 0.12) : null,
            border: Border.all(
              color: selected ? accent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: selected ? 1.5 : 0.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.description_outlined, color: accent, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  (t['name'] as String?) ?? 'Şablon',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (t['description'] as String?) ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, height: 1.3, color: sub),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============ SONUÇ ============
  Widget _buildResult(BuildContext context, bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _entryIcon(Icons.check_circle_outline_rounded, isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CV Hazır!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ATS uyumlu özgeçmişiniz başarılı şekilde oluşturuldu',
                        style: TextStyle(fontSize: 13, color: sub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: _actionChip(Icons.copy_all_outlined, 'Kopyala', _copyToClipboard, isDark),
                ),
                _actionDivider(isDark),
                Expanded(
                  child: _actionChip(Icons.favorite_border_rounded, 'Favori', _toggleFavorite, isDark),
                ),
                _actionDivider(isDark),
                Expanded(
                  child: _actionChip(Icons.share_outlined, 'Paylaş', _shareContent, isDark),
                ),
                _actionDivider(isDark),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _resultTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  _resultContent,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: text,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Yeni CV Oluştur',
            icon: Icons.refresh_rounded,
            onPressed: _resetForm,
            variant: PrimaryButtonVariant.glass,
          ),
        ],
      ),
    );
  }

  Widget _actionDivider(bool isDark) {
    return Container(
      width: 0.5,
      height: 40,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap, bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
