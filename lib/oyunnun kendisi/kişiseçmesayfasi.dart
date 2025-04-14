import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/sonrakisayfayageçiş.dart';
import '../fonksiyon ve providerlar/onlineStatusMonitoring.dart';
import '../soruveajan/soruveajaninternettenalma.dart';
import '../fonksiyon ve providerlar/firebase_realtime_service.dart';

class KisiSecmeListesi extends StatefulWidget {
  const KisiSecmeListesi({
    super.key,
  });

  @override
  _KisiSecmeListesiState createState() => _KisiSecmeListesiState();
}

class _KisiSecmeListesiState extends State<KisiSecmeListesi> {
 late GameLifecycleHandler _lifecycleHandler;
  late List<String> kullanicilar = [];
  int secilenIndex = -1;
  Future<bool>? kullaniciAjanMi;
  late int turSayisi;
  late String odaIsmi;
  late int kisiSayisi;
  final FirebaseRealtimeService _realtimeService = FirebaseRealtimeService();
  late int oyunIciTurSayisi = 0;
  late int oyunIciElSayisi = 0;
  late int kullaniciSirasi;
  late Future<dynamic> soru = Future.value("");
  final OnlineStatusMonitor _onlineStatusMonitor = OnlineStatusMonitor();
  late String username;
  late StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();
    
    // Initialize lifecycle handler
_lifecycleHandler = GameLifecycleHandler(context: context);
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onlineStatusMonitor.kontrolEtVeYonlendir(context, 'kisisecme');
    });
    _onlineStatusMonitor.startMonitoring(context);

    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    odaIsmi = roomProvider.odaIsmi ?? "BilinmeyenOda";
    kisiSayisi = roomProvider.kisiSayisi ?? 3;
    turSayisi = roomProvider.turSayisi ?? 6;
    username = Provider.of<UserProvider>(context, listen: false).username;
    kullaniciSirasi = roomProvider.kullaniciSirasi ?? 1;
    kisisecme(odaIsmi, kullaniciSirasi, 'nothing');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);

    getCounterValue(odaIsmi).then((counter) {
      int tur = calculateOyuncuTurSayisi(counter);
      int ciel = calculateOyuncuicielSayisi(counter);
      roomProvider.oyuniciTurSayisi = tur;
      roomProvider.oyunIciElSayisi = ciel;
      setState(() {
        oyunIciTurSayisi = tur;
        oyunIciElSayisi = ciel;
      });
soru = Provider.of<SoruProvider>(context, listen: false)
        .InternettenSoru(oyunIciTurSayisi-1, username,oyunIciElSayisi);
      fetchGameData();
    });

    fetchUsers();
  }

  Future<void> fetchGameData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    bool isAjan = await Provider.of<SoruProvider>(context, listen: false)
        .ajanmi(oyunIciTurSayisi, username);
    Provider.of<RoomProvider>(context, listen: false).isAjan = isAjan;
    if (mounted) {
      if (isAjan) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Ajan Sensin!'),
              content: Text('Köylülerden saklan'),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Köylüsün!'),
              content: Text('Ajanı bul'),
            );
          },
        );
      }
    }
  }

  void fetchUsers() {
    if (odaIsmi.isEmpty) return;

    _userSubscription =
        _realtimeService.getUsersInRoom(odaIsmi).listen((users) {
      if (mounted) {
        setState(() {
          kullanicilar = users;
        });
      }
    }, onError: (error) {
      print("Firebase kullanıcı listesi alınırken hata oluştu: $error");
    });
  }

  Future<void> kisisecme(String docId, int index, String yeniDeger) async {
    print(
        'kisisecme called with docId: $docId, index: $index, yeniDeger: $yeniDeger');
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('odalar')
          .child(docId)
          .child('kimsecildi')
          .get();

      if (snapshot.exists) {
        List<dynamic> kimSecildiListesi = List.from(snapshot.value as List);

        if (index >= 0 && index < kimSecildiListesi.length) {
          kimSecildiListesi[index] = yeniDeger;

          await FirebaseDatabase.instance
              .ref()
              .child('odalar')
              .child(docId)
              .child('kimsecildi')
              .set(kimSecildiListesi);
        }
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    _userSubscription?.cancel();
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
          title: const Text('Soruya en uygun gördüğünüzü seçin'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  Provider.of<SoruProvider>(context, listen: false)
                          .ajanmi(oyunIciTurSayisi, username)
                      ? 'assets/images/ajan.png'
                      : 'assets/images/köylü.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'El: ${oyunIciElSayisi} / 3',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tur: ${oyunIciTurSayisi} / ${turSayisi}',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<dynamic>(
                        future: soru,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Hata oluştu.",
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              snapshot.data.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return const Text(
                              "Veri bulunamadı.",
                              style: TextStyle(fontSize: 18),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: kullanicilar.length,
                      itemBuilder: (context, index) {
                        final color = _randomColor();
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: InkWell(
                            onTap: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Seçim Onayı'),
                                  content: Text(
                                    '${kullanicilar[index]} kullanıcısını seçmek istediğinize emin misiniz?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Hayır'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Evet'),
                                    ),
                                  ],
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  secilenIndex = index;
                                });

                                await kisisecme(odaIsmi, kullaniciSirasi,
                                    kullanicilar[index]);

                                final userDataFetcher = UserDataFetcher();
                                await userDataFetcher.SonrakiSayfaGecTiklandi(
                                    context);

                                if (!context.mounted) return;

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
                            },
                            child: Card(
                              color: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  kullanicilar[index],
                                  style: const TextStyle(
                                    fontSize: 18, // Increased from 16
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5, // Added letter spacing for better readability
                                    shadows: [
                                      Shadow( // Added shadow for better contrast
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _randomColor() {
    // Using a predefined list of contrasting colors instead of completely random ones
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

  Future<int> getCounterValue(String referencePath) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("odalar/$referencePath");
    try {
      DataSnapshot snapshot = await ref.child('Counter').get();
      if (snapshot.exists && snapshot.value != null) {
        int counter = snapshot.value as int;
        return counter;
      } else {
        return 1;
      }
    } catch (error) {
      return 1;
    }
  }

  int calculateOyuncuTurSayisi(int counter) {
    int oyuncuTurSayisi = (counter ~/ 10) + 1;
    return oyuncuTurSayisi;
  }

  int calculateOyuncuicielSayisi(int counter) {
    int remainder = counter % 10;
    if (remainder != 1 &&
        remainder != 4 &&
        remainder != 7 &&
        remainder != 0 &&
        remainder != 3 &&
        remainder != 6) {
      return 0;
    }
    return (remainder ~/ 3) + 1;
  }
}
