import 'package:flutter/material.dart';
import '../fonksiyon ve providerlar/firebase_realtime_service.dart';

class SoruProvider extends ChangeNotifier {
  final FirebaseRealtimeService _firebaseService = FirebaseRealtimeService();
  List<Map<String, dynamic>> _soruListesi = [];
  List<String> _ajanListesi = [];
  String? _currentRoom;

  List<Map<String, dynamic>> get soruListesi => _soruListesi;
  List<String> get ajanListesi => _ajanListesi;

  void setCurrentRoom(String odaIsmi) {
    _currentRoom = odaIsmi;
    print('📍 setCurrentRoom - Oda ismi: $_currentRoom');
  }

  Future<void> setSoruListesi(List<Map<String, dynamic>> yeniSoruListesi) async {
    _soruListesi = yeniSoruListesi;
    if (_currentRoom != null) {
      await _firebaseService.updateQuestionsAndAgents(
          _currentRoom!, yeniSoruListesi, _ajanListesi);
    }
    print('📍 setSoruListesi - Yeni soru listesi: $_soruListesi');
    notifyListeners();
  }

  Future<void> setAjanListesi(List<String> yeniAjanListesi) async {
    _ajanListesi = yeniAjanListesi;
    if (_currentRoom != null) {
      await _firebaseService.updateQuestionsAndAgents(
          _currentRoom!, _soruListesi, yeniAjanListesi);
    }
    print('📍 setAjanListesi - Yeni ajan listesi: $_ajanListesi');
    notifyListeners();
  }

  Future<void> addSoru(Map<String, dynamic> yeniSoru) async {
    _soruListesi.add(yeniSoru);
    if (_currentRoom != null) {
      await _firebaseService.updateQuestionsAndAgents(
          _currentRoom!, _soruListesi, _ajanListesi);
    }
    print('📍 addSoru - Eklenen soru: $yeniSoru');
    print('📍 addSoru - Güncel soru listesi: $_soruListesi');
    notifyListeners();
  }

  Future<void> clearSoruListesi() async {
    _soruListesi.clear();
    if (_currentRoom != null) {
      await _firebaseService.updateQuestionsAndAgents(
          _currentRoom!, [], _ajanListesi);
    }
    print('📍 clearSoruListesi - Soru listesi temizlendi');
    notifyListeners();
  }

  Map<String, dynamic>? getSoruByIndex(int index,int Elsayisi) {
    if (index >= 0 && index < _soruListesi.length) {
      print('📍 getSoruByIndex - Index: $index, Soru: ${_soruListesi[index]}');
      return _soruListesi[(index*3)+Elsayisi-1];
    }
    print('📍 getSoruByIndex - Index: $index, Soru bulunamadı');
    return null;
  }

  String? ajankim(int index) {
    if (_ajanListesi.isEmpty) {
      print('📍 ajankim - Ajan listesi boş');
      return null;
    }
    if (index < 0 || index >= _ajanListesi.length) {
      print('📍 ajankim - Geçersiz index: $index');
      return null;
    }
    print('📍 ajankim - Index: $index, Ajan: ${_ajanListesi[index]}');
    return _ajanListesi[index];
  }

  bool ajanmi(int index, String username) {
    try {
      String? ajan = ajankim(index - 1);
      if (ajan == null) {
        print('📍 ajanmi - Ajan bulunamadı - Index: $index, Username: $username');
        return false;
      }
      bool sonuc = ajan == username;
      print('📍 ajanmi - Index: $index, Username: $username, Sonuç: $sonuc');
      return sonuc;
    } catch (e) {
      print('Error in ajanmi: $e');
      return false;
    }
  }

  Future<dynamic> InternettenSoru(int index, username,Elsayisi) async {
    Map<String, dynamic>? soru = getSoruByIndex(index,Elsayisi);
    print('📍 InternettenSoru - Index: $index, Username: $username');

    if (soru == null) {
      print('📍 InternettenSoru - Soru bulunamadı');
      throw Exception('Soru bulunamadı.');
    }
    
    bool KullaniciAjanMi = ajanmi(index+1, username);
    bool ajanMiSonucu = KullaniciAjanMi;
    print('📍 InternettenSoru - Kullanıcı ajan mı: $ajanMiSonucu');

    if (ajanMiSonucu) {
      dynamic ilkValue = soru.values.first;
      print('📍 InternettenSoru - Ajan için dönen soru: $ilkValue');
      return ilkValue;
    } else {
      String? ilkKey = soru.keys.first;
      print('📍 InternettenSoru - Normal kullanıcı için dönen soru: $ilkKey');
      return ilkKey;
    }
    
  }

  Future<dynamic> AsilSoru(int index,elSayisi) async {
    Map<String, dynamic>? soru = getSoruByIndex(index,elSayisi);
    print('📍 AsilSoru - Index: $index');

    if (soru == null) {
      print('📍 AsilSoru - Soru bulunamadı');
      throw Exception('Soru bulunamadı.');
    }

    dynamic ilkKey = soru.keys.first;
    print('📍 AsilSoru - Dönen soru: $ilkKey');
    return ilkKey;
  }
}
