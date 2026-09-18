import 'package:dio/dio.dart';

class AIRepository {
  final Dio dio;

  AIRepository(this.dio);

  // ================ GET /ai/categories ================
  Future<List<Map<String, dynamic>>> getCategories() async {
    final r = await dio.get<Map<String, dynamic>>('/ai/categories');
    final list = (r.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ================ GET /ai/templates ================
  Future<List<Map<String, dynamic>>> getTemplates() async {
    final r = await dio.get<Map<String, dynamic>>('/ai/templates');
    final list = (r.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ================ POST /ai/petition ================
  Future<Map<String, dynamic>> generatePetition({
    required String categoryId,
    required Map<String, dynamic> answers,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/ai/petition',
      data: {'categoryId': categoryId, 'answers': answers},
    );
    return Map<String, dynamic>.from(r.data?['data'] ?? {});
  }

  // ================ POST /ai/email ================
  Future<Map<String, dynamic>> generateEmail({
    required String type,
    required String tone,
    required String language,
    required String context,
    String? recipient,
    String? senderName,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/ai/email',
      data: {
        'type': type,
        'tone': tone,
        'language': language,
        'context': context,
        if (recipient != null && recipient.isNotEmpty) 'recipient': recipient,
        if (senderName != null && senderName.isNotEmpty) 'senderName': senderName,
      },
    );
    return Map<String, dynamic>.from(r.data?['data'] ?? {});
  }

  // ================ POST /ai/cv ================
  Future<Map<String, dynamic>> generateCV({
    required Map<String, dynamic> personalInfo,
    required List<Map<String, dynamic>> education,
    required List<Map<String, dynamic>> experience,
    required List<String> skills,
    String? templateId,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/ai/cv',
      data: {
        'personalInfo': personalInfo,
        'education': education,
        'experience': experience,
        'skills': skills,
        if (templateId != null) 'templateId': templateId,
      },
    );
    return Map<String, dynamic>.from(r.data?['data'] ?? {});
  }

  // ================ POST /ai/ocr/analyze ================
  Future<Map<String, dynamic>> analyzeOCR({
    required String ocrText,
    String? customInstructions,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/ai/ocr/analyze',
      data: {
        'ocrText': ocrText,
        if (customInstructions != null && customInstructions.isNotEmpty)
          'customInstructions': customInstructions,
      },
    );
    return Map<String, dynamic>.from(r.data?['data'] ?? {});
  }

  // ================ POST /ai/chat ================
  Future<Map<String, dynamic>> chat({
    required String userMessage,
    List<Map<String, dynamic>>? history,
    String? conversationId,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/ai/chat',
      data: {
        'userMessage': userMessage,
        if (history != null && history.isNotEmpty) 'history': history,
        if (conversationId != null && conversationId.isNotEmpty)
          'conversationId': conversationId,
      },
    );
    return Map<String, dynamic>.from(r.data?['data'] ?? {});
  }

  // ================ GET /ai/documents ================
  Future<List<Map<String, dynamic>>> getUserDocuments({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null && type.isNotEmpty) params['type'] = type;
    final r = await dio.get<Map<String, dynamic>>(
      '/ai/documents',
      queryParameters: params,
    );
    final list = (r.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ================ GET /ai/favorites ================
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final r = await dio.get<Map<String, dynamic>>('/ai/favorites');
    final list = (r.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ================ POST /ai/favorites/toggle ================
  Future<Map<String, dynamic>> toggleFavorite({
    required String documentId,
    required String documentType,
  }) async {
    final r = await dio.post<Map<String, dynamic>>(
      '/ai/favorites/toggle',
      data: {'documentId': documentId, 'documentType': documentType},
    );
    return Map<String, dynamic>.from(r.data?['data'] ?? {});
  }

  // ================ GET /ai/chat/conversations ================
  Future<List<Map<String, dynamic>>> getConversations() async {
    final r = await dio.get<Map<String, dynamic>>('/ai/chat/conversations');
    final list = (r.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ================ GET /ai/chat/conversations/:id ================
  Future<List<Map<String, dynamic>>> getConversationMessages(
    String conversationId,
  ) async {
    final r = await dio.get<Map<String, dynamic>>(
      '/ai/chat/conversations/$conversationId',
    );
    final list = (r.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
