import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_messages.dart';
import '../../../providers/ai_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';

/// Oluşturulan bir belgeyi e-posta olarak göndermek için alıcı/konu/mesaj
/// bilgilerini toplayan diyalogu açar.
///
/// [pdfBytes] verilirse belge PDF eki olarak gönderilir.
Future<void> showDocumentEmailDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String content,
  Uint8List? pdfBytes,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final toCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(text: title);
  final messageCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var sending = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            setState(() => sending = true);
            final target = toCtrl.text.trim();
            try {
              await ref.read(aiRepositoryProvider).sendDocumentEmail(
                    to: target,
                    title: title,
                    content: content,
                    subject: subjectCtrl.text.trim(),
                    message: messageCtrl.text.trim(),
                    pdfBase64: pdfBytes == null ? null : base64Encode(pdfBytes),
                  );
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Belge $target adresine gönderildi'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            } catch (e) {
              if (!dialogContext.mounted) return;
              setState(() => sending = false);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(friendlyErrorMessage(e, action: 'E-posta gönderme')),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }

          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final text =
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          final sub =
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

          return AlertDialog(
            title: Text('E-posta ile Gönder', style: TextStyle(color: text)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdfBytes == null
                            ? 'Belge, e-posta metni olarak gönderilecek.'
                            : 'Belge, PDF eki ile birlikte gönderilecek.',
                        style: TextStyle(color: sub, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: toCtrl,
                        label: 'Alıcı e-posta',
                        hint: 'ornek@kurum.gov.tr',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Alıcı e-posta gerekli';
                          if (!AppConfig.emailRegex.hasMatch(value)) {
                            return 'Geçerli bir e-posta girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: subjectCtrl,
                        label: 'Konu',
                        prefixIcon: Icons.subject_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: messageCtrl,
                        label: 'Kısa not (isteğe bağlı)',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 3,
                        minLines: 2,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: sending ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'İptal',
                  style: TextStyle(color: sub),
                ),
              ),
              SizedBox(
                width: 140,
                child: PrimaryButton(
                  text: 'Gönder',
                  icon: Icons.send_rounded,
                  loading: sending,
                  onPressed: sending ? null : submit,
                ),
              ),
            ],
          );
        },
      );
    },
  );

  toCtrl.dispose();
  subjectCtrl.dispose();
  messageCtrl.dispose();
}
