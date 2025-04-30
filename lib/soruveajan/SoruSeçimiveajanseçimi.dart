import 'dart:math';
import 'GenisletilmisSoruListesi.dart';

class SoruIslemleri {
  static Map<String, dynamic> SoruDondur(
      bool buKim, int KisiSayisi, secilenKategoriler) {
    Random random = Random();

    // 🔀 1. Rastgele bir kategori seç
    if (secilenKategoriler.isEmpty) {
      throw Exception("Hiç kategori seçilmedi!");
    }
    String rastgeleKategori =
        secilenKategoriler[random.nextInt(secilenKategoriler.length)];

    // 🎯 2. Kategoriye göre doğru listeyi al
    List<Map<String, List<String>>> kategoriSorular;

    switch (rastgeleKategori) {
      case "futbol":
        kategoriSorular = GenisletilmisSoruListesi.futbol;
        break;
      case "basketbol":
        kategoriSorular = GenisletilmisSoruListesi.basketbol;
        break;
      case "Genel":
        kategoriSorular = GenisletilmisSoruListesi.Genel;
        break;
      case "Zihinsel & Bilişsel Beceriler":
        kategoriSorular = GenisletilmisSoruListesi.Zihinsel;
        break;
      case "Spor":
        kategoriSorular = GenisletilmisSoruListesi.spor;
        break;
      case "Duygusal & Karakter Özellikleri":
        kategoriSorular = GenisletilmisSoruListesi.duygusal;
        break;
      case "Yetenek & Hobi Becerileri":
        kategoriSorular = GenisletilmisSoruListesi.yetenek;
        break;
      case "Oyun & Rekabetçi Beceriler":
        kategoriSorular = GenisletilmisSoruListesi.oyun;
        break;
      case "Günlük Hayat Becerileri":
        kategoriSorular = GenisletilmisSoruListesi.gunluk;
        break;
      case "Bilgi & Genel Kültür":
        kategoriSorular = GenisletilmisSoruListesi.bilgi;
        break;
      default:
        throw Exception("Kategori tanınamadı: $rastgeleKategori");
    }

    // ❓ 3. Liste boşsa fallback yap
    if (kategoriSorular.isEmpty) {
      throw Exception("Seçilen kategoriye ait soru yok.");
    }
    if (buKim) {
      const String template = 'bu grubun en';

      List<Map<String, dynamic>> mapListesi = kategoriSorular.map((soru) {
        String key = soru.keys.first;
        String value = soru.values.first.first;
        return {
          '${key.startsWith("en") ? "bu grubun" : template} $key kişisi kim':
              '${key.startsWith("en") ? "bu grubun" : template} $value kişisi kim',
        };
      }).toList();

      return mapListesi[random.nextInt(mapListesi.length)];
    } else {
      int rastgeleSoruIndex = random.nextInt(kategoriSorular.length);
      Map<String, List<String>> secilenSoru =
          kategoriSorular[rastgeleSoruIndex];

      String Key = random.nextBool()
          ? secilenSoru.keys.first
          : secilenSoru.values.first.first;

      int Soru = random.nextInt(KisiSayisi) + 1; // 1'den başlayacak şekilde düzeltildi
      String NormalSoru = sayiDegeri(Soru);
      String AjanSorusu = AjanSoru(KisiSayisi, Soru, random);

      return {
        '${Key.startsWith("en") ? "bu grubun" : "bu grubunun en"} $Key $NormalSoru kişisi kim':
            '${Key.startsWith("en") ? "bu grubun" : "bu grubunun en"} $Key $AjanSorusu kişisi kim',
      };
    }
  }

  static String AjanSoru(int KisiSayisi, int Soru, Random random) {
    int Fark = KisiSayisi ~/ 2;
    int AltSinir = Soru - Fark;
    if (AltSinir < 1) {
      AltSinir = 1;
    }
    int Sayi = AltSinir + random.nextInt(Fark);

    List<String> rakamlar = [];
    for (int i = Sayi; i <= (Sayi + Fark); i++) {
      rakamlar.add(sayiDegeri(i));
    }

    // Virgülle ayrılmış string oluşturma
    String birlesikDeger = rakamlar.join(', ');
    // Son değerden önce "veya" ekleyerek birleştirme
    if (rakamlar.length > 1) {
      birlesikDeger = birlesikDeger.replaceRange(
          birlesikDeger.lastIndexOf(', '),
          birlesikDeger.lastIndexOf(', ') + 1,
          ' veya');
    }

    return birlesikDeger;
  }

  static String sayiDegeri(int Sayi) {
    String sonuc = '';
    {
      switch (Sayi) {
        case 1:
          sonuc += 'birinci ';
          break;
        case 2:
          sonuc += 'ikinci ';
          break;
        case 3:
          sonuc += 'üçüncü ';
          break;
        case 4:
          sonuc += 'dördüncü ';
          break;
        case 5:
          sonuc += 'beşinci ';
          break;
        case 6:
          sonuc += 'altıncı ';
          break;
        case 7:
          sonuc += 'yedinci ';
          break;
        case 8:
          sonuc += 'sekizinci ';
          break;
        case 9:
          sonuc += 'dokuzuncu ';
          break;
        case 10:
          sonuc += 'onuncu ';
          break;
      }
    }
    return sonuc.trim();
  }
}
