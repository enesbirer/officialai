import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const CATEGORIES: { name: string; description: string; fields?: Record<string, string> }[] = [
  {
    name: "Genel Başvuru Dilekçesi",
    description: "Kurum ve kuruluşlara yapılacak genel nitelikli başvurular",
    fields: {
      muhatap_kurum: "Muhatap Kurum/Kişi Unvanı ve Adresi",
      basvuru_nedeni: "Başvuru Nedeni / Konu",
      olay_ve_gerekce: "Olayın Açıklaması ve Gerekçesi",
      talep: "İstediğiniz Sonuç / Talepleriniz",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik Numarası",
      adres: "Adresiniz",
      telefon: "Telefon Numaranız",
      eposta: "E-posta Adresiniz",
    },
  },
  {
    name: "İşe İade & İşten Çıkarma",
    description: "İş sözleşmesinin sona ermesi, haksız fesih, işe iade talepleri",
    fields: {
      isveren_sirket: "İşveren Şirket Adı ve Adresi",
      ise_giris_tarihi: "İşe Giriş Tarihi (GG.AA.YYYY)",
      isten_cikis_tarihi: "İşten Çıkış/İhbar Tarihi",
      pozisyon: "Çalıştığınız Pozisyon/Ünvan",
      ucret: "Aldığınız Net/Brüt Maaş",
      fesih_sekli: "Nasıl işten çıkarıldınız? (Sözlü / Yazılı / Tebliğ ile)",
      neden_iade: "İşe iade talebinizin gerekçesi",
      talep_edilenler: "Talep edilen tazminatlar/haklar",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik Numarası",
      adres: "Adresiniz",
      telefon: "Telefon Numaranız",
    },
  },
  {
    name: "Kira & Tapu Dilekçesi",
    description: "Kira sözleşmesi, tahliye, kira artışı, tapu işlemleri",
    fields: {
      muhatap: "Muhatap (Kiracı/Kiralayan/TCML)",
      tapu_durumu: "Tapu Durumu ve Adres (İl/İlçe/Mahalle/Sokak/No)",
      kira_baslangic: "Kira Sözleşmesi Başlangıç Tarihi",
      kira_miktari: "Mevcut Kira Bedeli (TL)",
      sorun_nedeni: "Sorun / Dilekçe Konusu (Tahliye / Artış / Sigorta vb.)",
      tarihce: "Olayların kronolojik özeti",
      talep: "Talepleriniz ve Hukuki Dayanağınız",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik Numarası",
      telefon: "Telefon Numaranız",
    },
  },
  {
    name: "Trafik & Ceza İtiraz",
    description: "Trafik cezası, ödeme emri, idari para cezasına itiraz",
    fields: {
      ceza_tarihi: "Ceza Tarihi (GG.AA.YYYY)",
      ceza_kesilen_kurum: "Cezayı Kesen Kurum (Jandarma/Emniiyet/BELEDİYE)",
      ceza_turu: "Ceza Türü (Kırmızı ışık / Hız / Park / Diğer)",
      plaka: "Araç Plakası",
      karar_no: "Ceza Karar Numarası / Tebliğ Numarası",
      itiraz_nedeni: "İtiraz Gerekçesi (olayların anlatımı)",
      sunulacak_kanitlar: "Sunulacak Kanıtlar (Foto, Video, Tanık vb.)",
      talep: "İstediğiniz Sonuç (Ceza iptali / indirim vb.)",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik Numarası",
      adres: "Adresiniz",
      telefon: "Telefon Numaranız",
    },
  },
  {
    name: "Eğitim & Öğrenci Başvurusu",
    description: "Üniversite, MEB, okul, öğrenci, staj dilekçeleri",
    fields: {
      okul_kurum: "Okul/Kurum Adı ve Adresi",
      ogrenci_no: "Öğrenci Numarası (varsa)",
      bolum_program: "Bölüm/Program Adı",
      sinif: "Sınıf Seviyesi",
      basvuru_turu: "Başvuru Türü (Kayıt/Staj/İzin/Belge/İptal)",
      gerekce: "Başvuru Gerekçesi",
      ekler: "Eklenecek Belgeler",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik Numarası",
      telefon: "Telefon",
      eposta: "E-posta",
      veli_velayet: "Veli Adı/Soyadı (18 yaş altı için)",
    },
  },
  {
    name: "Sağlık & Hasta Hakları",
    description: "Hastane, SGK, rapor, muayene dilekçeleri",
    fields: {
      kurum: "Hastane/Kurum Adı",
      hasta: "Hasta Ad Soyad",
      tc_kimlik: "T.C. Kimlik No",
      protokol_no: "Protokol Dosya No (varsa)",
      tarih: "Olay Tarihi / Muayene Tarihi",
      konu: "Konu (Rapor/Reddedilen Tedavi/Tazminat/Şikayet)",
      olay_aciklamasi: "Olayın Kronolojik Açıklaması",
      talep: "Talepleriniz",
      ad_soyad: "Başvuran Ad Soyad",
      telefon: "İletişim Telefonu",
    },
  },
  {
    name: "Vergi & SGK İtirazı",
    description: "Vergi dairesi, SGK ödeme ve itiraz dilekçeleri",
    fields: {
      muhatap_kurum: "Muhatap Kurum (Gelir İdaresi/SGK/Maliye)",
      teblig_tarihi: "Tebliğ Tarihi",
      karar_no: "Tebliğ/Karar Numarası",
      tutar: "İtiraz Edilen Tutar",
      matrah: "Vergi Matrahı / Kazanç Tutarı",
      itiraz_nedeni: "İtirazınızın Gerekçesi ve Hukuki Dayanak",
      duzeltilmesi_istenen: "Düzeltilmesi istenen hususlar",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik No / Vergi No",
      adres: "Adres",
      telefon: "Telefon",
    },
  },
  {
    name: "Tüketici Hakları",
    description: "Şikayet, iade, ayıplı mal, Tüketici Hakemi başvuruları",
    fields: {
      satici_firma: "Satıcı Şirket Adı/Sitesi",
      urun_hizmet: "Ürün Adı / Hizmet Türü",
      satin_alma_tarihi: "Satın Alma Tarihi",
      tutar: "Ödenen Tutar",
      siparis_no: "Sipariş/Fiş Numarası",
      sorun: "Şikayet Konusu / Sorun Tanımı",
      iletilen_talepler: "Şirkete daha önce iletilen talepler",
      sunulan_kanitlar: "Sunulan Kanıtlar (Fiş, Sohbet Ekranları, Fotoğraf)",
      talep: "İstediğiniz Sonuç (İade/Değişim/Tazminat)",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik No",
      adres: "Adres",
      telefon: "Telefon",
      eposta: "E-posta",
    },
  },
  {
    name: "Belediye Hizmetleri",
    description: "Belediyelere yönelik hizmet talepleri, şikayetler",
    fields: {
      belediye: "Belediye Adı / İlçe",
      hizmet_turu: "Hizmet Türü (Yol, Su, Elektrik, Çöp, Park vb.)",
      adres: "İlgili Adres (Mahalle, Sokak, No)",
      sorun: "Sorunun Açıklaması",
      tarih_baslangic: "Sorunun Başladığı Tarih",
      talep: "Talepleriniz",
      ad_soyad: "Ad Soyad",
      tc_kimlik: "T.C. Kimlik No",
      telefon: "Telefon",
    },
  },
  {
    name: "Sivil Dava Dilekçesi",
    description: "Genel sivil davalar, alacak, tazminat, hak arama",
    fields: {
      mahkeme: "Dava Açılacak Mahkeme (Asliye Hukuk/İş/Aile vb.)",
      davaci: "Dava Açan (Davacı) Ad Soyad/Unvan",
      davali: "Davalı Ad Soyad/Unvan ve Adresi",
      uyuşmazlik_konusu: "Uyuşmazlık Konusu (Alacak/Tazminat/Ayıplı Mal)",
      olaya_iliskin: "Olayın Açıklaması (Tarihler, Tutarlar)",
      hukuki_dayanak: "Hukuki Dayanak (İlgili Kanun Maddeleri)",
      dava_talebi: "Dava Talebiniz ve Tutar",
      kanitlar: "Sunulacak Kanıtlar (Tanık, Belge, Bilirkişi)",
      davaci_tc: "Davacı T.C. Kimlik No",
      davaci_adres: "Davacı Adresi",
      davaci_telefon: "Davacı Telefonu",
      vekil: "Avukat/Vekil Adı (varsa)",
    },
  },
];

