import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'oyunbilgileriaktarma.dart';

class UserDataFetcher {
  Stream<bool> SonrakiSayfaGecilsinmi(BuildContext context) {
    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    String odaIsmi = roomProvider.odaIsmi!;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('odalar/$odaIsmi/Sonrakisayfa');

    return ref.onValue.asyncMap((event) async {
      if (event.snapshot.exists) {
        List<dynamic> sonrakiSayfa = event.snapshot.value as List<dynamic>;

        // onlineStatus verisini çekiyoruz
        DatabaseReference onlineStatusRef =
            FirebaseDatabase.instance.ref('odalar/$odaIsmi/onlineStatus');
        DatabaseEvent onlineStatusEvent = await onlineStatusRef.once();

        if (!onlineStatusEvent.snapshot.exists) {
          print("onlineStatus verisi bulunamadı.");
          return false;
        }

        List<dynamic> onlineStatus =
            onlineStatusEvent.snapshot.value as List<dynamic>;

        // iki listeyi birleştiriyoruz
        List<bool> combined = List.generate(sonrakiSayfa.length, (index) {
          final val1 = sonrakiSayfa[index] == true;
          final val2 =
              onlineStatus.length > index && onlineStatus[index] == true;
          return !(val1 == false && val2 == false);
        });

        bool allTrue = combined.every((value) => value == true);
        print("BİRLEŞİK kontrol sonucu: $combined | Hepsi true mu? $allTrue");

        return allTrue;
      } else {
        print("Sonrakisayfa verisi bulunamadı.");
        return false;
      }
    });
  }

  Future<void> SonrakiSayfaGecTiklandi(BuildContext context) async {
    try {
      RoomProvider roomProvider =
          Provider.of<RoomProvider>(context, listen: false);
      String odaIsmi = roomProvider.odaIsmi!;
      int index = roomProvider.kullaniciSirasi!;
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("odalar/$odaIsmi/Sonrakisayfa/$index");

      await ref.set(true);
      print("Index $index başarıyla true yapıldı.");
    } catch (error) {
      print("Hata oluştu: $error");
    }
  }
}
