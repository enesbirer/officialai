import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_messages.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/theme_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final messagesNotifier = ref.read(chatMessagesProvider.notifier);
    final chatNotifier = ref.read(chatGenerationProvider.notifier);

    messagesNotifier.addUser(text);
    final query = text;
    final history = ref.read(chatMessagesProvider);
    final historyList = history
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
    _textCtrl.clear();
    _scrollToBottom();

    try {
      final r = await chatNotifier.send(
        userMessage: query,
        history: historyList.isNotEmpty ? historyList : null,
      );
      final aiText = (r['content'] as String?) ?? (r['message'] as String?) ?? '';
      if (aiText.isNotEmpty) {
        messagesNotifier.addAI(aiText);
      } else {
        _showChatError('Yapay zekâ boş bir yanıt döndürdü. Lütfen sorunuzu tekrar gönderin.');
      }
    } catch (e) {
      _showChatError(friendlyErrorMessage(e, action: 'Mesaj gönderme'));
    }
    _scrollToBottom();
  }

  void _showChatError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearAll() {
    ref.read(chatMessagesProvider.notifier).clear();
    ref.read(chatGenerationProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final messages = ref.watch(chatMessagesProvider);
    final chatAsync = ref.watch(chatGenerationProvider);
    final isLoading = chatAsync.isLoading;

    final bg = isDark
        ? GlassBackground.iceDarkGradient(
            child: _buildScaffold(context, isDark, messages, isLoading),
          )
        : GlassBackground.iceLightGradient(
            child: _buildScaffold(context, isDark, messages, isLoading),
          );
    return bg;
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    List<ChatMessage> messages,
    bool isLoading,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OfficialAI Asistan',
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isLoading ? AppColors.warning : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isLoading ? 'Düşünüyor...' : 'Çevrimiçi',
                      style: TextStyle(
                        color: sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showClearDialog(context, isDark),
            icon: Icon(Icons.delete_sweep_outlined, color: text, size: 24),
            tooltip: 'Sohbeti temizle',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (isLoading && i == messages.length) {
                        return _buildTypingBubble(isDark, sub, accent);
                      }
                      final m = messages[i];
                      final isUser = m.role == 'user';
                      return _buildMessageBubble(m, isUser, isDark, text, accent);
                    },
                  ),
          ),
          _buildInputBox(context, isDark, isLoading),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void _showClearDialog(BuildContext context, bool isDark) {
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cleaning_services_outlined, size: 44, color: AppColors.accent),
            const SizedBox(height: 12),
            const Text(
              'Sohbeti Temizle',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Tüm mesajları silmek istediğinize emin misiniz?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: sub),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble(bool isDark, Color sub, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.smart_toy_outlined, color: accent, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGlassStrong : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                ),
                const SizedBox(width: 10),
                Text('Yazıyor...', style: TextStyle(color: sub, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage m,
    bool isUser,
    bool isDark,
    Color text,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.smart_toy_outlined, color: accent, size: 18),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              decoration: BoxDecoration(
                color: isUser ? accent : (isDark ? AppColors.darkGlassStrong : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
              ),
              child: SelectableText(
                m.content,
                style: TextStyle(
                  color: isUser ? Colors.white : text,
                  height: 1.4,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final suggestions = [
      'Resmi dilekçe nasıl yazılır?',
      'CV özet bölümü örnekleri',
      'İngilizce iş başvuru e-postası',
      'OCR ile belge analiz etme',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.smart_toy_outlined, size: 48, color: accent),
          ),
          const SizedBox(height: 20),
          Text(
            'OfficialAI Yardımcı Asistanı',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Dilekçe, e-posta, CV, OCR veya genel sorularınız için size yardımcı olabilirim.',
            style: TextStyle(fontSize: 15, height: 1.4, color: sub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                onTap: () {
                  _textCtrl.text = s;
                  _sendMessage();
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, color: accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 22, color: sub),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(BuildContext context, bool isDark, bool isLoading) {
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.clamp),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1C1C1E) : Colors.white).withValues(alpha: 0.82),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _textCtrl,
                    focusNode: _focusNode,
                    label: '',
                    hint: 'Mesajınızı yazın...',
                    minLines: 1,
                    maxLines: 4,
                    onFieldSubmitted: (_) {
                      if (!isLoading) _sendMessage();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  button: true,
                  label: 'Gönder',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: isLoading ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isLoading ? accent.withValues(alpha: 0.4) : accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isLoading ? Icons.hourglass_top_rounded : Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