async function main() {
  console.log("🌱 Seed data yükleniyor...");

  for (const cat of CATEGORIES) {
    const existing = await prisma.petitionCategory.findFirst({ where: { name: cat.name } });
    if (!existing) {
      const created = await prisma.petitionCategory.create({
        data: {
          name: cat.name,
          description: cat.description,
          isActive: true,
        },
      });
      console.log("✅ Kategori:", cat.name, "-> id:", created.id);

      try {
        await prisma.template.create({
          data: {
            petitionCategoryId: created.id,
            name: `${cat.name} - Standart Şablon`,
            description: `${cat.name} için genel amaçlı standart başvuru şablonu`,
            type: "petition",
            structure: { fields: cat.fields || {} },
            isActive: true,
          },
        });
      } catch (e) {
        console.log("⚠️  Template atlanıyor:", (e as any)?.message);
      }
    } else {
      console.log("↩️  Zaten mevcut:", cat.name);
    }
  }

  const cvTemplates = [
    { name: "Profesyonel CV - Standart", type: "cv", description: "Tek sütun, kurumsal firmalar için" },
    { name: "Yaratıcı CV Şablonu", type: "cv", description: "Tasarımcılar, yazılımcılar için renkli" },
    { name: "Akademik CV", type: "cv", description: "Doktora, akademik kadro başvuruları için detaylı" },
  ];
  for (const tpl of cvTemplates) {
    const ex = await prisma.template.findFirst({ where: { name: tpl.name } });
    if (!ex) {
      await prisma.template.create({ data: { ...tpl, structure: {}, isActive: true } });
      console.log("✅ CV Template:", tpl.name);
    }
  }

  const languages = [
    { code: "tr", name: "Türkçe" },
    { code: "en", name: "English" },
  ];
  for (const lng of languages) {
    const ex = await prisma.language.findUnique({ where: { code: lng.code } });
    if (!ex) {
      await prisma.language.create({ data: lng });
      console.log("✅ Dil:", lng.name);
    }
  }

  console.log("\n✅ Seed tamamlandı!");
}

main()
  .catch(e => { console.error("❌ Seed hatası:", e); process.exit(1); })
  .finally(() => prisma.$disconnect());
