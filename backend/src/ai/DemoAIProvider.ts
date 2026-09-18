import { AIProvider, AIResponse, AIStreamChunk } from "./AIProvider";

const DEMO_PETITION = `AD, SOYAD: [Tam Adınız]
TC KİMLİK NO: [XXXXXXXXXXX]
ADRES: [İlçe / İl / Açık Adres]
TEL: [05XX XXX XX XX]
E-POSTA: [email@example.com]

T.C.
[İlgili Kurum/İlçe] [Daire Başkanlığı/Müdürlüğü]
[Adres]

KONU: [Başvuru Konusu] — talebiniz için dilekçe

DEĞERLİ KURUL;

Yazar tarafımca, yukarıda adresi belirtilen [İlgili Kurum] nezdinde, aşağıda detaylarını açıkladığım talep / şikâyet / başvurunun, ilgili mevzuat hükümleri çerçevesinde incelenerek tarafıma sonuçlandırılmasını talep ederim.

AÇIKLAMA:

1. Temel Bilgiler ve Olayların Gelişimi
   — Şahıs/kurum bilgileri ve başvuru konusu ile ilgili ilk temas / işlem tarihi: [GG.AA.YYYY]
   — Gerekçe ve mevzuat dayanağı (varsa ilgili kanun madde, yönetmelik veya tebliğ): ilgili kamu hizmeti mevzuatı
   — Önceden yapılmış başvuru / dilekçe / yazışma varsa (numara ve tarih ile): [Numara / Tarih]

2. Şikâyet / Talep / Başvuru Konusu
   — Süreç içinde ortaya çıkan haksız uygulama / ihmal / eksik işlem: [Açıklama]
   — Başvuruya konu olan hak / menfaat / hizmet: [Açıklama]
   — İlgili belgeler (fiil durum, kanıt, fotoğraf, dekont, vs.): Eklerdedir.

3. Dayanak ve Kanıtlar
   — İlgili mevzuat / yönetmelik / genelge maddeleri
   — Dekont, fatura, rapor, fotoğraf, iletişim kayıtları vb. belgeler
   — Tanık bilgileri (varsa): Ad-Soyad, İletişim

TALEP:
Yukarıda açıklanan nedenlerle;
a) [Talep edilen işlemin tanımı] tarafımca yerine getirilmesini,
b) Başvuruma ilişkin sonucun [15] gün içinde yazılı olarak tarafıma bildirilmesini,
c) Aksi bir sonuçlanma halinde haklı yasal yollara başvurma hakkımı saklı tuttuğumu,
kurumunuz tarafından bilgilerinize arz ederim.

DAYANAK NOKTALARI:
— Anayasa ve ilgili kamu hizmeti mevzuatı hükümleri
— İlgili yazışma / dekont / rapor ve ekler listesi

EK LİSTESİ:
1. Nüfus Cüzdanı / T.C. Kimlik Kartı fotokopisi
2. İlgili dekont / fatura / rapor fotokopisi
3. Varsa fotoğraf / görsel kanıtlar
4. Varsa önceki yazışmalar / dilekçeler nüshası

GEREĞİNİ yapılması ve sonuçlandırılmasını arz ederim.

[Şehir], [GG.AA.YYYY]

Saygılarımla,
[Ad SOYAD]
[İmza]

NÜSHA:
— Başvuru sahibinde (kayıt altındadır)
— Kurum / Daire arşivi
`;

