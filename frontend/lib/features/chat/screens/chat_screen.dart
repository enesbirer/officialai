import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/primary_button.dart';
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
        messagesNotifier.addAI(_demoAnswer(query));
      }
    } catch (_) {
      messagesNotifier.addAI(_demoAnswer(query));
    }
    _scrollToBottom();
  }

  String _demoAnswer(String q) {
    final qLower = q.toLowerCase();
    if (qLower.contains('dilekçe') || qLower.contains('petition')) {
      return 'Merhaba! Dilekçe oluşturmak için ana ekrandaki "Dilekçe" kartına tıklayabilirsiniz. OfficialAI ile resmi dilekçelerinizi (iş, trafik, kira, eğitim vb.) kategorilerine göre alanları doldurarak, tamamen Türk resmi yazım kurallarına uygun şekilde AI ile oluşturabilirsiniz.';
    }
    if (qLower.contains('cv') || qLower.contains('özgeçmiş') || qLower.contains('ozgecmis')) {
      return 'CV / Özgeçmiş oluşturmak için ana ekrandaki "CV Oluşturucu" bölümünü kullanın. 4 adımda kişisel bilgiler, eğitim, iş deneyimi ve yeteneklerinizi girin; ATS uyumlu, profesyonel bir özgeçmiş elde edin. PDF olarak kaydedebilir ve paylaşabilirsiniz.';
    }
    if (qLower.contains('e-posta') || qLower.contains('email') || qLower.contains('mail')) {
      return 'E-posta oluşturucu için ana ekrandaki "E-posta" seçeneğini kullanın. Resmi, yarı resmi, özel, teşekkür veya şikayet tonlarında ve TR/EN dillerinde konu bağlamınıza uygun e-postalar AI ile hızlıca hazırlanır.';
    }
    if (qLower.contains('nası') || qLower.contains('how') || qLower.contains('yardım')) {
      return '''Merhaba 👋 OfficialAI size nasıl yardımcı olabilirim?

📋 **Dilekçe**: Resmi dilekçe, yazı, tebliğ ve benzeri resmi evraklar
✉️ **E-posta**: İş/özel her türlü e-posta taslakları
📄 **CV**: Profesyonel, ATS uyumlu özgeçmiş hazırlama
📷 **Scanner**: Belgelerinizi OCR ile analiz ettirme
💬 **Sohbet**: Genel sorularınız için benimle sohbet edin

Özelliklerden birini seçerek veya bana doğrudan sorunuzu yazarak başlayabilirsiniz!''';
    }
    if (qLower.contains('merhaba') || qLower.contains('selam') || qLower.contains('hi') || qLower.contains('hello')) {
      return 'Merhaba! 👋 OfficialAI yapay zeka asistanına hoş geldiniz. Resmi evrak, e-posta, CV, OCR belge analiz ve daha fazlası için yanınızdayım. Size nasıl yardımcı olabilirim?';
    }
    return '''Sorunuzu anladım ✨

Size destek olmak için OfficialAI ile ilgili bilmemiz gerekenler:
- 📋 **Dilekçe Oluşturucu**: 10'dan fazla kategori ile resmi dilekçe hazırlama
- ✉️ **E-posta Üreticisi**: Farklı ton ve dillerde profesyonel e-postalar
- 📄 **CV Builder**: ATS uyumlu 4 adımda özgeçmiş
- 📷 **OCR Tarayıcı**: Belgeleri analiz etme ve özetleme

Bana özel bir konu (örn: "işten çıkış dilekçesi nasıl yazılır" veya "CV özet bölümü nasıl olmalı" gibi) sorabilir veya ana menüden ilgili özelliği seçerek hemen kullanmaya başlayabilirsiniz. Başka sorunuz varsa çekinmeden sorun! 😊''';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.icePrimary, AppColors.iceAccent],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OfficialAI Asistan',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isLoading ? 'Düşünüyor...' : 'Çevrimiçi',
                      style: TextStyle(
                        color: isLoading ? Colors.amber : Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.transparent,
                content: GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cleaning_services_outlined, size: 52, color: AppColors.icePrimary),
                      const SizedBox(height: 12),
                      Text(
                        'Sohbeti Temizle',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tüm mesajları silmek istediğinize emin misiniz?',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: 'İptal',
                              variant: PrimaryButtonVariant.outlined,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryButton(
                              text: 'Temizle',
                              onPressed: () {
                                _clearAll();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            icon: Icon(Icons.delete_sweep_outlined, color: isDark ? Colors.white70 : Colors.black87),
            tooltip: 'Sohbeti temizle',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (isLoading && i == messages.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.icePrimary.withOpacity(0.2),
                                child: const Icon(Icons.smart_toy_outlined, color: AppColors.icePrimary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              GlassContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                backgroundColor: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 10, height: 10,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.icePrimary),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Yazıyor...'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final m = messages[i];
                      final isUser = m.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.icePrimary.withOpacity(0.2),
                                  child: const Icon(Icons.smart_toy_outlined, color: AppColors.icePrimary, size: 18),
                                ),
                              ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isUser
                                      ? const LinearGradient(
                                          colors: [AppColors.icePrimary, AppColors.iceAccent],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isUser
                                      ? null
                                      : (isDark ? AppColors.darkGlassStrong : Colors.white),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
                                    bottomRight: isUser ? Radius.zero : const Radius.circular(18),
                                  ),
                                  border: Border.all(
                                    color: isUser ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
                                  ),
                                ),
                                child: SelectableText(
                                  m.content,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                    height: 1.45,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (isUser)
                              const SizedBox(width: 8),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _buildInputBox(context, isDark, isLoading),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final suggestions = [
      'Resmi dilekçe nasıl yazılır?',
      'CV özet bölümü örnekleri',
      'İngilizce iş başvuru e-postası',
      'OCR ile belge analiz etme',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.icePrimary.withOpacity(0.2), AppColors.iceAccent.withOpacity(0.2)],
              ),
              border: Border.all(color: AppColors.icePrimary.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.smart_toy_outlined, size: 64, color: AppColors.icePrimary),
          ),
          const SizedBox(height: 18),
          Text(
            'OfficialAI Yardımcı Asistanı',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Dilekçe, e-posta, CV, OCR veya genel sorularınız için size yardımcı olabilirim.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassContainer(
                  onTap: () {
                    _textCtrl.text = s;
                    _sendMessage();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.icePrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white60 : Colors.black45),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInputBox(BuildContext context, bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
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
                prefixIcon: Icons.message_outlined,
                onFieldSubmitted: (_) {
                  if (!isLoading) _sendMessage();
                },
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isLoading ? null : _sendMessage,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isLoading
                      ? LinearGradient(colors: [Colors.grey, Colors.grey.withOpacity(0.8)])
                      : const LinearGradient(
                          colors: [AppColors.icePrimary, AppColors.iceAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.icePrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isLoading ? Icons.hourglass_top : Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
