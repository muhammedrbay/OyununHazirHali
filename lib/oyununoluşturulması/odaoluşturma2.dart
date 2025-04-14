import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/fonksiyon%20ve%20providerlar/onlineStatusMonitoring.dart';
import 'package:provider/provider.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../fonksiyon ve providerlar/sonrakisayfayageçiş.dart';
import '../oyunnun kendisi/kişiseçmesayfasi.dart';
import '../soruveajan/soruveajaninternettenalma.dart';
import '../fonksiyon ve providerlar/firebase_realtime_service.dart';
import 'package:firebase_database/firebase_database.dart';

class OdaKur2 extends StatefulWidget {
  final bool BuKim;
  final String odaismi;
  // BuKim parametresini al
  const OdaKur2({super.key, required this.BuKim, required this.odaismi});

  @override
  _OdaKur2State createState() => _OdaKur2State();
}

class _OdaKur2State extends State<OdaKur2> {
  final bool _dataLoaded =
      true; // Initially false to indicate data is not yet loaded

  late List<String> _internettenKullancilar =
      []; // Initialize with an empty list
  late int TurSayisi = 0; // Initialize with a default value
  late String odaIsmi = ""; // Initialize with an empty string
  late int KisiSayisi = 0; // Initialize with a default value
  late String Sifre = ""; // Already initialized correctly
  late bool Sahip = false; // Initialize with a default value
  final FirebaseRealtimeService _realtimeService = FirebaseRealtimeService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late bool BuKim;
  late String Username;
  late RoomLifecycleHandler _lifecycleHandler;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    
    // Initialize lifecycle handler
    _lifecycleHandler = RoomLifecycleHandler(
      detachedCallBack: () async {
        try {
          await _realtimeService.deleteRoom(widget.odaismi);
          debugPrint('Uygulama kapandı, oda silindi.');
        } catch (e) {
          debugPrint('Oda silinirken hata: $e');
        }
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    
    Username = Provider.of<UserProvider>(context, listen: false).username;
    BuKim = widget.BuKim;
    Provider.of<RoomProvider>(context, listen: false).updateRoomInfo(
      puan: 0,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    WidgetsBinding.instance.removeObserver(
      LifecycleEventHandler(
        detachedCallBack: () async => await _handleAppClose(),
      ),
    );
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      // Get room data from Realtime Database
      final roomData = await _realtimeService.getRoomData(widget.odaismi);
      if (roomData != null) {
        // Update the state with the fetched data
        setState(() {
          odaIsmi = roomData['odaIsmi'] ?? "Name not available";
          TurSayisi = roomData['Tursayisi'] ?? 0;
          Sifre = roomData['Sifre'] ?? "";
          KisiSayisi = roomData['KisiSayisi'] ?? 0;
        });

        // Listen to users in the room
        _realtimeService.getUsersInRoom(widget.odaismi).listen((kullanicilar) {
          setState(() {
            _internettenKullancilar = kullanicilar;
            if (kullanicilar.length == KisiSayisi) {
      _addAjanToFirestore();
    }
          });
        });
      } else {
        print("No such room.");
      }
    } catch (error) {
      print("Hata oluştu: hata $error");
    }
  }

  Future<void> removeUserFromRoom(String roomId, String username) async {
    final ref = FirebaseDatabase.instance.ref('odalar/$roomId/kullaniciadi');
    final event = await ref.once();

    if (event.snapshot.exists) {
      List<dynamic> users = List.from(event.snapshot.value as List);
      users.remove(username);
      await ref.set(users);
    }
  }

  // Remove this method as it's duplicated
  Future<void> _handleAppClose() async {
    try {
      await _realtimeService.deleteRoom(widget.odaismi);
      debugPrint('Uygulama kapandı, oda silindi.');
    } catch (e) {
      debugPrint('Oda silinirken hata: $e');
    }
  }

  // Remove this dispose method as we have another one
 

  // Get user list from Realtime Database
  Future<List<String>> getUsersInRoom(String odaIsmi) async {
    final snapshot = await _database
        .child('odalar')
        .child(odaIsmi)
        .child('kullaniciadi')
        .get();

    if (snapshot.exists) {
      List<dynamic> data = snapshot.value as List<dynamic>;
      List<String> kullaniciAdlari =
          data.map((item) => item.toString()).toList();
      // Save user list to RoomProvider
      Provider.of<RoomProvider>(context, listen: false)
          .setUserList(kullaniciAdlari);
      return kullaniciAdlari;
    }
    return [];
  }

  // Fake data get fonksiyonu simüle edelim

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? result = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Odayı Kapatma'),
              content:
                  const Text('Odayı kapatmak istediğinizden emin misiniz?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Hayır'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _realtimeService.deleteRoom(widget.odaismi);
                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Evet'),
                ),
              ],
            );
          },
        );
        return result ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue.shade700,
          title: Text(
            widget.BuKim
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
          child: _dataLoaded
              ? ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade100,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.meeting_room,
                                      color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Oda İsmi: $odaIsmi',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.lock_outline,
                                      color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Şifre: ${Sifre.isEmpty ? "Herkese Açık" : Sifre}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.casino_outlined,
                                      color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Oynanacak El Sayısı: $TurSayisi',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._generateContainers(
                        KisiSayisi), // Eğer List<Widget> döndürüyorsa
                    const SizedBox(height: 20),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: _internettenKullancilar.length == KisiSayisi
                  ? [Colors.green.shade400, Colors.green.shade700]
                  : [Colors.grey.shade400, Colors.grey.shade700],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: const Offset(0, 4),
                blurRadius: 5.0,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: _internettenKullancilar.length == KisiSayisi
                ? () async {
                    bool? result = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.95),
                          title: const Text('Oyuna Başla',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text(
                              'Sonraki sayfaya geçmek istediğinize emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hayır',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Evet',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );

                    if (result == true) {
                      await _fetchRoomDataAndSetProvider();
                      await updateUserIndex(context);

                      UserDataFetcher userDataFetcher = UserDataFetcher();
                      await userDataFetcher.SonrakiSayfaGecTiklandi(context);

                      if (!context.mounted) return;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StreamBuilder<bool>(
                            stream:
                                userDataFetcher.SonrakiSayfaGecilsinmi(context),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.of(context).pop();
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            KisiSecmeListesi(),
                                      ),
                                    );
                                  }
                                });
                              }
                              return const AlertDialog(
                                title: Text('Bekleniyor...'),
                                content:
                                    Text('Diğer kullanıcılar için bekleniyor'),
                              );
                            },
                          );
                        },
                      );
                    }
                  }
                : null,
            label: Text(
              _internettenKullancilar.length == KisiSayisi
                  ? 'İleri'
                  : 'Oyuncu Bekleniyor (${_internettenKullancilar.length}/$KisiSayisi)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            icon: Icon(
              _internettenKullancilar.length == KisiSayisi
                  ? Icons.arrow_forward
                  : Icons.hourglass_empty,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<void> _fetchRoomDataAndSetProvider() async {
    try {
      // Get room data from Realtime Database
      final roomData = await _realtimeService.getRoomData(widget.odaismi);

      if (roomData != null) {
        // Get KisiSayisi and TurSayisi values
        int fetchedKisiSayisi = roomData['KisiSayisi'] ?? 0;
        int fetchedTurSayisi = roomData['Tursayisi'] ?? 0;
        String fetchedSifre = roomData['Sifre'] ?? "";

        // Update through RoomProvider
        Provider.of<RoomProvider>(context, listen: false).updateRoomInfo(
            kisiSayisi: fetchedKisiSayisi,
            turSayisi: fetchedTurSayisi,
            odaIsmi: widget.odaismi,
            sifre: fetchedSifre,
            buKim: widget.BuKim);

        print("Room data successfully updated in provider.");
      } else {
        print("Specified room not found.");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  Future<void> _addAjanToFirestore() async {
    if (_internettenKullancilar.isEmpty || TurSayisi <= 0) {
      print('Yeterli kullanıcı veya tur sayısı yok.');
      return;
    }
    final random = Random();
    List<String> ajanListesi = List.generate(
      TurSayisi,
      (index) => _internettenKullancilar[
          random.nextInt(_internettenKullancilar.length)],
    );

    try {
      Provider.of<SoruProvider>(context, listen: false)
          .setAjanListesi(ajanListesi);
      // Update ajan list in Realtime Database
      await _database
          .child('odalar')
          .child(widget.odaismi)
          .child('ajan')
          .set(ajanListesi);

      print('Ajan listesi başarıyla eklendi: $ajanListesi');
    } catch (error) {
      print('Ajan listesi eklenirken hata oluştu: $error');
    }
  }

  List<Widget> _generateContainers(int count) {
    return List.generate(count, (index) {
      String? kullaniciAdi = index < _internettenKullancilar.length
          ? _internettenKullancilar[index]
          : null;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: kullaniciAdi != null
                    ? [Colors.green.shade200, Colors.green.shade400]
                    : [Colors.grey.shade200, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  kullaniciAdi != null ? Icons.person : Icons.person_outline,
                  color: kullaniciAdi != null ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(
                kullaniciAdi ?? 'Bekleniyor...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: kullaniciAdi != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              trailing: kullaniciAdi != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Kullanıcıyı At'),
                                  content: Text(
                                      '$kullaniciAdi adlı kullanıcıyı odadan atmak istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Hayır'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Evet'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await removeUserFromRoom(
                                  widget.odaismi, kullaniciAdi);
                            }
                          },
                        ),
                      ],
                    )
                  : const Icon(Icons.hourglass_empty, color: Colors.white70),
            ),
          ),
        ),
      );
    });
  }

  Future<int> getUserIndex(String odaIsmi, String kullaniciAdi) async {
    List<String> users =
        await getUsersInRoom(odaIsmi); // Kullanıcı listesini al
    return users.indexOf(kullaniciAdi); // Kullanıcının sırasını döndür
  }

  Future<void> updateUserIndex(BuildContext context) async {
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);

    // Asenkron fonksiyon olduğu için sonucu beklemelisin
    int index = await getUserIndex(odaIsmi, Username);

    // RoomProvider'daki KullaniciSirasi değerini güncelle
    roomProvider.kullaniciSirasi = index;
  }
}
