import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _volume = 0.0;

  bool get isPlaying => _isPlaying;
  double get volume => _volume;

  Future<void> init() async {
    try {
      await _player.setAsset('assets/audio/arkaplanmuzik.mp3');
      await _player.setLoopMode(LoopMode.all);
      await _player.setVolume(_volume);
      _isPlaying = true;
      await _player.play();
      notifyListeners();
    } catch (e) {
      print('❌ Müzik başlatma hatası: $e');
    }
  }

  void toggleMusic() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (e) {
      print('❌ Müzik toggle hatası: $e');
    }
  }

  void setVolume(double val) async {
    try {
      _volume = val;
      await _player.setVolume(val);
      notifyListeners();
    } catch (e) {
      print('❌ Ses ayarlama hatası: $e');
    }
  }

  void disposePlayer() {
    _player.dispose();
  }
}