const DEMO_EMAIL = `Konu: [Konu Başlığı] — Resmi Yazışma

Sayın [Alıcı Unvan / Ad Soyad],

Bu e-posta, [açıklama: başvuru, teşekkür, bilgi, itiraz, teklif vb.] amacıyla tarafıma iletilmek üzere hazırlanmıştır.

1. Konu Hakkında Genel Bilgi
   — İşlem / hizmet / proje: [Açıklama]
   — İlgili tarih ve referans: [GG.AA.YYYY / Ref: XXX]
   — Taraf (gönderen / alıcı / 3. kişiler): [Açıklama]

2. Detaylı Açıklama
   — Neden / amaç / talep: [Paragraf 1]
   — Süreç ve gelişmeler: [Paragraf 2]
   — Beklenti / sonuç / sorumluluk: [Paragraf 3]

3. Ekler ve Kanıtlar
   — PDF / görsel / tablo / rapor: [Liste]
   — Referans dokümanlar: [Numara / Tarih]

4. Sonuç ve Talepler
   a) [Talep 1]
   b) [Talep 2]
   c) [GG.AA.YYYY] tarihine kadar yazılı / sözlü dönüş yapılması

Uygun ve hızlı sonuçlanması dileğiyle, değerli zamanınız için teşekkür ederim. Eklerim dikkatinize sunulur.

Saygılarımla,
[Ad SOYAD]
[Pozisyon / Ünvan]
[Şirket / Kurum]
📞 [05XX XXX XX XX] | 📧 [email@example.com]
🔗 [LinkedIn / Web sitesi (opsiyonel)]
`;

const DEMO_CV = `
─────── ✦ AD SOYAD ✦ ───────
Kıdemli [Pozisyon] Profesyoneli | [Şehir]
📞 05XX XXX XX XX   |   ✉️ email@example.com   |   🔗 linkedin.com/in/kullanici
📍 [İlçe / İl]   |   🚗 Sürücü Belgesi: [Var/Yok]

▌ PROFESYONEL ÖZET (ATS)
Son [X]+ yıl [Sektör] sektöründe uçtan uca proje yönetimi, [Teknoloji/Alan] uzmanlığı ve ekip liderliği deneyimine sahip, analitik düşünce yapılı ve sonuca odaklı profesyonel. Stratejik hedefler ile operasyonel realiteyi birleştiren, maliyet optimizasyonu (%X), verimlilik artışları (X%) ve müşteri memnuniyeti (X/10) sağlayan kanıtlanmış bir başarı geçmişine sahiptir.

▌ TEMEL YETKİNLİKLER
• Teknik: [Teknoloji 1], [Teknoloji 2], [Teknoloji 3], [Teknoloji 4]
• Yönetim: Proje Yönetimi, Bütçe & Risk, Ekip Liderliği (Kişi X)
• Fonksiyonel: Strateji, Operasyon, Veri Analizi, Müşteri Ilişkileri
• Diller: Türkçe (Ana dil), İngilizce (C1 / Aktif İş), [Dil 3] (B2)

▌ İŞ DENEYİMLERI

🔹 [Şirket Adı 1] — [Pozisyon]                [GG.AA.YYYY] - [GG.AA.YYYY / Halen]
   [Şehir / Uzaktan]
   • [STAR 1]: [Durum — görev — eylem — sonuç] | Etki: [X%] artış / [₺X] tasarruf
   • [STAR 2]: [Durum — görev — eylem — sonuç] | Etki: [X] müşteri / [X] ekip üyesi
   • [STAR 3]: [Durum — görev — eylem — sonuç] | Etki: [X] proje / [X] hafta erken teslim

🔹 [Şirket Adı 2] — [Pozisyon]                [GG.AA.YYYY] - [GG.AA.YYYY]
   • [STAR 1]: [Durum — görev — eylem — sonuç] | Etki: [X%] kalite / [X%] maliyet
   • [STAR 2]: [Durum — görev — eylem — sonuç] | Etki: [X] rapor / [X] toplantı

▌ EĞİTİM BİLGİSİ

🎓 [Üniversite Adı] — [Bölüm]                [GG.AA.YYYY] - [GG.AA.YYYY]
   Lisans / [Yüksek Lisans] — GNO: [X,XX / 4,00]
   • Başarılar: [Öğrenci Kulübü, Tez Konusu, Onur Listesi]

▌ SERTİFİKALAR & EĞİTİMLER
• [Sertifika 1] — [Veren Kurum] | [YYYY]
• [Sertifika 2] — [Veren Kurum] | [YYYY]
• [Eğitim / Kurs] — [Kurum]     | [YYYY]

▌ PROJELER (Opsiyonel)
• [Proje Adı]: [1-2 cümle açıklama + teknoloji + etki]
• [Proje Adı]: [1-2 cümle açıklama + teknoloji + etki]

▌ REFERANSLAR
Talep edilmesi halinde tarafınıza sunulacaktır.

── OfficialAI v1.0 ATS Optimize Özgeçmiş ──
`;

