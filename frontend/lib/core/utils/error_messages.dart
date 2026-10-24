import 'package:dio/dio.dart';

/// Teknik/ham hataları kullanıcının anlayacağı sade Türkçe mesajlara çevirir.
///
/// Teknik ayrıntılar (stack trace, SDK mesajları) kullanıcıya gösterilmez;
/// yalnızca ne olduğu ve mümkünse ne yapılması gerektiği anlatılır.
String friendlyErrorMessage(Object error, {String? action}) {
  final what = action ?? 'İşlem';

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Sunucu yanıt vermedi. İnternet bağlantınızı kontrol edip tekrar deneyin.';
      case DioExceptionType.connectionError:
        return 'İnternete bağlanılamadı. Bağlantınızı kontrol edip tekrar deneyin.';
      case DioExceptionType.badCertificate:
        return 'Güvenli bağlantı kurulamadı. Lütfen daha sonra tekrar deneyin.';
      case DioExceptionType.cancel:
        return 'İşlem iptal edildi.';
      case DioExceptionType.badResponse:
        return _messageFromResponse(error.response, what);
      case DioExceptionType.unknown:
        final raw = error.message ?? '';
        if (raw.contains('SocketException') ||
            raw.contains('Failed host lookup') ||
            raw.contains('Connection refused')) {
          return 'İnternete bağlanılamadı. Bağlantınızı kontrol edip tekrar deneyin.';
        }
        return '$what sırasında beklenmeyen bir sorun oluştu. Lütfen tekrar deneyin.';
    }
  }

  final text = error.toString();
  if (text.contains('SocketException') || text.contains('Failed host lookup')) {
    return 'İnternete bağlanılamadı. Bağlantınızı kontrol edip tekrar deneyin.';
  }
  if (text.contains('TimeoutException')) {
    return 'Sunucu yanıt vermedi. Lütfen tekrar deneyin.';
  }
  return '$what tamamlanamadı. Lütfen tekrar deneyin.';
}

String _messageFromResponse(Response<dynamic>? response, String what) {
  final status = response?.statusCode ?? 0;

  // Backend zaten kullanıcı dostu Türkçe mesaj döndürüyorsa onu kullan.
  final data = response?.data;
  if (data is Map && data['message'] is String) {
    final message = (data['message'] as String).trim();
    if (message.isNotEmpty && !_looksTechnical(message)) return message;
  }

  if (status == 400) return 'Girilen bilgilerde eksik veya hatalı alanlar var. Lütfen kontrol edip tekrar deneyin.';
  if (status == 401) return 'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.';
  if (status == 403) return 'Bu işlem için yetkiniz bulunmuyor.';
  if (status == 404) return 'İstenen içerik bulunamadı.';
  if (status == 408 || status == 504) return 'Sunucu yanıt vermedi. Lütfen biraz sonra tekrar deneyin.';
  if (status == 413) return 'Gönderilen içerik çok büyük. Lütfen daha küçük bir içerikle deneyin.';
  if (status == 422) return 'Girilen bilgiler işlenemedi. Lütfen bilgileri kontrol edip tekrar deneyin.';
  if (status == 429) return 'Çok fazla istek gönderildi. Lütfen biraz bekleyip tekrar deneyin.';
  if (status >= 500) return 'Sunucuda geçici bir sorun oluştu. Lütfen birkaç dakika sonra tekrar deneyin.';
  return '$what tamamlanamadı. Lütfen tekrar deneyin.';
}

/// Ham/teknik görünen mesajları kullanıcıya gösterme.
bool _looksTechnical(String message) {
  final lower = message.toLowerCase();
  return lower.contains('stack') ||
      lower.contains('exception') ||
      lower.contains('prisma') ||
      lower.contains('dio') ||
      lower.contains('syntax') ||
      lower.contains('at /') ||
      message.contains('\n');
}
