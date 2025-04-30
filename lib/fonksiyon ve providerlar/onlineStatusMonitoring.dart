import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../oyunnun kendisi/SonucSayfasi.dart';
import '../oyunnun kendisi/kimekaçoy.dart';
import '../oyunnun kendisi/kimkimisecti.dart';
import '../oyunnun kendisi/kişiseçmesayfasi.dart';
import '../oyunnun kendisi/puanlama.dart';
import 'firebase_realtime_service.dart';
import 'oyunbilgileriaktarma.dart';

class OnlineStatusMonitor {
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _onlineStatusSubscription;

  void startMonitoring(BuildContext context) async {
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    String referencePath = roomProvider.odaIsmi!;
    int index = roomProvider.kullaniciSirasi!;

    // Check if room exists by checking 'ajan' field
    DatabaseReference roomRef =
        FirebaseDatabase.instance.ref("odalar/$referencePath/buKim");
    DataSnapshot roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) {
      print(
          'Room $referencePath does not exist or is invalid, skipping online status monitoring');
      return;
    }

    // Monitor connection status
    DatabaseReference connectedRef =
        FirebaseDatabase.instance.ref('.info/connected');
    _connectionSubscription = connectedRef.onValue.listen((event) {
      bool isConnected = event.snapshot.value as bool? ?? false;
      bool shouldBeMarkedOffline = !isConnected;
      _updateOnlineStatus(referencePath, index, shouldBeMarkedOffline);
    });

    // Monitor online status changes
    DatabaseReference onlineStatusRef = FirebaseDatabase.instance
        .ref('odalar/$referencePath/onlineStatus/$index');
    _onlineStatusSubscription = onlineStatusRef.onValue.listen((event) {
      bool currentStatus = event.snapshot.value as bool? ?? true;
      if (currentStatus) {
        _updateOnlineStatus(referencePath, index, true);
      }
    });
  }

  Future<void> _updateOnlineStatus(
      String referencePath, int index, bool isConnected) async {
    DatabaseReference parentRef =
        FirebaseDatabase.instance.ref('odalar/$referencePath/onlineStatus');
    final snapshot = await parentRef.get();

    if (snapshot.exists) {
      DatabaseReference ref = parentRef.child('$index');
      await ref.set(isConnected);
      print('User online status updated for index $index to $isConnected');
    } else {
      print('Path does not exist: odalar/$referencePath/onlineStatus');
      // set() işlemi yapılmıyor
    }
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _onlineStatusSubscription?.cancel();
  }

  StreamSubscription? _counterListener;
  Timer? _sabitlikTimer;

  void kontrolEtVeYonlendir(BuildContext context, String sayfaIsmi) {
    String odaIsmi = Provider.of<RoomProvider>(context, listen: false).odaIsmi!;
    int turSayisi =
        Provider.of<RoomProvider>(context, listen: false).turSayisi!;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("odalar/$odaIsmi/Counter");

    int? lastValue;

    _counterListener = ref.onValue.listen((event) {
      if (event.snapshot.value == null) return;
      int currentValue = event.snapshot.value as int;

      print("Veri geldi: $currentValue");
      _sabitlikTimer?.cancel();
      lastValue = currentValue;

      _sabitlikTimer = Timer(const Duration(seconds: 3), () {
        print("3 saniyedir veri gelmedi, son değer: $lastValue");

        int birlerBasamagi = lastValue! % 10;
        int onlarBasamagi = (lastValue! ~/ 10) % 10;

        String hedefSayfaIsmi = "";

        // Eğer onlar basamağı tur sayısına ve birler basamağı 1'e eşitse sonuç sayfasına yönlendir
        if (onlarBasamagi == turSayisi && birlerBasamagi == 1) {
          hedefSayfaIsmi = "sonuc";
        } else if ([1, 4, 7].contains(birlerBasamagi)) {
          hedefSayfaIsmi = "kisisecme";
        } else if ([2, 5, 8].contains(birlerBasamagi)) {
          hedefSayfaIsmi = "kimkimisecti";
        } else if ([3, 6, 9].contains(birlerBasamagi)) {
          hedefSayfaIsmi = "kimekacoy";
        } else if (birlerBasamagi == 0) {
          hedefSayfaIsmi = "puanlama";
        }

        if (sayfaIsmi == hedefSayfaIsmi) {
          print("Zaten doğru sayfadasın ($sayfaIsmi), yönlendirme yapılmadı.");
          return;
        }

        if (!context.mounted) {
          print("Yönlendirme yapılamadı çünkü context artık geçerli değil.");
          return;
        }

        Widget hedefSayfa;
        switch (hedefSayfaIsmi) {
          case "sonuc":
            hedefSayfa = SonucSayfasi(); // Add proper score table
            break;
          case "kisisecme":
            hedefSayfa = KisiSecmeListesi();
            break;
          case "kimkimisecti":
            hedefSayfa = KimKimisecti();
            break;
          case "kimekacoy":
            hedefSayfa = KimeKacOy();
            break;
          case "puanlama":
            hedefSayfa = PuanlamaWidget();
            break;
          default:
            return;
        }

        _counterListener?.cancel();

        // 👉 Microtask ile geçişi bir sonraki frame'e al
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => hedefSayfa),
          );
        });
      });
    });
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

// First part remains unchanged...

// For game pages (oyunun kendisi)
class GameLifecycleHandler extends WidgetsBindingObserver {
  final BuildContext context;
  final FirebaseRealtimeService _firebaseService = FirebaseRealtimeService();

  GameLifecycleHandler({
    required this.context,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      try {
        final roomProvider = Provider.of<RoomProvider>(context, listen: false);
        final referencePath = roomProvider.odaIsmi!;
        final userIndex = roomProvider.kullaniciSirasi!;

        // Önce referansın var olup olmadığını kontrol et
        final statusRef = FirebaseDatabase.instance
            .ref('odalar/$referencePath/onlineStatus/$userIndex');
        final snapshots = await statusRef.get();

        // Eğer referans varsa set işlemini yap
        if (snapshots.exists) {
          await statusRef.set(true);
          print('✅ Kullanıcı durumu güncellendi: $userIndex -> true');
        } else {
          print('❌ Belirtilen yol bulunamadı: odalar/$referencePath/onlineStatus/$userIndex');
          return;
        }

        final allStatusRef =
            FirebaseDatabase.instance.ref('odalar/$referencePath/onlineStatus');
        final snapshot = await allStatusRef.get();

        if (snapshot.exists && snapshot.value is List) {
          List<dynamic> statuses = List.from(snapshot.value as List);
          bool allTrue = statuses.every((status) => status == true);

          if (allTrue) {
            await _firebaseService.deleteRoom(referencePath);
            print('Room $referencePath deleted as all users are offline');
          }
        }
      } catch (e) {
        print('Error in lifecycle handler: $e');
      }
    }
  }
}

// For room creation (odaoluşturma2)
class RoomLifecycleHandler extends WidgetsBindingObserver {
  final Future<void> Function() detachedCallBack;

  RoomLifecycleHandler({required this.detachedCallBack});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      detachedCallBack();
    }
  }
}
