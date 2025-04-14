import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/sonrakisayfayageçiş.dart';
import '../soruveajan/soruveajaninternettenalma.dart';
import '../fonksiyon ve providerlar/onlineStatusMonitoring.dart';

class KimKimisecti extends StatefulWidget {
  const KimKimisecti({
    super.key,
  });

  @override
  _KimKimisectiState createState() => _KimKimisectiState();
}

class _KimKimisectiState extends State<KimKimisecti> {
  late Future<List<Map<String, String>>> map;
  late GameLifecycleHandler _lifecycleHandler;
  late String kullaniciAdi;
  late int turSayisi;
  Future<String>? soru;
  late int kullaniciSirasi;
  final OnlineStatusMonitor _onlineStatusMonitor = OnlineStatusMonitor();
  late String username;
  late String odaIsmi;
  late int oyuniciturSayisi;
  late int oyunicielSayisi;
  late int puan;
  late int kisiSayisi;
  late int KullaniciSirasi;
  @override
  void initState() {
    super.initState();

_lifecycleHandler = GameLifecycleHandler(context: context);
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    _onlineStatusMonitor.startMonitoring(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onlineStatusMonitor.kontrolEtVeYonlendir(context, 'kimkimisecti');
    });
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    odaIsmi = roomProvider.odaIsmi ?? "Bilinmeyen Oda";
    turSayisi = roomProvider.turSayisi ?? 1;
    kullaniciSirasi = roomProvider.kullaniciSirasi ?? 1;
    oyunicielSayisi = roomProvider.oyunIciElSayisi!;
    oyuniciturSayisi = roomProvider.oyuniciTurSayisi!;
    kisiSayisi=roomProvider.kisiSayisi!;
    KullaniciSirasi=roomProvider.kullaniciSirasi!;

