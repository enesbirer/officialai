import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authNotifierProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (mounted) {
        final s = ref.read(authNotifierProvider);
        if (s.value != null) {
          context.go('/dashboard');
        } else if (s.hasError) {
          _err('Giriş başarısız: ${_extractError(s.error)}');
        }
      }
    } catch (e) {
      if (mounted) _err('Giriş başarısız: ${_extractError(e)}');
    }
  }

  String _extractError(Object? e) {
    if (e == null) return 'Bilinmeyen hata';
    final s = e.toString();
    // Dio error formatını temizle
    if (s.contains('Exception:')) return s.split('Exception:').last.trim();
    if (s.length > 120) return '${s.substring(0, 120)}...';
    return s;
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 36,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.icePrimary, AppColors.iceSecondary],
                          ),
                        ),
                        child: const Icon(
                          Icons.document_scanner,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConfig.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Hoş geldiniz, giriş yapın', style: TextStyle(color: sub)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'E-posta',
                        hint: 'ornek@mail.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                          if (!AppConfig.emailRegex.hasMatch(v.trim())) {
                            return 'Geçerli bir e-posta girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passCtrl,
                        label: 'Şifre',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        suffixIcon:
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        onSuffixTap: () => setState(() => _obscure = !_obscure),
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Şifre gerekli';
                          if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Şifre sıfırlama için e-posta gönderin'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Şifremi unuttum'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        text: 'Giriş Yap',
                        icon: Icons.login_rounded,
                        loading: loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: Divider(color: sub.withAlpha(60))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('veya', style: TextStyle(color: sub, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: sub.withAlpha(60))),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: 'Kayıt Ol',
                              variant: PrimaryButtonVariant.outlined,
                              icon: Icons.person_add_alt_rounded,
                              onPressed: loading ? null : () => context.go('/register'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Amazon Appstore için ücretsiz sürüm',
                  style: TextStyle(color: sub.withAlpha(180), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
