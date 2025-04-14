import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = '';

  String get username => _username;

  void updateUser(String username) { // Surname parametresi ekledik
    _username = username; // Surname güncelleme işlemi
    notifyListeners();
  }
}