    username = Provider.of<UserProvider>(context, listen: false).username;
    map = getUsersFromFirestore(odaIsmi);
    soru = Provider.of<SoruProvider>(context, listen: false)
        .AsilSoru(oyuniciturSayisi-1,oyunicielSayisi)
        .then((value) => value != null ? value.toString() : "Soru bulunamadı.");
  }

  @override
  void dispose() {
    _onlineStatusMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                  'Bu soruya kim hangi  cevabı verdi? yalan söyleyeni bul'),
              backgroundColor: Colors.blue.shade700,
              elevation: 8,
            ),
            body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        Provider.of<SoruProvider>(context, listen: false)
                                .ajanmi(oyuniciturSayisi, username)
                            ? 'assets/images/ajan.png'
                            : 'assets/images/köylü.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'El: ${oyunicielSayisi}/3',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Tur: ${oyuniciturSayisi}/${turSayisi}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Kişi: ${kisiSayisi}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],),),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<String>(
                              future: soru,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}',
                                      style: const TextStyle(
                                          fontSize: 18.0, color: Colors.red));
                                } else if (!snapshot.hasData) {
                                  return const Text('No question available',
                                      style: TextStyle(fontSize: 18.0));
                                }
                                return Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<Map<String, String>>>(
                          future: map,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Hata: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Veri bulunamadı'));
                            }

                            List<Map<String, String>> userList = snapshot.data!;

                            return ListView.builder(
                              itemCount: userList.length,
                              itemBuilder: (context, index) {
                                final key = userList[index].keys.first;
                                final value = userList[index].values.first;

                                Color _randomColor() {
                                    // Predefined colors with good contrast
                                    final List<Color> colors = [
                                      Colors.blue[700]!,
                                      Colors.red[700]!,
                                      Colors.green[700]!,
                                      Colors.purple[700]!,
                                      Colors.orange[700]!,
                                      Colors.teal[700]!,
                                      Colors.indigo[700]!,
                                      Colors.pink[700]!,
                                    ];
                                    return colors[Random().nextInt(colors.length)];
                                  }
                                return Card(
                                  color: _randomColor(),
                                  elevation: 4.0,
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      onTapKey(key, index);
                                    },
                                    child: ListTile(
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward),
                                            Text(value),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Pas Butonu
                    ],
                  ),
                ))));
  }

  Future<void> puanHesapla(String username, String key, int KullaniciSirasi) async {
      try {
        String? actualAjan = Provider.of<SoruProvider>(context, listen: false)
            .ajankim(oyuniciturSayisi-1);
  
        if (actualAjan != null) {
          final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
          final DatabaseReference puanRef = databaseRef
              .child('odalar')
              .child(odaIsmi)
              .child('puanlama')
              .child((KullaniciSirasi).toString());
  
          DatabaseEvent event = await puanRef.once();
          DataSnapshot snapshot = event.snapshot;
  
          if (snapshot.value == null) {
            print('❌ Firebase\'den puan değeri alınamadı');
            return;
          }
  
          int mevcutPuan = snapshot.value as int;
          int yeniPuan = mevcutPuan;
  
          if (actualAjan != username && actualAjan == key) {
            yeniPuan += 5;
          } else if (actualAjan != username && actualAjan != key) {
            yeniPuan -= 5;
          }
  
          await puanRef.set(yeniPuan);
  
          print("✅ Puan güncellendi: oda=$odaIsmi, kullanıcı=${KullaniciSirasi-1}, eskiPuan=$mevcutPuan, yeniPuan=$yeniPuan");
        }
      } catch (e) {
        print('❌ Puan güncelleme hatası: $e');
      }
    }

  void onTapKey(String key, int index) async {
      
      
      UserDataFetcher userDataFetcher = UserDataFetcher();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seçilen Değer'),
        content: Text('Seçmek istediğiniz isim: $key. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hayır'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (result == true) {
      await updateVoteInFirebase(odaIsmi, index);
      await userDataFetcher.SonrakiSayfaGecTiklandi(context);

      // Modified ajan check
      try {
        final soruProvider = Provider.of<SoruProvider>(context, listen: false);
        final bool isAjan = soruProvider.ajanmi(oyuniciturSayisi, username);
        
        if (!isAjan) {
          print("Puan hesaplanıyor: kullanıcı=$username, seçilen=$key");
          await puanHesapla(username, key, KullaniciSirasi);
        } else {
          print("Kullanıcı ajan olduğu için puan hesaplanmadı");
        }
      } catch (e) {
        print("Ajan kontrolü sırasında hata: $e");
      }

      if (!context.mounted) return;
      print('kimkimiseçti tamamlandı');
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
    }
  }

  Future<List<Map<String, String>>> getUsersFromFirestore(String docId) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('odalar')
          .child(docId);
      
      // Only fetch the required fields
      final DataSnapshot kullaniciSnapshot = await ref.child('kullaniciadi').get();
      final DataSnapshot secimSnapshot = await ref.child('kimsecildi').get();

      if (!kullaniciSnapshot.exists || !secimSnapshot.exists) {
        throw Exception("Required data not found in Firebase");
      }

      List<dynamic> kullaniciAdiList = List.from(kullaniciSnapshot.value as List? ?? []);
      List<dynamic> kimSecildiList = List.from(secimSnapshot.value as List? ?? []);

      if (kullaniciAdiList.isEmpty || kimSecildiList.isEmpty) {
        throw Exception("User list or selection list is empty");
      }

      return List.generate(kullaniciAdiList.length,
          (i) => {kullaniciAdiList[i]: kimSecildiList[i]});
          
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

  Color _randomColor() {
    Random random = Random();
    return Color.fromRGBO(
        random.nextInt(256), random.nextInt(256), random.nextInt(256), 1);
  }


Future<void> updateVoteInFirebase(String odaIsmi, int index) async {
    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      final DatabaseReference oyRef = databaseRef
          .child('odalar')
          .child(odaIsmi)
          .child('oylar')
          .child(index.toString());

      DatabaseEvent event = await oyRef.once();
      DataSnapshot snapshot = event.snapshot;

      int mevcutOy = 0;
      if (snapshot.value != null) {
        mevcutOy = (snapshot.value as int);
      }

      int yeniOy = mevcutOy + 1;
      await oyRef.set(yeniOy);

      print("✅ Oy başarıyla güncellendi: oda=$odaIsmi, index=$index, yeniOy=$yeniOy");
    } catch (e) {
      print('❌ Oy güncelleme hatası: $e');
      rethrow;
    }
  }
}