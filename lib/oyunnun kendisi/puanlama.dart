import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/sonrakisayfayageçiş.dart';
import '../fonksiyon ve providerlar/onlineStatusMonitoring.dart';
import '../soruveajan/soruveajaninternettenalma.dart';

class PuanlamaWidget extends StatefulWidget {
  const PuanlamaWidget();

  @override
  _PuanlamaWidgetState createState() => _PuanlamaWidgetState();
}

class _PuanlamaWidgetState extends State<PuanlamaWidget> {
  late GameLifecycleHandler _lifecycleHandler;
  Map<String, int> puanTablosu = {};
  late int oyunIciTurSayisi;
  late int turSayisi;
  late String username;
  late String? actualAjan; // ✅ Ajan bilgisini tutmak için
  bool oyunBittiMi = false;
  UserDataFetcher userDataFetcher = UserDataFetcher();
  final OnlineStatusMonitor _onlineStatusMonitor = OnlineStatusMonitor();
  late String odaIsmi;
  late bool buKim;

  @override
  void initState() {
    super.initState();
    _lifecycleHandler = GameLifecycleHandler(context: context);
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    print('PuanlamaWidget initState başladı.');
    _onlineStatusMonitor.startMonitoring(context);

    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    oyunIciTurSayisi = roomProvider.oyuniciTurSayisi??0;
    turSayisi = roomProvider.turSayisi??0;
    odaIsmi = roomProvider.odaIsmi??"";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onlineStatusMonitor.kontrolEtVeYonlendir(context, 'puanlama');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final maybeUsername =
          Provider.of<UserProvider>(context, listen: false).username;


      username = maybeUsername;

      actualAjan = Provider.of<SoruProvider>(context, listen: false)
          .ajankim(oyunIciTurSayisi - 1); // ✅ Ajanı al

      // Puan tablosunu getir ve setState ile güncelle
      Map<String, int> fetchedData = await puanTablosuGetir(odaIsmi);
      Provider.of<RoomProvider>(context, listen: false)
          .updatePuanlama(fetchedData);
      setState(() {
        puanTablosu = fetchedData;
      });
    });
  }

  Future<Map<String, int>> puanTablosuGetir(String docId) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('odalar').child(docId);
      print('puan tablosu getir çalıştı');

      // Only fetch required fields
      final DataSnapshot kullaniciSnapshot =
          await ref.child('kullaniciadi').get();
      final DataSnapshot puanlamaSnapshot = await ref.child('puanlama').get();

      if (!kullaniciSnapshot.exists || !puanlamaSnapshot.exists) {
        throw Exception("Required data not found");
      }

      List<dynamic> kullaniciAdiList =
          List.from(kullaniciSnapshot.value as List? ?? []);
      List<dynamic> puanlama = List.from(puanlamaSnapshot.value as List? ?? []);

      print("👥 Kullanıcı Listesi: $kullaniciAdiList");
      print("📊 Puan Listesi: $puanlama");

      if (kullaniciAdiList.length != puanlama.length) {
        print("❌ Liste uzunlukları uyuşmuyor: Kullanıcılar(${kullaniciAdiList.length}) - Puanlar(${puanlama.length})");
        throw Exception("User list and score list lengths don't match");
      }

      Map<String, int> sonucMap = Map.fromIterables(
          kullaniciAdiList.map((e) => e.toString()),
          puanlama.map((e) => e as int));
      
      print("🎯 Oluşturulan Puan Tablosu: $sonucMap");
      
      return sonucMap;
          
    } catch (e) {
      print("Error fetching score data: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Puan Tablosu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Colors.blue.shade700,
          elevation: 10,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/ajanfoto.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Oyuncu Puanları',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: puanTablosu.length,
                      itemBuilder: (context, index) {
                        String key = puanTablosu.keys.elementAt(index);
                        int value = puanTablosu.values.elementAt(index);
                        bool isAjan = key == actualAjan; // ✅ Ajan kontrolü

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAjan
                                      ? "$key (ajan)"
                                      : key, // ✅ Etiketli yaz
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                                Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.blueGrey.shade800,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Text(
                        'Kaçıncı Tur: $oyunIciTurSayisi/ $turSayisi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      userDataFetcher.SonrakiSayfaGecTiklandi(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: const AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 20),
                                  Text("Diğerleri için bekleniyor..."),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'İleri',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _onlineStatusMonitor.dispose();
    super.dispose();
  }
}
