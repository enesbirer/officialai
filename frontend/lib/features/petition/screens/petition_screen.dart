import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pdf_export_utils.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/ai_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/custom_text_field.dart';

// Demo fallback kategoriler (backend çalışmazsa)
const List<Map<String, dynamic>> _fallbackCategories = [
  {
    'id': 'cat_general',
    'name': 'Genel Başvuru Dilekçesi',
    'description': 'Her türlü kuruma yazabileceğiniz genel başvuru şablonu',
    'icon': 'description',
    'fields': [
      {'key': 'muhatap_kurum', 'label': 'Muhatap Kurum', 'required': true, 'type': 'text'},
      {'key': 'basvuru_nedeni', 'label': 'Başvuru Nedeni', 'required': true, 'type': 'text'},
      {'key': 'olay_ve_gerekce', 'label': 'Olay ve Gerekçe (detaylı)', 'required': true, 'type': 'longtext'},
      {'key': 'talep', 'label': 'Neyi Talep Ediyorsunuz', 'required': true, 'type': 'text'},
      {'key': 'ad_soyad', 'label': 'Ad Soyad', 'required': true, 'type': 'text'},
      {'key': 'tc_kimlik', 'label': 'TC Kimlik No (11 hane)', 'required': true, 'type': 'text'},
      {'key': 'adres', 'label': 'Tam Adres', 'required': true, 'type': 'longtext'},
      {'key': 'telefon', 'label': 'Telefon', 'required': false, 'type': 'text'},
      {'key': 'eposta', 'label': 'E-posta', 'required': false, 'type': 'email'},
    ]
  },
  {
    'id': 'cat_job',
    'name': 'İşe İade & İşten Çıkarma',
    'description': 'İş hukuku ile ilgili dilekçeler: işe iade, tazminat, ihbar',
    'icon': 'work',
    'fields': [
      {'key': 'isveren_sirket', 'label': 'İşveren Şirket Adı', 'required': true, 'type': 'text'},
      {'key': 'ise_giris_tarihi', 'label': 'İşe Giriş Tarihi', 'required': true, 'type': 'text'},
      {'key': 'isten_cikis_tarihi', 'label': 'İşten Çıkış Tarihi', 'required': true, 'type': 'text'},
      {'key': 'kidem', 'label': 'Toplam Kıdem (Yıl/Ay)', 'required': true, 'type': 'text'},
      {'key': 'pozisyon', 'label': 'Görev/Pozisyon', 'required': true, 'type': 'text'},
      {'key': 'net_maas', 'label': 'Net Maaş', 'required': true, 'type': 'text'},
      {'key': 'isten_cikma_nedeni', 'label': 'İşten Çıkış Nedeni (Açıklama)', 'required': true, 'type': 'longtext'},
      {'key': 'talep', 'label': 'Talebiniz (işe iade/tazminat vb.)', 'required': true, 'type': 'longtext'},
      {'key': 'ad_soyad', 'label': 'Ad Soyad', 'required': true, 'type': 'text'},
      {'key': 'tc_kimlik', 'label': 'TC Kimlik No', 'required': true, 'type': 'text'},
    ]
  },
  {
    'id': 'cat_traffic',
    'name': 'Trafik & Ceza İtiraz',
    'description': 'Trafik cezası, ehliyet iptali, HGS vs. itiraz dilekçeleri',
    'icon': 'car_crash',
    'fields': [
      {'key': 'ceza_tarihi', 'label': 'Ceza Tarihi', 'required': true, 'type': 'text'},
      {'key': 'ceza_numarasi', 'label': 'Ceza Numarası / Makbuz No', 'required': true, 'type': 'text'},
      {'key': 'plaka', 'label': 'Araç Plakası', 'required': true, 'type': 'text'},
      {'key': 'ceza_maddesi', 'label': 'Ceza Maddesi (5607/..)', 'required': false, 'type': 'text'},
      {'key': 'olay_aciklamasi', 'label': 'Olayın Açıklaması', 'required': true, 'type': 'longtext'},
      {'key': 'itiraz_nedeni', 'label': 'İtiraz Gerekçeniz', 'required': true, 'type': 'longtext'},
      {'key': 'ad_soyad', 'label': 'Ad Soyad', 'required': true, 'type': 'text'},
      {'key': 'tc_kimlik', 'label': 'TC Kimlik No', 'required': true, 'type': 'text'},
      {'key': 'adres', 'label': 'Adres', 'required': true, 'type': 'longtext'},
    ]
  },
  {
    'id': 'cat_landlord',
    'name': 'Kira & Tapu Dilekçesi',
    'description': 'Kiracı-ev sahibi uyuşmazlıkları, tahliye, kira artışı, tapu',
    'icon': 'home',
    'fields': [
      {'key': 'muhatap_kurum', 'label': 'Muhatap (Tahkeme/İcra/Noter)', 'required': true, 'type': 'text'},
      {'key': 'kira_suresi', 'label': 'Kira Süresi / Başlangıç', 'required': true, 'type': 'text'},
      {'key': 'kira_miktari', 'label': 'Kira Bedeli', 'required': true, 'type': 'text'},
      {'key': 'ev_sahibi', 'label': 'Ev Sahibi Ad Soyad', 'required': true, 'type': 'text'},
      {'key': 'kira_sahibi_tc', 'label': 'Kiracı TC', 'required': true, 'type': 'text'},
      {'key': 'konu', 'label': 'Başvuru Konusu (tahliye/kira artışı/tapu..)', 'required': true, 'type': 'text'},
      {'key': 'detaylar', 'label': 'Olay Detayları', 'required': true, 'type': 'longtext'},
      {'key': 'talep', 'label': 'Talep', 'required': true, 'type': 'longtext'},
    ]
  },
  {
    'id': 'cat_education',
    'name': 'Eğitim & Öğrenci Başvurusu',
    'description': 'Kayıt, yatay geçiş, barınma, burs, sınav dilekçeleri',
    'icon': 'school',
    'fields': [
      {'key': 'kurum_adi', 'label': 'Okul/Kurum Adı', 'required': true, 'type': 'text'},
      {'key': 'ogrenci_no', 'label': 'Öğrenci Numara', 'required': false, 'type': 'text'},
      {'key': 'bolum', 'label': 'Bölüm/Program', 'required': false, 'type': 'text'},
      {'key': 'sinif', 'label': 'Sınıf', 'required': false, 'type': 'text'},
      {'key': 'basvuru_konusu', 'label': 'Başvuru Konusu', 'required': true, 'type': 'text'},
      {'key': 'aciklama', 'label': 'Açıklama/Gerekçe', 'required': true, 'type': 'longtext'},
      {'key': 'ad_soyad', 'label': 'Ad Soyad', 'required': true, 'type': 'text'},
      {'key': 'tc_kimlik', 'label': 'TC Kimlik No', 'required': true, 'type': 'text'},
    ]
  },
];

