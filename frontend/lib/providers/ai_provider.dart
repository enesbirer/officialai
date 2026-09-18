import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dio_client.dart';
import '../repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepository(ref.watch(dioProvider));
});

// ================ FutureProviders ================

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getCategories();
});

final templatesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getTemplates();
});

final documentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, type) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getUserDocuments(type: type);
});

final favoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getFavorites();
});

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getConversations();
});

final conversationMessagesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getConversationMessages(id);
});

// ================ Generation State Providers ================

final petitionGenerationProvider =
    StateNotifierProvider<PetitionGenerator, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return PetitionGenerator(ref.watch(aiRepositoryProvider));
});

class PetitionGenerator extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AIRepository _repo;
  PetitionGenerator(this._repo) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> generate({
    required String categoryId,
    required Map<String, dynamic> answers,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final r = await _repo.generatePetition(
        categoryId: categoryId,
        answers: answers,
      );
      return r;
    });
    final value = state.value;
    if (value == null) throw Exception('Petition generation failed');
    return value;
  }

  void reset() => state = const AsyncValue.data(null);
}

// ================ Email Generation ================

final emailGenerationProvider =
    StateNotifierProvider<EmailGenerator, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return EmailGenerator(ref.watch(aiRepositoryProvider));
});

class EmailGenerator extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AIRepository _repo;
  EmailGenerator(this._repo) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> generate({
    required String type,
    required String tone,
    required String language,
    required String context,
    String? recipient,
    String? senderName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repo.generateEmail(
        type: type,
        tone: tone,
        language: language,
        context: context,
        recipient: recipient,
        senderName: senderName,
      );
    });
    final value = state.value;
    if (value == null) throw Exception('Email generation failed');
    return value;
  }

  void reset() => state = const AsyncValue.data(null);
}

// ================ CV Generation ================

final cvGenerationProvider =
    StateNotifierProvider<CVGenerator, AsyncValue<Map<String, dynamic>?>>((ref) {
  return CVGenerator(ref.watch(aiRepositoryProvider));
});

class CVGenerator extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AIRepository _repo;
  CVGenerator(this._repo) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> generate({
    required Map<String, dynamic> personalInfo,
    required List<Map<String, dynamic>> education,
    required List<Map<String, dynamic>> experience,
    required List<String> skills,
    String? templateId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repo.generateCV(
        personalInfo: personalInfo,
        education: education,
        experience: experience,
        skills: skills,
        templateId: templateId,
      );
    });
    final value = state.value;
    if (value == null) throw Exception('CV generation failed');
    return value;
  }

  void reset() => state = const AsyncValue.data(null);
}

// ================ OCR Analysis ================

final ocrAnalysisProvider =
    StateNotifierProvider<OCRAnalyzer, AsyncValue<Map<String, dynamic>?>>((ref) {
  return OCRAnalyzer(ref.watch(aiRepositoryProvider));
});

class OCRAnalyzer extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AIRepository _repo;
  OCRAnalyzer(this._repo) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> analyze({
    required String ocrText,
    String? customInstructions,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repo.analyzeOCR(
        ocrText: ocrText,
        customInstructions: customInstructions,
      );
    });
    final value = state.value;
    if (value == null) throw Exception('OCR analysis failed');
    return value;
  }

  void reset() => state = const AsyncValue.data(null);
}

// ================ Chat Generation ================

final chatGenerationProvider =
    StateNotifierProvider<ChatGenerator, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return ChatGenerator(ref.watch(aiRepositoryProvider));
});

class ChatGenerator extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AIRepository _repo;
  ChatGenerator(this._repo) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> send({
    required String userMessage,
    List<Map<String, dynamic>>? history,
    String? conversationId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repo.chat(
        userMessage: userMessage,
        history: history,
        conversationId: conversationId,
      );
    });
    final value = state.value;
    if (value == null) throw Exception('Chat failed');
    return value;
  }

  void reset() => state = const AsyncValue.data(null);
}

// ================ Favorites Toggle ================

final favoriteToggleProvider =
    FutureProviderFamily<bool, ({String documentId, String documentType})>(
        (ref, params) async {
  final repo = ref.watch(aiRepositoryProvider);
  final r = await repo.toggleFavorite(
    documentId: params.documentId,
    documentType: params.documentType,
  );
  ref.invalidate(favoritesProvider);
  return (r['isFavorite'] ?? false) as bool;
});

// ================ Chat local state (mesaj listesi) ================

class ChatMessage {
  final String id;
  final String role; // 'user' veya 'ai'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addUser(String text) {
    state = [
      ...state,
      ChatMessage(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void addAI(String text, {String? id}) {
    state = [
      ...state,
      ChatMessage(
        id: id ?? 'a-${DateTime.now().millisecondsSinceEpoch}',
        role: 'ai',
        content: text,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void clear() => state = [];
}
