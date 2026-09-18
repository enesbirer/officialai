# OfficialAI Tam Uygulama Planı

## Repository Araştırma Sonuçları

### Mevcut Durum Analizi
- **Backend (Node.js/Express/TypeScript/Prisma/PostgreSQL)**:
  - Temel kimlik doğrulama (JWT + bcrypt) mevcut
  - AI Provider sadece Google Gemini ile çalışıyor (ücretsiz katman mevcut)
  - AI promptları çok basit - Türk resmi dile uygun değil
  - Petition/Email/CV endpointleri var ama kaliteli çıktı üretmiyor
  - Chat endpoint eksik
  - PDF oluşturma client tarafında, storage entegrasyonu boş

- **Frontend (Flutter/Riverpod/GoRouter)**:
  - Tema çok basit, standart Material 3 mavi tema
  - **Çoğu ekran placeholder**: PetitionScreen, EmailScreen, CVScreen, ChatScreen, ScannerScreen, HistoryScreen, FavoritesScreen, ProfileScreen, SettingsScreen sadece `Center(Text(...))` gösteriyor
  - Dashboard'da sadece Quick Action kartları var, veri yok
  - Login/Register ekranları kısmi fonksiyonel
  - Hiçbir özellik backend API ile tam entegre değil
  - Glassmorphism / buzlu cam efekti **tamamen yok**

- **Mevcut Teknoloji Yığını (Ücretsiz/Olması Gerekenler)**:
  - ✅ Google Gemini Free Tier (15 RPM, ücretsiz)
  - ✅ Google ML Kit Text Recognition (cihaz üstü, ücretsiz)
  - ✅ Hive/Flutter Secure Storage (local, ücretsiz)
  - ✅ printing/pdfx package (cihaz üstü PDF, ücretsiz)
  - ❌ Firebase/Google SignIn (Amazon Appstore için GMS bağımlılığı yaratır) - kaldırılmalı
  - ⚠️ Cloudinary (ücretsiz katman var ama local storage fallback eklenmeli)

## Değiştirilecek Dosyalar ve Modüller

### Backend
- `backend/src/prompts/promptTemplates.ts`: Türk resmi dile uygun detaylı promptlar
- `backend/src/prompts/PromptBuilder.ts`: Kategori bazlı şablon desteği
- `backend/src/services/ai/AIService.ts`: Chat endpoint + streaming + daha iyi response işleme
- `backend/src/controllers/ai/AIController.ts`: Chat + OCR analiz endpointleri
- `backend/src/routes/aiRoutes.ts`: Yeni endpointler
- `backend/src/ai/GeminiProvider.ts`: Streaming desteği, retry mantığı
- `backend/prisma/schema.prisma`: Seed data + gerekli küçük düzeltmeler
- `backend/src/config/index.ts`: CORS düzenlemesi, mobil desteği
- `backend/src/services/storage/StorageService.ts`: Local storage fallback + Cloudinary
- `backend/src/server.ts`: Seed data çalıştırma
- Yeni: `backend/prisma/seed.ts`: Petition kategorileri ve şablonları

### Frontend - Tema & UI (Glassmorphism Buzlu Cam)
- `frontend/lib/core/theme/app_theme.dart`: Tamamen yeniden - buzlu cam teması
- `frontend/lib/core/theme/glass_container.dart` (YENİ): Glassmorphism widget
- `frontend/lib/core/theme/glass_background.dart` (YENİ): Buzlu arka plan gradient
- `frontend/lib/widgets/bottom_nav_bar.dart`: Glass efektli bottom nav
- `frontend/lib/widgets/primary_button.dart`: Glass buton
- `frontend/lib/widgets/custom_text_field.dart`: Glass input alanı

