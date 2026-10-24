import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Uygulama genelinde tutarlı ve güvenli navigasyon yardımcıları.
///
/// Sorun: `context.go(...)` çağrıldığında mevcut rota yığını tamamen
/// değiştirilir; geri dönülecek bir sayfa kalmaz ve sistem geri tuşu
/// siyah/boş ekrana yol açar. Bu yüzden ileri navigasyonda [pushRoute],
/// geri dönüşte [goBack] kullanılır.
class AppNavigation {
  const AppNavigation._();

  /// İleri navigasyon: sayfayı yığına ekler, geri dönüş her zaman çalışır.
  static void push(BuildContext context, String location) {
    context.push(location);
  }

  /// Geri navigasyon: yığında önceki sayfa varsa ona döner, yoksa
  /// [fallback] ekranına güvenli biçimde yönlendirir (siyah ekranı önler).
  static void back(BuildContext context, {String fallback = '/dashboard'}) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(fallback);
    }
  }

  /// Yığını değiştirir. Yalnızca giriş/çıkış, onboarding ve sekme
  /// geçişleri gibi geri dönülmemesi gereken durumlarda kullanılır.
  static void replace(BuildContext context, String location) {
    context.go(location);
  }
}
