import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../soruveajan/SoruSeçimiveajanseçimi.dart';
import '../fonksiyon ve providerlar/firebase_realtime_service.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../soruveajan/soruveajaninternettenalma.dart';
import 'odaoluşturma2.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';

class OdaKurScreen extends StatefulWidget {
  final bool buKim;
//bunu da internete vermen lazım. oyunun bukim mi yoksa puanlama mı olduğunu gösteriyor
  const OdaKurScreen({
    super.key,
    required this.buKim,
  });
  @override
  _OdaKurScreenState createState() => _OdaKurScreenState();
}

class _OdaKurScreenState extends State<OdaKurScreen> {
  final TextEditingController _odaIsmiController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  int Tursayisi = 3;
  int KisiSayisi = 3;
  int OyunTursayisi = 1;
  late String username;
  int ElSayisi = 1;
  late String randomString;
  late List<Map<String, dynamic>> soru;
  int counter = 0;
  List<String> secilenKategoriler = [];
  @override
  void initState() {
    super.initState();
    username = Provider.of<UserProvider>(context, listen: false).username;
  }

  Future<void> _navigateToSecondPage(BuildContext context) async {
    String secilmedi = 'nothing';
    if (_odaIsmiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oda ismi boş olamaz.'),
        ),
      );
      return; // Oda ismi boş ise fonksiyon burada sonlanır
    }

    // Oda ismi benzersiz mi kontrol et
    FirebaseRealtimeService realtimeService = FirebaseRealtimeService();
    bool isUnique =
        await realtimeService.isRoomNameUnique(_odaIsmiController.text);
    if (!isUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oda ismi önceden alındı, oda ismini değiştirin.'),
        ),
      );
      return; // Oda ismi benzersiz değilse fonksiyon burada sonlanır
    }
    if (_odaIsmiController.text.isNotEmpty &&
        await realtimeService.isRoomNameUnique(_odaIsmiController.text)) {
      soru = generateSoruList(widget.buKim, KisiSayisi, Tursayisi,
          _odaIsmiController.text, secilenKategoriler);

      Provider.of<SoruProvider>(context, listen: false).setSoruListesi(soru);

      try {
        // Create room data structure
        Map<String, dynamic> roomData = {
          'Tursayisi': Tursayisi,
          'odaIsmi': _odaIsmiController.text,
          'sifre': _sifreController.text,
          'KisiSayisi': KisiSayisi,
          'buKim': widget.buKim,
          'kullaniciadi': [username],
          'El sayisi': ElSayisi,
          'OyuniçiTursayisi': OyunTursayisi,
          'Sonrakisayfa': List.generate(KisiSayisi, (index) => false),
          'puanlama': List.generate(KisiSayisi, (index) => 0),
          'kimsecildi': List.generate(KisiSayisi, (index) => secilmedi),
          'soru': soru,
          'oylar': List.generate(KisiSayisi, (index) => 0),
          'Counter': counter,
          'onlineStatus': List.generate(KisiSayisi, (index) => false),
          'girisZamani': ServerValue.timestamp
        };

        // Create the room in Firebase
        await realtimeService.createRoom(_odaIsmiController.text, roomData);

        // Update RoomProvider with the created room info
        Provider.of<RoomProvider>(context, listen: false).updateRoomInfo(
          turSayisi: Tursayisi,
          odaIsmi: _odaIsmiController.text,
          sifre: _sifreController.text,
          kisiSayisi: KisiSayisi,
          buKim: widget.buKim,
          elSayisi: ElSayisi,
          oyuniciTurSayisi: OyunTursayisi,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OdaKur2(BuKim: widget.buKim, odaismi: _odaIsmiController.text),
          ),
        );
      } catch (error) {
        print('Firebase kaydetme hatası: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oda oluşturulurken hata oluştu: $error')),
        );
      }
    }
  }

  Future<void> removeUserFromRoom(String roomId, String username) async {
    final ref = FirebaseDatabase.instance.ref('odalar/$roomId/kullaniciadi');
    final event = await ref.once();

    if (event.snapshot.exists) {
      List<dynamic> users = List<dynamic>.from(event.snapshot.value as List);
      users.removeWhere((e) => e == username || e == null);
      await ref.set(users);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue.shade700,
          title: Text(
            widget.buKim
                ? 'BuKim oyunu oda oluşturma'
                : 'Puanlama oyunu oda oluşturma',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade900,
              ],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/ajanbaslangic.png'),
              fit: BoxFit.cover,
              opacity: 0.2,
              colorFilter: ColorFilter.mode(
                Colors.black26,
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _odaIsmiController,
                          decoration: InputDecoration(
                            labelText: 'Oda İsmi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _sifreController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Şifre (isteğe bağlı)',
                            hintText:
                                'Eğer odanızın herkese açık olmasını istiyorsanız şifre girmeyiniz',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Tur Sayısı',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.blue.shade700,
                                onPressed: () {
                                  setState(() {
                                    Tursayisi--;
                                    if (Tursayisi < 1) {
                                      Tursayisi++;
                                    }
                                  });
                                },
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '$Tursayisi',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.blue.shade700,
                                onPressed: () {
                                  setState(() {
                                    Tursayisi++;
                                    if (7 < Tursayisi) {
                                      Tursayisi--;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Kaç Kişi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.blue.shade700,
                                onPressed: () {
                                  setState(() {
                                    KisiSayisi--;
                                    if (KisiSayisi < 3) {
                                      KisiSayisi++;
                                    }
                                  });
                                },
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '$KisiSayisi',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.blue.shade700,
                                onPressed: () {
                                  setState(() {
                                    KisiSayisi++;
                                    if (15 < KisiSayisi) {
                                      KisiSayisi--;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    List<String> yeniSecimler = await showKategoriSecimDialog(
                      context,
                      oncekiSecimler: secilenKategoriler,
                    );
                    setState(() {
                      secilenKategoriler = yeniSecimler;
                    });

                    print("✅ Seçilen kategoriler: $secilenKategoriler");
                  },
                  icon: const Icon(Icons.category, size: 20), // ikon eklendi
                  label: const Text(
                    "Kategoriler",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        offset: const Offset(0, 4),
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (secilenKategoriler.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Uyarı'),
                            content:
                                const Text('Lütfen en az bir kategori seçin.'),
                            actions: [
                              TextButton(
                                child: const Text('Tamam'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _navigateToSecondPage(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'İleri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<List<String>> showKategoriSecimDialog(
    BuildContext context, {
    required List<String> oncekiSecimler,
  }) async {
    List<String> kategoriler = [
      "Genel",
      "Zihinsel & Bilişsel Beceriler",
      "Spor",
      "Duygusal & Karakter Özellikleri",
      "Yetenek & Hobi Becerileri",
      "Oyun & Rekabetçi Beceriler",
      "Günlük Hayat Becerileri",
      "Bilgi & Genel Kültür",
      "futbol",
      "basketbol",
    ];

    // Başlangıç durumu, önceki seçimlere göre
    Map<String, bool> seciliKategoriler = {
      for (var kategori in kategoriler)
        kategori: oncekiSecimler.contains(kategori),
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Kategoriler"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: kategoriler.map((kategori) {
                    final seciliMi = seciliKategoriler[kategori]!;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          seciliKategoriler[kategori] = !seciliMi;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: seciliMi ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kategori,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dialogu kapat
                  },
                  child: const Text("Kapat"),
                ),
              ],
            );
          },
        );
      },
    );

    // Seçilen (yeşil olan) kategorileri döndür
    List<String> secilenler = seciliKategoriler.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    return secilenler;
  }

  List<Map<String, dynamic>> generateSoruList(bool BuKim, int KisiSayisi,
      int TurSayisi, String odaIsmi, secilenKategoriler) {
    List<Map<String, dynamic>> sorular = [];

    // Tursayisi kadar map oluşturuluyor
    for (int i = 0; i < TurSayisi * 3; i++) {
      // Her bir tur için SoruDondur fonksiyonu çağrılıyor
      Map<String, dynamic> Soru = SoruIslemleri.SoruDondur(
        BuKim,
        KisiSayisi,
        secilenKategoriler,
      );
      if (i % 3 != 0) {
        Soru.updateAll((key, value) => '');
  }


      sorular.add(Soru);
    }

    return sorular;
  }
}