class PetitionScreen extends ConsumerStatefulWidget {
  const PetitionScreen({super.key});

  @override
  ConsumerState<PetitionScreen> createState() => _PetitionScreenState();
}

class _PetitionScreenState extends ConsumerState<PetitionScreen> {
  int _step = 0; // 0: kategori, 1: form, 2: sonuc
  Map<String, dynamic>? _selectedCat;
  String _resultTitle = '';
  final Map<String, TextEditingController> _ctrls = {};
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scroll = ScrollController();
  final TextEditingController _resultCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _scroll.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _cats {
    final asyncCats = ref.read(categoriesProvider);
    if (asyncCats.hasValue && asyncCats.value!.isNotEmpty) {
      return asyncCats.value!;
    }
    return _fallbackCategories;
  }

  void _selectCat(Map<String, dynamic> cat) {
    setState(() {
      _selectedCat = cat;
      _step = 1;
      _ctrls.clear();
      final fields = (cat['fields'] as List?) ?? [];
      for (final f in fields) {
        final key = f['key'].toString();
        _ctrls[key] = TextEditingController();
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final answers = <String, dynamic>{};
    _ctrls.forEach((k, v) => answers[k] = v.text.trim());

    try {
      final catId = _selectedCat?['id'] ?? 'cat_general';
      final result = await ref.read(petitionGenerationProvider.notifier).generate(
            categoryId: catId.toString(),
            answers: answers,
          );
      if (mounted) {
        setState(() {
          _step = 2;
          _resultCtrl.text = (result['content']?.toString()) ?? '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Fallback: demo yanıt
      setState(() {
        _step = 2;
        _resultCtrl.text = _demoPetition(answers, _selectedCat?['name'] ?? '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sunucu yanıtı alınamadı, demo çıktı gösteriliyor: ${e.toString().characters.take(60)}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  String _demoPetition(Map<String, dynamic> a, String catName) {
    final tarih = DateTime.now();
    final adSoyad = a['ad_soyad'] ?? 'AD SOYAD';
    final tc = a['tc_kimlik'] ?? 'XXXXXXXXXXX';
    final muhatap = a['muhatap_kurum'] ?? a['kurum_adi'] ?? 'İLGİLİ KURUM';
    final konu = a['basvuru_nedeni'] ?? a['talep'] ?? a['basvuru_konusu'] ?? a['ceza_maddesi'] ?? 'Konu';
    final detay = a['olay_ve_gerekce'] ?? a['isten_cikma_nedeni'] ?? a['itiraz_nedeni'] ?? a['detaylar'] ?? a['aciklama'] ?? a['konu'] ?? 'Açıklama';
    final talep = a['talep'] ?? a['basvuru_nedeni'] ?? 'Çözüm';
    final adres = a['adres'] ?? 'Açık adres';
    final tel = a['telefon'] ?? '';
    final eposta = a['eposta'] ?? '';

    return '''
T.C.
$muhatap

KONU: $catName - $konu
Tarih: ${tarih.day.toString().padLeft(2, '0')}/${tarih.month.toString().padLeft(2, '0')}/${tarih.year}

$adSoyad
$tc
$adres
${tel.isNotEmpty ? 'Tel: $tel' : ''}
${eposta.isNotEmpty ? 'E-posta: $eposta' : ''}

Sayın Yetkili,

Aşağıda bilgileri belirtilen tarafımdan ilgili konu hakkında başvuruda bulunulmuştur.

$detay

Gerekli yasal mevzuat ve mevcut uygulamalar doğrultusunda aşağıda belirttiğim talebinin yerine getirilmesini, kamu yararı ve hakkaniyet çerçevesinde değerlendirilmesini saygılarımla arz ederim.

TALEP: $talep

Ekler:
1) Kimlik fotokopisi
2) İlgili belgeler (varsa)

$adSoyad
''';
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _resultCtrl.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dilekçe panoya kopyalandı ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _share() async {
    await Share.share(_resultCtrl.text, subject: 'OfficialAI Dilekçe');
  }

  Future<void> _exportPdf() async {
    final text = _resultCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      await PdfExportUtils.exportAndShare(
        title: _resultTitle.isEmpty ? 'Resmi Dilekçe' : _resultTitle,
        subtitle: 'OfficialAI • Dilekçe / Başvuru',
        content: text,
        documentType: 'petition',
        shareSubject: _resultTitle.isEmpty ? 'OfficialAI Dilekçe' : _resultTitle,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF oluşturulamadı, lütfen tekrar deneyin')),
        );
      }
    }
  }

  Future<void> _favorite() async {
    final state = ref.read(petitionGenerationProvider);
    final docId = state.valueOrNull?['petitionId']?.toString() ?? '';
    if (docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dilekçe sunucuda kaydedilmeden favorilere eklenemez'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    ref.read(favoriteToggleProvider((documentId: docId, documentType: 'petition')));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorilere eklendi/çıkarıldı'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success),
      );
    }
  }

  IconData _iconFor(String? name) {
    switch (name) {
      case 'work': return Icons.work_outline_rounded;
      case 'car_crash': return Icons.car_crash_outlined;
      case 'home': return Icons.home_outlined;
      case 'school': return Icons.school_outlined;
      default: return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cats = ref.watch(categoriesProvider);
    final generating = ref.watch(petitionGenerationProvider).isLoading;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dilekçe Üretici'),
        leading: IconButton(
          onPressed: () {
            if (_step == 2) {
              setState(() => _step = 1);
            } else if (_step == 1) {
              setState(() { _step = 0; _selectedCat = null; });
            } else {
              context.go('/dashboard');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: isDark
          ? GlassBackground.iceDarkGradient(child: _body(text, sub, cats, generating, isDark))
          : GlassBackground.iceLightGradient(child: _body(text, sub, cats, generating, isDark)),
    );
  }

  Widget _body(Color text, Color sub, AsyncValue<List<Map>> cats, bool generating, bool isDark) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          children: [
            _stepper(text, sub),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                child: _step == 0
                    ? _catList(cats, text, sub)
                    : _step == 1
                        ? _formBody(text, sub, generating)
                        : _resultBody(text, sub, generating),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepper(Color text, Color sub) {
    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Row(
        children: [
          _stepTile(0, 'Kategori', text, sub),
          Expanded(child: Divider(color: _step >= 1 ? AppColors.icePrimary : sub.withAlpha(80), height: 2)),
          _stepTile(1, 'Form', text, sub),
          Expanded(child: Divider(color: _step >= 2 ? AppColors.icePrimary : sub.withAlpha(80), height: 2)),
          _stepTile(2, 'Sonuç', text, sub),
        ],
      ),
    );
  }

  Widget _stepTile(int i, String label, Color text, Color sub) {
    final active = _step >= i;
    return Column(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.icePrimary : Colors.transparent,
            border: Border.all(color: active ? AppColors.icePrimary : sub.withAlpha(100), width: 1.4),
          ),
          child: Center(
            child: _step > i
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('${i + 1}', style: TextStyle(color: active ? Colors.white : sub, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? text : sub, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _catList(AsyncValue<List<Map>> cats, Color text, Color sub) {
    final list = cats.when(
      data: (d) => d.isEmpty ? _fallbackCategories : d.cast<Map<String, dynamic>>(),
      loading: () => _fallbackCategories,
      error: (_, __) => _fallbackCategories,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori Seçin',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 6),
              Text('Oluşturmak istediğiniz dilekçe türünü seçin',
                  style: TextStyle(color: sub, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...list.map((c) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: GlassContainer(
              borderRadius: 22,
              onTap: () => _selectCat(c),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.iceSecondary, AppColors.icePrimary],
                      ),
                    ),
                    child: Icon(_iconFor(c['icon']?.toString()), color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name']?.toString() ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: text)),
                        const SizedBox(height: 4),
                        Text(c['description']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: sub, fontSize: 12, height: 1.35)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.icePrimary, size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _formBody(Color text, Color sub, bool generating) {
    final catName = _selectedCat?['name'] ?? 'Kategori';
    final fields = ((_selectedCat?['fields'] as List?) ?? []).cast<Map<String, dynamic>>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(catName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: text)),
                const SizedBox(height: 6),
                Text('Lütfen tüm zorunlu alanları doldurun', style: TextStyle(color: sub, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...fields.map((f) {
            final key = f['key'].toString();
            final ctrl = _ctrls[key] ??= TextEditingController();
            final label = f['label']?.toString() ?? key;
            final required = f['required'] == true;
            final type = f['type']?.toString() ?? 'text';
            final isLong = type == 'longtext';
            final isEmail = type == 'email';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: CustomTextField(
                controller: ctrl,
                label: required ? '$label *' : label,
                hint: label,
                prefixIcon: Icons.edit_note_rounded,
                maxLines: isLong ? 5 : 1,
                minLines: isLong ? 3 : 1,
                keyboardType: isEmail ? TextInputType.emailAddress : (isLong ? TextInputType.multiline : TextInputType.text),
                validator: (v) {
                  if (required && (v == null || v.trim().isEmpty)) {
                    return 'Bu alan zorunlu';
                  }
                  if (isEmail && v != null && v.isNotEmpty && !AppConfig.emailRegex.hasMatch(v.trim())) {
                    return 'Geçerli bir e-posta girin';
                  }
                  return null;
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Dilekçe Oluştur',
            icon: Icons.auto_awesome_rounded,
            loading: generating,
            onPressed: _generate,
          ),
        ],
      ),
    );
  }

  Widget _resultBody(Color text, Color sub, bool generating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColors.success, size: 26),
                  const SizedBox(width: 8),
                  Text('Dilekçe Hazır!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: text)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Aşağıda düzenleyebilir, kopyalayabilir veya paylaşabilirsiniz',
                  style: TextStyle(color: sub, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassContainer(
          borderRadius: 22,
          padding: const EdgeInsets.all(14),
          child: CustomTextField(
            controller: _resultCtrl,
            maxLines: 25,
            minLines: 18,
            expands: false,
            prefixIcon: null,
            label: 'Dilekçe İçeriği',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: PrimaryButton(text: 'Kopyala', icon: Icons.copy_all_rounded, variant: PrimaryButtonVariant.glass, onPressed: _copy)),
            const SizedBox(width: 10),
            Expanded(child: PrimaryButton(text: 'Favori', icon: Icons.favorite_border_rounded, variant: PrimaryButtonVariant.outlined, onPressed: _favorite)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: PrimaryButton(text: 'PDF', icon: Icons.picture_as_pdf_outlined, variant: PrimaryButtonVariant.glass, onPressed: _exportPdf)),
            const SizedBox(width: 10),
            Expanded(child: PrimaryButton(text: 'Paylaş', icon: Icons.share_rounded, onPressed: _share)),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Yeni Dilekçe Oluştur',
          icon: Icons.replay_rounded,
          variant: PrimaryButtonVariant.glass,
          loading: generating,
          onPressed: () {
            setState(() {
              _step = 0;
              _selectedCat = null;
              _resultCtrl.clear();
              _ctrls.forEach((_, c) => c.clear());
              ref.read(petitionGenerationProvider.notifier).reset();
            });
          },
        ),
      ],
    );
  }
}
