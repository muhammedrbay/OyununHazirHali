import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'oyunbilgileriaktarma.dart';

class UserDataFetcher {
  Future<void> SonrakiSayfaGecTiklandi(BuildContext context) async {
    try {
      RoomProvider roomProvider =
          Provider.of<RoomProvider>(context, listen: false);
      String odaIsmi = roomProvider.odaIsmi!;
      int index = roomProvider.kullaniciSirasi!;

      // Önce referansın var olup olmadığını kontrol et
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("odalar/$odaIsmi/Sonrakisayfa/$index");
      final snapshot = await ref.get();

      // Eğer referans varsa set işlemini yap
      if (snapshot.exists) {
        await ref.set(true);
        print("✅ Index $index başarıyla true yapıldı.");
      } else {
        print(
            "❌ Belirtilen yol bulunamadı: odalar/$odaIsmi/Sonrakisayfa/$index");
        return;
      }
    } catch (error) {
      print("❌ Hata oluştu: $error");
    }
  }
}
