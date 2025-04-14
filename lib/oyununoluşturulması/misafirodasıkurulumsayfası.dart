import 'dart:async';
import 'package:flutter/material.dart';
import '../fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import 'package:provider/provider.dart';
import 'misafirodakurulum2.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import 'package:firebase_database/firebase_database.dart';

class Misafirodakurulumsayfasi extends StatefulWidget {
  final bool buKim;

  const Misafirodakurulumsayfasi({super.key, required this.buKim});

  @override
  _MisafirodakurulumsayfasiState createState() =>
      _MisafirodakurulumsayfasiState();
}

class _MisafirodakurulumsayfasiState extends State<Misafirodakurulumsayfasi> {
  late Future<List<Map<String, dynamic>>> roomsFuture;
  late String _username;
  late bool OdayaKatildi = false;
  TextEditingController sifreController = TextEditingController();
  bool Sahip = false;

  @override
  void dispose() {
    sifreController.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();
  roomsFuture = fetchRooms();
}

void didChangeDependencies() {
  super.didChangeDependencies();
  setState(() {
    roomsFuture = fetchRooms(); // sayfa görününce her defa çekilir
  });
}


  Future<void> handleRoomJoin(Map<String, dynamic> room) async {
    try {
      _username = Provider.of<UserProvider>(context, listen: false).username;

      // Check current room capacity
      final DatabaseReference ref = FirebaseDatabase.instance
          .ref('odalar/${room['odaIsmi']}/kullaniciadi');
      final DatabaseEvent event = await ref.once();

      if (event.snapshot.exists) {
        List<dynamic> currentUsers = event.snapshot.value as List<dynamic>;
        if (currentUsers.contains(_username)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Aynı isme sahip başka kullanıcı var!')));
          return;
        }
        if (currentUsers.length >= room['KisiSayisi']) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Oda dolmuştur!')));
          return;
        }
      }

      await addNewUserToRoom(room['odaIsmi'], _username);

      if (!mounted) return; // Check if widget is still mounted

      Provider.of<RoomProvider>(context, listen: false).updateRoomInfo(
        odaIsmi: room['odaIsmi'],
        sifre: room['şifre'],
        buKim: widget.buKim,
        turSayisi: room['Tursayisi'],
        kisiSayisi: room['KisiSayisi'],
      );

      Navigator.of(context).pop(); // Close the dialog before navigating
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Oyunkurulumsayfasi(BuKim: widget.buKim),
        ),
      );
    } catch (e) {
      print("Error in handleRoomJoin: $e");
      if (mounted) {
        // Check if widget is still mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Odaya katılırken bir hata oluştu: ${e.toString()}')));
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchRooms() async {
    List<Map<String, dynamic>> roomList = [];

    try {
      roomList.clear();
      print("✅ Existing rooms cleared");

      final DatabaseReference dbRef = FirebaseDatabase.instance.ref('odalar');
      final Query query = dbRef.orderByKey();
      final DataSnapshot snapshot = await query.get();

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((roomKey, roomData) {
          if (roomData is Map) {
            // Only add rooms that match the buKim value
            bool roomBuKim = roomData["buKim"] as bool? ?? false;
            if (roomBuKim == widget.buKim) {
              roomList.add({
                "odaIsmi": roomKey,
                "Tursayisi": (roomData["Tursayisi"] as num?)?.toInt() ?? 0,
                "şifre": roomData["şifre"]?.toString() ?? "",
                "KisiSayisi": (roomData["KisiSayisi"] as num?)?.toInt() ?? 0,
              });
            }
          }
        });
        print("✅ Odalar başarıyla çekildi!");
        print("📝 Çekilen Odalar (buKim: ${widget.buKim}):");
        roomList.forEach((room) {
          print("   🏠 ${room['odaIsmi']}");
        });
      } else {
        print("❌ Veritabanında oda bulunamadı!");
      }
    } catch (e) {
      print("❌ Firebase Realtime Database Hatası: ${e.toString()}");
    }
    return roomList;
  }


  Future<void> addNewUserToRoom(
      String selectedRoomId, String newUsername) async {
    try {
      final DatabaseReference ref =
          FirebaseDatabase.instance.ref('odalar/$selectedRoomId/kullaniciadi');
      final DatabaseEvent event = await ref.once();

      List<dynamic> currentUsers = [];

      if (event.snapshot.exists) {
        currentUsers =
            List<dynamic>.from(event.snapshot.value as List<dynamic>);
        // 🔧 Null olanları temizle
        currentUsers.removeWhere((user) => user == null);
      }

      // ➕ Yeni kullanıcıyı ekle
      currentUsers.add(newUsername);

      // 🔄 Güncellenmiş listeyi tekrar yaz
      await ref.set(currentUsers);
    } catch (error) {
      print("❌ Kullanıcı eklenirken hata oluştu: $error");
      throw error;
    }
  }

  Future<void> _showInputDialog(BuildContext context, String odaIsmi,
      String Sifre, int TurSayisi, int KisiSayisi) async {
    if (Sifre.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Odaya Katıl',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.meeting_room,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  '$odaIsmi odasına katılmak istediğinize emin misiniz?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text(
                  'İptal',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  OdayaKatildi = true;
                  await handleRoomJoin({
                    'odaIsmi': odaIsmi,
                    'şifre': Sifre,
                    'Tursayisi': TurSayisi,
                    'KisiSayisi': KisiSayisi
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Katıl',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Şifre Girin',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sifreController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text(
                  'İptal',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (sifreController.text == Sifre) {
                    OdayaKatildi = true;
                    await handleRoomJoin({
                      'odaIsmi': odaIsmi,
                      'şifre': Sifre,
                      'Tursayisi': TurSayisi,
                      'KisiSayisi': KisiSayisi
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Yanlış şifre!'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Giriş',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.buKim
              ? 'BuKim oyunu odaya katılma'
              : 'Puanlama oyunu odaya katılma',
        ),
        // Add refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                roomsFuture = fetchRooms();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ajanbaslangic.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: roomsFuture,
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Hata: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          color: Colors.white, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        'Hiç oda bulunamadı',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () {
                          _showInputDialog(
                            context,
                            room['odaIsmi'],
                            room['şifre'],
                            room['Tursayisi'],
                            room['KisiSayisi'],
                          );
                        },
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Oda İsmi: ${room['odaIsmi']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.sports_esports,
                                          color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Oyun Sayısı: ${room['Tursayisi']}',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.group,
                                          color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kişi Sayısı: ${room['KisiSayisi']}',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _privateRoomSearch(context);
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  void _privateRoomSearch(BuildContext context) async {
    TextEditingController odaIsmiController = TextEditingController();
    TextEditingController sifreController = TextEditingController();

    List<Map<String, dynamic>> rooms = await roomsFuture;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Private Room Girişi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: odaIsmiController,
                decoration: const InputDecoration(
                  hintText: 'oda ismi',
                ),
              ),
              TextField(
                controller: sifreController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Şifre',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  String odaIsmi = odaIsmiController.text;
                  String password = sifreController.text;

                  final room = rooms.firstWhere(
                    (room) =>
                        room['odaIsmi'] == odaIsmi && room['şifre'] == password,
                    orElse: () => {},
                  );

                  if (room.isNotEmpty) {
                    // Check room capacity
                    final DatabaseReference ref = FirebaseDatabase.instance
                        .ref('odalar/${room["odaIsmi"]}/kullaniciadi');
                    final DatabaseEvent event = await ref.once();

                    if (event.snapshot.exists) {
                      List<dynamic> currentUsers =
                          event.snapshot.value as List<dynamic>;
                      if (currentUsers.contains(_username)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Aynı isme sahip başka kullanıcı var!')));
                        return;
                      }
                      if (currentUsers.length >= room['KisiSayisi']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Oda dolmuştur!')));
                        return;
                      }
                    }

                    _username =
                        Provider.of<UserProvider>(context, listen: false)
                            .username;
                    Provider.of<RoomProvider>(context, listen: false)
                        .updateRoomInfo(
                      odaIsmi: room['odaIsmi'],
                      sifre: room['şifre'],
                      buKim: widget.buKim,
                      turSayisi: room['Tursayisi'],
                      kisiSayisi: room['KisiSayisi'],
                    );
                    await addNewUserToRoom(odaIsmi, _username);
                    Navigator.pop(context); // Close the dialog first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Oyunkurulumsayfasi(
                          BuKim: widget.buKim,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Yanlış kullanıcı adı veya şifre!')));
                  }
                } catch (e) {
                  print("Error in private room search: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bir hata oluştu: $e')));
                }
              },
              child: const Text('Giriş'),
            ),
          ],
        );
      },
    );
  }
}
