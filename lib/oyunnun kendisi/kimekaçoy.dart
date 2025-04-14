import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/sonrakisayfayageçiş.dart';
import '../soruveajan/soruveajaninternettenalma.dart';
import '../fonksiyon ve providerlar/onlineStatusMonitoring.dart';

class KimeKacOy extends StatefulWidget {
  const KimeKacOy({
    super.key,
  });

  @override
  _KimeKacOyState createState() => _KimeKacOyState();
}

class _KimeKacOyState extends State<KimeKacOy> {
    late GameLifecycleHandler _lifecycleHandler;
  late int turSayisi;
  late String odaIsmi;
  late String kullaniciAdi;
  late int kullaniciSirasi;
  Map<String, int> oyDurumuMap = {};
  bool _isLoading = true;
  final OnlineStatusMonitor _onlineStatusMonitor = OnlineStatusMonitor();
  late String username;
  late int oyunicielSayisi = 0;
  late int oyuniciturSayisi = 0;
  late int kisiSayisi;
  @override
  void initState() {
    super.initState();
_lifecycleHandler = GameLifecycleHandler(context: context);
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    print("✅ inintstate başlatıldı");
    _onlineStatusMonitor.startMonitoring(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onlineStatusMonitor.kontrolEtVeYonlendir(context, 'kimekacoy');
    });
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    odaIsmi = roomProvider.odaIsmi ?? "";
    oyunicielSayisi = roomProvider.oyunIciElSayisi ?? 0;
    oyuniciturSayisi = roomProvider.oyuniciTurSayisi ?? 0;
    turSayisi = roomProvider.turSayisi ?? 0;
    kullaniciSirasi = roomProvider.kullaniciSirasi ?? 0;
    kisiSayisi=roomProvider.kisiSayisi??0;

    var userProvider = Provider.of<UserProvider>(context, listen: false);
    username = userProvider.username ?? "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('Starting _initializeData...');

      final result = await fetchOyDurumu(odaIsmi);
      print('fetchOyDurumu result: $result');
      if (mounted) {
        setState(() {
          for (var map in result) {
            oyDurumuMap.addAll(map);
          }
          print('oyDurumuMap after update: $oyDurumuMap');
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error in _initializeData: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  

  Future<List<Map<String, int>>> fetchOyDurumu(String odaIsmi) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref().child('odalar').child(odaIsmi);
      
      // Only fetch required fields
      final DataSnapshot kullaniciSnapshot = await ref.child('kullaniciadi').get();
      final DataSnapshot oylarSnapshot = await ref.child('oylar').get();

      if (!kullaniciSnapshot.exists || !oylarSnapshot.exists) {
        throw Exception("Required data not found");
      }

      List<dynamic> kullaniciAdiList = List.from(kullaniciSnapshot.value as List? ?? []);
      List<dynamic> oylar = List.from(oylarSnapshot.value as List? ?? []);

      if (kullaniciAdiList.length != oylar.length) {
        throw Exception("User list and vote list lengths don't match");
      }

      return List.generate(kullaniciAdiList.length,
          (i) => {kullaniciAdiList[i].toString(): oylar[i] as int});
    } catch (e) {
      print("Error fetching vote data: $e");
      rethrow;
    }
  }

  Widget buildCard(String key, int value) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: _randomColor(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 24.0,
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _randomColor() {
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

  @override
  void dispose() {
    _onlineStatusMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **MAP'İ YÜKSEKTEN DÜŞÜĞE SIRALA**
    List<MapEntry<String, int>> sortedEntries = oyDurumuMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Büyükten küçüğe sıralama

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Kim kaç oy aldı?'),
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
  child: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [ // <-- Eksik olan kısım burasıydı!
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
            Expanded(
              child: ListView.builder(
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  String key = sortedEntries[index].key;
                  int value = sortedEntries[index].value;
                  return buildCard(key, value);
                },
              ),
            ),
          ],
        ),
),

          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!mounted) return;

              bool? result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        'Sonraki sayfaya geçmek istediğinize emin misiniz?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Evet'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Hayır'),
                      ),
                    ],
                  );
                },
              );

              if (result == true) {
                await UserDataFetcher().SonrakiSayfaGecTiklandi(context);

                if (!context.mounted) return;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,  // Prevent back button
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
            child: const Icon(Icons.arrow_forward),
          ),
        ));
  }
}