const DEMO_OCR = `
📋 1. ÖZET
Belge/metin, [tür: sözleşme, fatura, rapor, mektup vb.] niteliğindedir. Ana konu: [1 cümle özet]. Toplam [X] sayfa / [X] paragraf.

🔑 2. ANAHTAR KELİMELER & KAVRAMLAR
• [Kelime 1] — [Kısa açıklama / bağlam]
• [Kelime 2] — [Kısa açıklama / bağlam]
• [Kelime 3] — [Kısa açıklama / bağlam]
• [Kelime 4] — [Kısa açıklama / bağlam]
• [Kelime 5] — [Kısa açıklama / bağlam]

📌 3. ÖNEMLİ DETAYLAR (Tarih / Para / Taraflar / Numaralar)
• Tarih: [GG.AA.YYYY] (son başvuru / imza / vade)
• Tutar: [₺XXXX,XX] / [€XXXX] / [%X] — [açıklama]
• Taraflar: [Taraf 1] — [Taraf 2] — [Tanık / 3. Kişi]
• Referans / Fatura / Sözleşme No: [REF-XXXX-YYYY]
• Diğer kritik alan: [Açıklama]

✅ 4. EYLEM NOKTALARI (Yapılacaklar Listesi)
□ Adım 1 — [Açıklama] | Sorumlu: [Kişi/Departman] | Son: [GG.AA.YYYY]
□ Adım 2 — [Açıklama] | Sorumlu: [Kişi/Departman] | Son: [GG.AA.YYYY]
□ Adım 3 — [Açıklama] | Sorumlu: [Kişi/Departman] | Son: [GG.AA.YYYY]
□ Adım 4 — [Açıklama] | Sorumlu: [Kişi/Departman] | Son: [GG.AA.YYYY]

⚠️ 5. RİSKLER VE UYARILAR
• Yüksek Risk: [Açıklama + önerilen önlem]
• Orta Risk:   [Açıklama + önerilen önlem]
• Dikkat:      [Eksik bilgi / imza / dekont uyarısı]

💡 6. ÖNERİLER VE SONUÇ DEĞERLENDİRMESİ
1. [Öneri 1 — gerekçe + beklenen fayda]
2. [Öneri 2 — gerekçe + beklenen fayda]
3. [Öneri 3 — gerekçe + beklenen fayda]
Genel sonuç: [olumlu / şartlı / riskli] — özet: [2 cümle karar]
`;

const DEMO_CHAT_INTRO = `Merhaba 👋 Ben OfficialAI. Türkçe resmi yazışma, dilekçe, özgeçmiş, OCR analiz ve genel sorular konusunda sana yardımcı olabilirim. Ne hakkında destek almak istersin?\n\n• Resmi dilekçe, dava dilekçesi, başvuru metni\n• E-posta taslakları (resmi, satış, pazarlama, özür vb.)\n• ATS uyumlu CV/özgeçmiş hazırlama\n• Bir belgeyi yükle → özet, anahtar kelime, eylem, risk analizi\n• Genel sorular, bilgi, danışma`;

type ScoredKind = { kind: "petition" | "email" | "cv" | "ocr" | "chat"; score: number };

const PETITION_RULES: [RegExp, number][] = [
  [/(?:resmi\s+)?dilek(?:çe)?|dava\s+dilek/i, 5],
  [/başvur(?:u|mak)?|başka\s+alın|müdür(?:lük)?|kaymakam(?:lık)?|belediye/i, 4],
  [/muhatap\s+kim/i, 3],
  [/kurum\s+ne|kuruma\s+yazıl|hükümet|kamu\s+hizmet/i, 3],
  [/t\.c\.|sayın\s+(?:vali|müdür|kaymakam|belediye|bakan)/i, 4],
  [/ad\s+soyad\s+tc\s+kimlik|imz|ek\s+listes/i, 3],
  [/petition/i, 4],
];

