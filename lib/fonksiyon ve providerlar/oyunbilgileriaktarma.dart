import 'package:flutter/cupertino.dart';

class RoomProvider extends ChangeNotifier {
  int? turSayisi;
  String? odaIsmi;
  String? sifre;
  int? kisiSayisi;
  bool? buKim;
  List<String>? kullaniciAdi;
  int? elSayisi;
  int? oyuniciTurSayisi;
  int? kullaniciSirasi;
  bool? isAjan = false;
  List<String>? _userList;
  int? oyunIciElSayisi;
  Map<String, int>? _puanlama;
  
  Map<String, int>? get puanlama => _puanlama;

  void updatePuanlama(Map<String, int> puanlar) {
    _puanlama = puanlar;
    notifyListeners();
  }

  void setUserList(List<String> users) {
    _userList = users;
    notifyListeners();
  }

  void updateRoomInfo({
    int? turSayisi,
    String? odaIsmi,
    String? sifre,
    int? kisiSayisi,
    bool? buKim,
    int? elSayisi,
    int? oyuniciTurSayisi,
    int? kullaniciSirasi,
    bool? isAjan,
    int? oyunIciElSayisi,
    int? puan,
  }) {
    this.turSayisi = turSayisi;
    this.odaIsmi = odaIsmi;
    this.sifre = sifre;
    this.kisiSayisi = kisiSayisi;
    this.buKim = buKim;
    this.elSayisi = elSayisi;
    this.oyuniciTurSayisi = oyuniciTurSayisi;
    this.kullaniciSirasi = kullaniciSirasi;
    this.oyunIciElSayisi = oyunIciElSayisi;
    this.isAjan = isAjan;


    notifyListeners();
  }
}