### Frontend - Tam Ekrankı Tamamlama
- `frontend/lib/features/dashboard/screens/dashboard_screen.dart`: İstatistikler + son dökümanlar
- `frontend/lib/features/petition/screens/petition_screen.dart`: Kategori seçimi + form + AI sonuç + PDF
- `frontend/lib/features/email/screens/email_screen.dart`: Email form + AI sonuç
- `frontend/lib/features/cv/screens/cv_screen.dart`: Çok adımlı CV form + AI sonuç
- `frontend/lib/features/chat/screens/chat_screen.dart`: Streaming AI sohbet
- `frontend/lib/features/scanner/screens/scanner_screen.dart`: ML Kit OCR + AI analiz
- `frontend/lib/features/history/screens/history_screen.dart`: Döküman geçmişi
- `frontend/lib/features/favorites/screens/favorites_screen.dart`: Favoriler listesi
- `frontend/lib/features/profile/screens/profile_screen.dart`: Kullanıcı profili
- `frontend/lib/features/settings/screens/settings_screen.dart`: Dil, tema, bildirimler
- `frontend/lib/features/auth/screens/register_screen.dart`: Glass temalı kayıt
- `frontend/lib/screens/splash_screen.dart`: Animasyonlu açılış
- `frontend/lib/screens/onboarding_screen.dart`: Kullanıcı tanıtım
- `frontend/lib/providers/auth_provider.dart`: Backend entegrasyonu
- `frontend/lib/core/utils/dio_client.dart`: Auth header + interceptor
- `frontend/lib/repositories/auth_repository.dart`: Backend API çağrıları
- Yeni: `frontend/lib/repositories/ai_repository.dart`: AI feature repository
- Yeni: `frontend/lib/providers/ai_provider.dart`: AI state management

## Uygulama Adımları (Bağımlılık Sırasıyla)

### Aşama 1: Backend Geliştirme (Önce olmalı - Frontend buna bağlı)
1. **Prompt İyileştirme**: Türk resmi dile uygun, kategorili detaylı prompt şablonları hazırla
   - Dava dilekçeleri, başvurular, tebliğler, itirazlar için özel formatlar
   - Resmi Türkçe kelime dağarcığı, saygı ifadeleri, kanun referansları
2. **GeminiProvider İyileştirme**: Retry mantığı, streaming generation desteği
3. **AIService + Controller**: Chat endpoint, OCR'dan metin analiz endpointi ekle
4. **Prisma Seed Data**: Yaygın petition kategorilerini (iş, eğitim, sağlık, belediye, hukuk) ve şablonları veritabanına ekle
5. **Storage Service**: Local disk fallback + Cloudinary opsiyonel
6. **CORS & Config**: Mobil origin desteği, güvenlik headerları
7. **Hata Yönetimi**: Daha detaylı kullanıcı dostu hata mesajları

### Aşama 2: Flutter Tema & Glassmorphism UI Sistemi
8. **AppTheme Yeniden**: Buzlu mavi / buzlu lacivert gradient arka plan
   - Light mode: Buzlu beyaz + açık mavi tonlar, ince blur
   - Dark mode: Buzlu lacivert + gece mavisi, stronger blur
9. **GlassContainer Widget**: `BackdropFilter(ImageFilter.blur)` + yarı şeffaf gradient kenarlık
10. **Shared Widgetlar**: Glass buton, glass input, glass card, glass bottom nav bar

### Aşama 3: Auth Akışı + Core Providers
11. **AuthRepository + AuthProvider**: Backend /login, /register, /refresh, /logout bağlantısı
12. **DioClient**: JWT header ekleme, 401'de otomatik refresh, logout
13. **Router**: Auth guard - giriş yapmamış kullanıcıyı /login'e yönlendir
14. **Login/Register Ekranları**: Glass temalı, loading state, hata gösterimi