const EMAIL_RULES: [RegExp, number][] = [
  [/e-?posta|e-posta\s+taslak|email|mail\s+gönder/i, 6],
  [/konu\s*:|subject\s*:|sayın\s+[a-zçğıöşü]{3,}\s*,/i, 4],
  [/saygılarımla|saygılarla|best\s+regards/i, 4],
  [/(?:resmi|iş|özel|akademik|başvuru)\s+e-?posta/i, 5],
  [/alıcı\s+kim|gönderen\s+ad|alıcı\s+unvan|muhatap\s+e-?posta/i, 4],
  [/ton\s*:|tone\s*:|üslup|dil\s*:\s*(tr|en|türkçe|ingilizce)/i, 3],
];

const CV_RULES: [RegExp, number][] = [
  [/özgeçmiş|özgecmis|cv\b|resume|curriculum\s+vitae|özgeçmiş\s+hazır/i, 7],
  [/iş\s+deneyim|iş\s+geçmişi|deneyim\s+kartı|yıldız\s+iş/i, 4],
  [/eğitim\s+bilgi|mezun|üniversite|lise|gno|not\s+ortalam/i, 4],
  [/yetenekler?\s+listes|skill|yabancı\s+dil|dil\s+seviye/i, 4],
  [/başarı\s+hikaye|cv\s+şablon|ats\s+format|özgeçmiş\s+formatı/i, 5],
  [/ad\s+soyad.*pozisyon|pozisyon.*pozisyon|profil\s+özett/i, 3],
];

const OCR_RULES: [RegExp, number][] = [
  [/ocr\s+anal|taranan\s+metin|tara|scanner|scanned|tanıma/i, 6],
  [/belge\s+yükle|fotoğraf\s+anal|döküman\s+özet|metin\s+çıkar/i, 5],
  [/anahtar\s+kelime|risk\s+anal|eylem\s+adım|özetle|kısa\s+özet/i, 5],
  [/fatura\s+özet|sözleşme\s+özet|ceza\s+bildir|tutar.*tl|tarih.*\.20/i, 3],
  [/t\.?c\.?\s*kimlik|tc\s*no|vade\s+tarih|son\s+başvuru/i, 3],
];

const CHAT_RULES: [RegExp, number][] = [
  [/(?:^|[\s.,!?])(merhaba|selam(?:ünaleyküm)?|naber|ne\s+haber|iyi\s+günler|iyi\s+akşamlar|günaydın|iyi\s+geceler|kolay\s+gelsin|hoş\s+ça\s+kal)(?:[\s.,!?]|$)/i, 6],
  [/nasılsın|kimsin|sen\s+kim(?:sin)?|kendini\s+tanıt|tanıtır\s+mısın|özgeçmişin\s+ne/i, 6],
  [/ne\s+yardım|ne\s+yapabilirsin|yapabileceklerin|nelere\s+bakıyorsun|hizmetlerin|özelliklerin|neler\s+yaparsın/i, 5],
  [/yardım\s+et|bilgi\s+ver|açıkla|öğret|öneri\s+ver|öner\s+al|öyle\s+yap|bunu\s+nasıl/i, 3],
  [/teşekkür|sağol|eyvallah|tamam\s+devam|anladım|peki|harika|süper|mükemmel/i, 4],
  [/anlatır\s+mısın|özetle\s+geç|kısaca|hızlıca|acaba|merak\s+ediyorum/i, 3],
];

function scoreText(text: string, rules: [RegExp, number][]): number {
  let total = 0;
  for (const [re, pts] of rules) if (re.test(text)) total += pts;
  return total;
}

