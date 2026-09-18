import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _stageVerify = false;
  String? _registeredEmail;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String _err(Object? e) {
    if (e == null) return 'Bilinmeyen hata';
    final s = e.toString();
    if (s.contains('Exception:')) return s.split('Exception:').last.trim();
    if (s.length > 120) return '${s.substring(0, 120)}...';
    return s;
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : AppColors.iceSecondary,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final result = await ref.read(authNotifierProvider.notifier).register(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
          );
      if (mounted) {
        setState(() {
          _stageVerify = true;
          _registeredEmail = _emailCtrl.text.trim();
        });
        _snack(result['message'] ?? 'Doğrulama kodu gönderildi');
      }
    } catch (e) {
      if (mounted) _snack('Kayıt başarısız: ${_err(e)}', error: true);
    }
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.length != 6) {
      _snack('Lütfen 6 haneli kodu girin', error: true);
      return;
    }
    try {
      await ref.read(authNotifierProvider.notifier).verifyEmail(
            _registeredEmail!,
            _codeCtrl.text.trim(),
          );
      if (mounted) {
        final s = ref.read(authNotifierProvider);
        if (s.value != null) {
          context.go('/dashboard');
        } else if (s.hasError) {
          _snack('Doğrulama başarısız: ${_err(s.error)}', error: true);
        }
      }
    } catch (e) {
      if (mounted) _snack('Doğrulama başarısız: ${_err(e)}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final loading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _buildBody(text, sub, loading))
          : GlassBackground.iceLightGradient(child: _buildBody(text, sub, loading)),
    );
  }

  Widget _buildBody(Color text, Color sub, bool loading) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.iceAccent, AppColors.icePrimary],
                          ),
                        ),
                        child: Icon(
                          _stageVerify ? Icons.verified_user_rounded : Icons.person_add_alt_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stageVerify ? 'E-postayı Doğrula' : 'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _stageVerify
                            ? 'Gönderilen kodu $_registeredEmail adresine girin'
                            : 'Tüm özelliklere erişmek için üye olun',
                        style: TextStyle(color: sub, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 26,
                  child: Column(
                    children: [
                      if (!_stageVerify) ..._registerFields(),
                      if (_stageVerify) ..._verifyFields(sub),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        text: _stageVerify ? 'Doğrula ve Giriş Yap' : 'Hesap Oluştur',
                        icon: _stageVerify ? Icons.task_alt_rounded : Icons.how_to_reg_rounded,
                        loading: loading,
                        onPressed: _stageVerify ? _verify : _register,
                      ),
                      const SizedBox(height: 16),
                      if (_stageVerify)
                        PrimaryButton(
                          text: 'Geri Dön',
                          variant: PrimaryButtonVariant.outlined,
                          icon: Icons.arrow_back_rounded,
                          onPressed: loading
                              ? null
                              : () => setState(() {
                                    _stageVerify = false;
                                    _registeredEmail = null;
                                  }),
                        )
                      else
                        PrimaryButton(
                          text: 'Giriş Sayfasına Dön',
                          variant: PrimaryButtonVariant.glass,
                          icon: Icons.arrow_back_rounded,
                          onPressed: loading ? null : () => context.go('/login'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _registerFields() {
    return [
      Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _firstNameCtrl,
              label: 'Ad',
              hint: 'Ahmet',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomTextField(
              controller: _lastNameCtrl,
              label: 'Soyad',
              hint: 'Yılmaz',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Soyad gerekli' : null,
              textInputAction: TextInputAction.next,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      CustomTextField(
        controller: _emailCtrl,
        label: 'E-posta',
        hint: 'ornek@mail.com',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        textInputAction: TextInputAction.next,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
          if (!AppConfig.emailRegex.hasMatch(v.trim())) return 'Geçerli bir e-posta girin';
          return null;
        },
      ),
      const SizedBox(height: 14),
      CustomTextField(
        controller: _passCtrl,
        label: 'Şifre',
        hint: '••••••••',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: true,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
        validator: (v) {
          if (v == null || v.isEmpty) return 'Şifre gerekli';
          if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
          return null;
        },
      ),
      const SizedBox(height: 14),
      CustomTextField(
        controller: _pass2Ctrl,
        label: 'Şifre (Tekrar)',
        hint: '••••••••',
        prefixIcon: Icons.lock_rounded,
        obscureText: true,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _register(),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Şifre tekrar gerekli';
          if (v != _passCtrl.text) return 'Şifreler eşleşmiyor';
          return null;
        },
      ),
    ];
  }

  List<Widget> _verifyFields(Color sub) {
    return [
      const SizedBox(height: 8),
      CustomTextField(
        controller: _codeCtrl,
        label: 'Doğrulama Kodu',
        hint: '000000',
        prefixIcon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.icePrimary,
          fontSize: 28,
          letterSpacing: 14,
          fontWeight: FontWeight.w800,
        ),
        onFieldSubmitted: (_) => _verify(),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Kod gerekli';
          if (v.trim().length != 6) return '6 haneli kod girin';
          return null;
        },
      ),
      const SizedBox(height: 6),
      Text('Kodu almadınız mı? 60 sn sonra tekrar deneyin',
          style: TextStyle(color: sub, fontSize: 12)),
    ];
  }
}
