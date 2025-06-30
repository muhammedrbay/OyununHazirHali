import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/sonrakisayfayageçiş.dart';
import '../oyunnun kendisi/kişiseçmesayfasi.dart';
import '../soruveajan/soruveajaninternettenalma.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/firebase_realtime_service.dart';
import '../oyununoluşturulması/misafirodasıkurulumsayfası.dart';

class Oyunkurulumsayfasi extends StatefulWidget {
  final bool BuKim;

  const Oyunkurulumsayfasi({required this.BuKim, super.key});

  @override
  _OyunkurulumsayfasiState createState() => _OyunkurulumsayfasiState();
}

class _OyunkurulumsayfasiState extends State<Oyunkurulumsayfasi> {
  late List<String> _internettenKullancilar = [];
  late bool sonrakiSayfayaGecilsinmi;
  bool _dataLoaded = false;
  final FirebaseRealtimeService _firebaseService = FirebaseRealtimeService();
  late int turSayisi;
  late String odaIsmi;
  late int kisiSayisi;
  late String sifre;
  StreamSubscription? _subscription;
  List<Map<String, dynamic>>? soruListesi;
  late String username;
  UserDataFetcher userDataFetcher = UserDataFetcher(); // NESNE OLUŞTURULDU

  @override
  void initState() {
    super.initState();
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    odaIsmi = roomProvider.odaIsmi!;
    sifre = roomProvider.sifre!;
    turSayisi = roomProvider.turSayisi!;
    kisiSayisi = roomProvider.kisiSayisi!;

    _subscription = _firebaseService.getUsersInRoom(odaIsmi).listen(
      (kullanicilar) {
        if (kullanicilar.isEmpty) {
          // Oda boşsa, yönlendirme yap
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Misafirodakurulumsayfasi(
                    buKim: true,
                  ),
                ),
              );
            }
          });
        } else {
          setState(() {
            _internettenKullancilar = kullanicilar;
            _dataLoaded = true;
          });
        }
      },
      onError: (error) {
        print("Hata oluştu: $error");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Oda Kapatıldı'),
              content: const Text('Bu oda artık mevcut değil.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Misafirodakurulumsayfasi(
                          buKim: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
      },
    );
    username = Provider.of<UserProvider>(context, listen: false).username;
    _setupAppLifecycleListener();
  }

  Stream<bool> counterTakipStream(BuildContext context) {
    String odaIsmi = Provider.of<RoomProvider>(context, listen: false).odaIsmi!;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("odalar/$odaIsmi/Counter");

    // Stream dönüşü: sadece birler basamağı 1 ise true, değilse false
    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return false;

      int currentValue = event.snapshot.value as int;
      int birlerBasamagi = currentValue % 10;

      print("Yeni Counter: $currentValue → Birler: $birlerBasamagi");

      return birlerBasamagi == 1;
    });
  }

  void _setupAppLifecycleListener() {
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () async => await _handleAppClose(),
      ),
    );
  }

  Future<void> _handleAppClose() async {
    await removeUserFromRoom(odaIsmi, username);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(
      LifecycleEventHandler(
        detachedCallBack: () async => await _handleAppClose(),
      ),
    );
    super.dispose();
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
        backgroundColor: Colors.blue,
        title: const Text(
          'BuKim Oyun Kuruldu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            bool? result = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Odadan Çıkış'),
                  content:
                      const Text('Odadan çıkmak istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Hayır'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Evet'),
                    ),
                  ],
                );
              },
            );

            if (result == true) {
              await removeUserFromRoom(odaIsmi, username);
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Misafirodakurulumsayfasi(
                    buKim: true,
                  ),
                ),
              );
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/ajanbaslangic.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: _dataLoaded
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.meeting_room,
                                size: 40, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(
                              'Oda İsmi: $odaIsmi',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(),
                            Text(
                              'Şifre: ${sifre.isEmpty ? 'Herkese Açık' : sifre}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Oynanacak El Sayısı: $turSayisi',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Oyuncular',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ..._generateContainers(),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _internettenKullancilar.length == kisiSayisi
            ? () async {
                bool? result = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: const Text(
                        'Oyunu Başlat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      content: const Text(
                        'Tüm oyuncular hazır! Oyunu başlatmak istiyor musunuz?',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text(
                            'Hayır',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Evet, Başlat'),
                        ),
                      ],
                    );
                  },
                );

                if (result == true) {
                  await fetchRoomAndGameData(context, odaIsmi);
                  await updateUserIndex(context);

                  UserDataFetcher userDataFetcher = UserDataFetcher();
                  await userDataFetcher.SonrakiSayfaGecTiklandi(context);

                  if (!context.mounted) return;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StreamBuilder<bool>(
                        stream: counterTakipStream(context),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).pop();
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KisiSecmeListesi(),
                                  ),
                                );
                              }
                            });
                          }
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: const Text(
                              'Bekleniyor...',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Diğer oyuncular bekleniyor...',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              }
            : null,
        label: const Text('İleri'),
        icon: const Icon(Icons.arrow_forward),
        backgroundColor: _internettenKullancilar.length == kisiSayisi
            ? Colors.blue
            : Colors.grey[400],
        foregroundColor: Colors.white,
        elevation: _internettenKullancilar.length == kisiSayisi ? 6.0 : 0.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _generateContainers() {
    List<Widget> containers = [];
    for (int i = 0; i < kisiSayisi; i++) {
      bool isOccupied = i < _internettenKullancilar.length;
      containers.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOccupied
                    ? [Colors.blue[400]!, Colors.blue[800]!]
                    : [Colors.grey[300]!, Colors.grey[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.person,
                    color: isOccupied ? Colors.white : Colors.grey[400],
                    size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    i < _internettenKullancilar.length
                        ? _internettenKullancilar[i]
                        : 'Boş',
                    style: TextStyle(
                      color: isOccupied ? Colors.white : Colors.grey[400],
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return containers;
  }

  Future<int> getUserIndex(String odaIsmi, String kullaniciAdi) async {
    List<String> users = await _firebaseService.getUsersInRoom(odaIsmi).first;
    return users.indexOf(kullaniciAdi);
  }

  Future<void> updateUserIndex(BuildContext context) async {
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    int index = await getUserIndex(odaIsmi, username);
    roomProvider.kullaniciSirasi = index;
  }

  Future<void> fetchRoomAndGameData(
      BuildContext context, String odaIsmi) async {
    try {
      Map<String, dynamic>? data = await _firebaseService.getRoomData(odaIsmi);

      if (data != null) {
        // Oda bilgilerini güncelle
        Provider.of<RoomProvider>(context, listen: false).updateRoomInfo(
          turSayisi: data['Tursayisi'],
          odaIsmi: data['odaIsmi'],
          sifre: data['sifre'],
          kisiSayisi: data['KisiSayisi'],
          buKim: data['BuKim'],
          elSayisi: data['El sayisi'],
          oyuniciTurSayisi: data['OyuniçiTursayisi'],
        );

        // **Soru listesini al ve uygun formata dönüştür**
        List<Map<String, dynamic>> soruListesi = [];
        if (data.containsKey('soru') && data['soru'] is List) {
          // Her elemanı Map'e çevir
          soruListesi = data['soru'].map<Map<String, dynamic>>((e) {
            return Map<String, dynamic>.from(e);
          }).toList();
        }

        Provider.of<SoruProvider>(context, listen: false)
            .setSoruListesi(soruListesi);

        // **Ajan listesini al**
        if (data.containsKey('ajan') && data['ajan'] is List) {
          List<String> ajanListesi = List<String>.from(data['ajan']);
          Provider.of<SoruProvider>(context, listen: false)
              .setAjanListesi(ajanListesi);
        }

        // **setState() çağırmadan önce context'in halen geçerli olup olmadığını kontrol et**
        if (!context.mounted) return;
        setState(() {
          turSayisi = data['turSayisi'] ?? 0;
          kisiSayisi = data['kisiSayisi'] ?? 0;
          _dataLoaded = true;
        });
      }
    } catch (error) {
      // Hata yönetimi
      print("Veri çekme sırasında hata oluştu: $error");
    }
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function() detachedCallBack;

  LifecycleEventHandler({required this.detachedCallBack});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      detachedCallBack();
    }
  }
}
