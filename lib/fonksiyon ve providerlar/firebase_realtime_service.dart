import 'package:firebase_database/firebase_database.dart';

class FirebaseRealtimeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Oda oluşturma
  Future<void> createRoom(String odaIsmi, Map<String, dynamic> roomData) async {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi");
    await ref.set(roomData);
  }

  // Odadaki kullanıcıları dinleme
  Stream<List<String>> getUsersInRoom(String odaIsmi) {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi/kullaniciadi");
    return ref.onValue.map((event) {
      if (event.snapshot.value != null) {
        List<dynamic> data = event.snapshot.value as List<dynamic>;
        return data.map((item) => item.toString()).toList();
      }
      return <String>[];
    });
  }

  // Oda bilgilerini alma
  Future<Map<String, dynamic>?> getRoomData(String odaIsmi) async {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }


  // Kullanıcı ekleme
  Future<void> addUserToRoom(String odaIsmi, String username) async {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi/kullaniciadi");
    final snapshot = await ref.get();

    List<String> users = [];
    if (snapshot.exists) {
      users = List<String>.from(snapshot.value as List);
    }

    if (!users.contains(username)) {
      users.add(username);
      await ref.set(users);
    }
  }

  // Soru ve ajan listelerini güncelleme
  Future<void> updateQuestionsAndAgents(
      String odaIsmi, List<Map<String, dynamic>> questions, List<String> agents) async {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi");
    final updates = {
      'soru': questions,
      'ajan': agents
    };
    await ref.update(updates);
  }

  // Oda isminin benzersiz olup olmadığını kontrol etme
  Future<bool> isRoomNameUnique(String odaIsmi) async {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi");
    final snapshot = await ref.get();
    return !snapshot.exists;
  }

  // Odayı silme
  Future<void> deleteRoom(String odaIsmi) async {
    DatabaseReference ref = _database.ref("odalar/$odaIsmi");
    await ref.remove();
  }
}