function smartMockFromPrompt(systemPrompt: string, userPrompt: string): string {
  const system = systemPrompt.toLowerCase();
  const prompt = userPrompt.toLowerCase();
  const promptOnlyScore = (kind: ScoredKind["kind"]) => {
    const rules =
      kind === "petition" ? PETITION_RULES :
      kind === "email"    ? EMAIL_RULES :
      kind === "cv"       ? CV_RULES :
      kind === "ocr"      ? OCR_RULES :
      CHAT_RULES;
    return scoreText(prompt, rules) * 2 + scoreText(system, rules);
  };

  const scores: ScoredKind[] = [
    { kind: "petition", score: promptOnlyScore("petition") },
    { kind: "email", score: promptOnlyScore("email") },
    { kind: "cv", score: promptOnlyScore("cv") },
    { kind: "ocr", score: promptOnlyScore("ocr") },
    { kind: "chat", score: promptOnlyScore("chat") },
  ];

  if (system.length > 20) {
    if (/dilek/i.test(system)) scores.find((s) => s.kind === "petition")!.score += 2;
    if (/e-?posta|email/i.test(system)) scores.find((s) => s.kind === "email")!.score += 2;
    if (/özgeçmiş|cv|cv\s+sistemi|resume/i.test(system)) scores.find((s) => s.kind === "cv")!.score += 2;
    if (/ocr|metin\s+anal|döküman\s+anal/i.test(system)) scores.find((s) => s.kind === "ocr")!.score += 2;
    if (/sohbet|chat|yardım\s+asistan|genel\s+sorular|kullanıcının\s+sorusu/i.test(system)) scores.find((s) => s.kind === "chat")!.score += 3;
  }

  scores.sort((a, b) => b.score - a.score);
  const best = scores[0];
  const second = scores[1];

  if (best.score > 0 && best.score >= second.score) {
    if (best.kind === "petition") return DEMO_PETITION;
    if (best.kind === "email") return DEMO_EMAIL;
    if (best.kind === "cv") return DEMO_CV;
    if (best.kind === "ocr") return DEMO_OCR;
    if (best.kind === "chat") return DEMO_CHAT_INTRO;
  }

  const fallbackHeader =
    "▶ Soru / İstek: " +
    (prompt.length
      ? prompt.slice(0, 160) + (prompt.length > 160 ? "…" : "")
      : userPrompt.slice(0, 160)) +
    "\n\n OfficialAI DEMO Mod Yanıtı — bu yanıt API anahtarı olmadan üretilmiştir:\n\n";

  return (
    fallbackHeader +
    "1. Konu: İsteğiniz doğrultusunda ön analiz yapıldı. " +
    (best.kind !== "chat" ? `En uygun kategori: ${best.kind.toUpperCase()}.\n` : "\n") +
    "2. Öneriler: Detaylar ve format resmi yazışma kurallarına uygun olarak yapılandırıldı.\n" +
    "   • Adım 1 — Hedef / gerekçe tanımlaması yapıldı\n" +
    "   • Adım 2 — Format ve kanıt belgeleri önerildi\n" +
    "   • Adım 3 — Sonuçlandırma ve iletişim adımları\n\n" +
    "3. Sonuç ve Uygulanabilirlik: Yukarıdaki maddeler ışığında süreci başlatmak için gerekli\n" +
    "   dokümanlar, yetki ve iletişim bilgileri hazırlanmalıdır.\n\n" +
    "4. Sonraki Adım: Daha detaylı / kişiselleştirilmiş çıktı almak için lütfen Gemini API\n" +
    "   anahtarınızı (.env → GEMINI_API_KEY) tanımlayınız.\n\n" +
    "Teşekkürler.\n— OfficialAI Demo (ücretsiz sunum modu)"
  );
}

export class DemoAIProvider implements AIProvider {
  async generate(systemPrompt: string, userPrompt: string): Promise<AIResponse> {
    const startTime = Date.now();
    const simDelay = 350 + Math.floor(Math.random() * 700);
    await new Promise((res) => setTimeout(res, simDelay));
    return {
      content: smartMockFromPrompt(systemPrompt, userPrompt),
      processingTime: Date.now() - startTime,
      tokensUsed: 0,
    };
  }

  async *generateStream(
    systemPrompt: string,
    userPrompt: string
  ): AsyncGenerator<AIStreamChunk> {
    const startTime = Date.now();
    const full = smartMockFromPrompt(systemPrompt, userPrompt);
    const chunkSize = 48;
    let i = 0;
    while (i < full.length) {
      await new Promise((r) => setTimeout(r, 28));
      const chunk = full.slice(i, i + chunkSize);
      i += chunkSize;
      yield {
        content: chunk,
        processingTime: Date.now() - startTime,
        done: false,
      };
    }
    yield {
      content: "",
      processingTime: Date.now() - startTime,
      done: true,
    };
  }
}