### Aşama 4: Feature Ekranları (Backend API ile)
15. **Dashboard**: Kullanıcı İstatistikleri (kaç döküman oluşturuldu), Son Dökümanlar, Quick Actions
16. **Petition Generator**:
    - Adım 1: Kategori seçimi (seed'den gelen kategoriler)
    - Adım 2: Kategoriye göre dinamik soru formu
    - Adım 3: AI'dan sonuç, text field içinde düzenlenebilir
    - Adım 4: Favorilere ekle, PDF oluştur, Paylaş
17. **Email Generator**: Tip (resmi/özel), Ton (resmi/dostça), Dil (TR/EN), İçerik → AI Sonuç
18. **CV Builder**: Kişisel Bilgiler → Eğitim → Deneyim → Yetenekler → AI ile ATS uyumlu CV
19. **AI Chat**: Streaming mesajlaşma, önceki mesajları context olarak gönderme
20. **Scanner**: Resim çek/seç → ML Kit OCR → Türkçe metin çıkar → AI ile analiz/özet/düzeltme

### Aşama 5: History, Favorites, Profile, Settings
21. **History Screen**: Tüm oluşturulan dökümanlar (petition/email/cv) tip filtreli liste
22. **Favorites Screen**: Favorilenen dökümanlar
23. **Profile Screen**: Kullanıcı bilgileri, tema/dil tercihleri
24. **Settings Screen**: Dil (TR/EN), Tema (Açık/Koyu), Hakkında, Gizlilik, Çıkış

### Aşama 6: Doğrulama & Test
25. Backend: `npm install && npx prisma generate && npx prisma migrate dev && npm run seed && npm run dev` - health check + tüm endpointleri test et
26. Frontend: `flutter pub get && flutter pub run build_runner build` - analiz, lint, derleme kontrol
27. Her ekranı manuel olarak kontrol et: Login → Dashboard → Petition → PDF → History → Favorites → Profile → Settings → Chat → Scanner

## Bağımlılıklar ve Dikkat Edilecekler

- **Ücretsiz API Politikası (Amazon Appstore İçin Kritik)**:
  - ✅ Google Gemini Free tier kullan (ücretsiz 15 RPM) - production'da limitleri yönet
  - ✅ Google ML Kit OCR tamamen cihaz üstünde çalışır, sunucu maliyeti yok
  - ✅ PDF oluşturma `printing` paketi ile cihaz üstünde, sunucu maliyeti yok
  - ❌ Firebase Auth çıkarılıp sadece email/password JWT auth kullanılacak (GMS bağımlılığı nedeniyle Amazon Appstore sorun çıkarır)
  - ⚠️ Cloudinary ücretsiz katman kullanılabilir, ama fallback olarak yerel storage olsun
  - ⚠️ Email doğrulama SMTP olmadan - development'ta log'a yaz, production'da ücretsiz SMTP (Brevo/SendGrid free tier)

- **Amazon Appstore Uyumluluğu**:
  - Google Mobile Services (GMS) bağımlılığı olmayan paketleri tercih et
  - firebase_core ve firebase_auth çıkarılmalı
  - google_sign_in çıkarılmalı (Amazon Login entegrasyonu istenirse sonradan eklenir)

- **Performans**:
  - Buzlu cam efekti (BackdropFilter) pahalıdır; `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` tutarlı kullan
  - Çoklu glass container kullanımında dikkatli ol, performansı test et

## Doğrulama (Validation)

### Backend Doğrulaması
- [ ] `npm install` başarılı
- [ ] PostgreSQL çalışıyor, `npx prisma migrate dev` başarılı
- [ ] Seed data çalıştı - kategoriler eklendi
- [ ] `npm run dev` başladı, `/health` endpoint `{"status":"OK"}` dönüyor
- [ ] `/api/v1/auth/register` → login → `/api/v1/ai/petition` akışı çalışıyor
- [ ] AI cevapları Türkçe, resmi dile uygun ve detaylı geliyor

### Frontend Doğrulaması
- [ ] `flutter pub get` başarılı
- [ ] `flutter analyze` 0 error, 0 warning (veya çok düşük)
- [ ] `flutter build apk --debug` başarılı derleniyor
- [ ] Chrome'da test: Splash → Onboarding → Login/Register → Dashboard → tüm feature ekranları
- [ ] Tüm ekranlarda glass buzlu görünüm tutarlı
- [ ] AI ile oluşturulan içerikler ekranda gösteriliyor, PDF oluşuyor
- [ ] Favorilere ekleme / geçmişe kaydetme çalışıyor

## Riskler ve Çözümler

- **Risk: Gemini Free Tier Rate Limit** → Çözüm: Client-side rate limit + retry with backoff, aşım durumunda kullanıcıya bilgi ver
- **Risk: PostgreSQL çalışmıyor** → Çözüm: SQLite fallback veya development'ta env değişkeni ile esnek bağlantı
- **Risk: Glassmorphism düşük cihazlarda performans** → Çözüm: Düşük performanslı cihazlarda blur'u otomatik kapat veya reduce motion ile
- **Risk: Amazon Appstore GMS reddi** → Çözüm: Firebase/google_sign_in bağımlılıklarını kaldır, saf email/password kullan
- **Risk: AI cevapları kalitesiz** → Çözüm: Prompt engineering detayı, birkaç retry + en iyi cevabı seçme, user feedback loop
