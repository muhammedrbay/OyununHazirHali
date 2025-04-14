import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../başlangıç dosyaları/anasayfa.dart';
import '../fonksiyon ve providerlar/firebase_realtime_service.dart';
import '../fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import '../web_helpers/sonuc_ad_factory.dart';

class SonucSayfasi extends StatefulWidget {
  const SonucSayfasi({super.key});

  @override
  State<SonucSayfasi> createState() => _SonucSayfasiState();
}

class _SonucSayfasiState extends State<SonucSayfasi> {
  InterstitialAd? _interstitialAd;
  final FirebaseRealtimeService _realtimeService = FirebaseRealtimeService();
  late String odaIsmi;
  late int turSayisi;
  late Map<String, int> puanTablosu = {};

  @override
  @override
  void initState() {
    super.initState();

    final puanlar = Provider.of<RoomProvider>(context, listen: false).puanlama;
    if (puanlar != null) {
      setState(() {
        puanTablosu = puanlar;
      });
    }

    RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    odaIsmi = roomProvider.odaIsmi!;
    turSayisi = roomProvider.turSayisi!;

    // ✅ Android/iOS için tam ekran reklam
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _loadAndShowAd();
    }
    if (kIsWeb) {
      registerWebAdView(); // Web platformu için banner reklam HTML'i eklenir
    }

    _realtimeService.deleteRoom(odaIsmi);
  }

  void _loadAndShowAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-9576499265117171/5288141220'
          : 'ca-app-pub-9576499265117171/9780052017',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
            onAdShowedFullScreenContent: (ad) {},
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ Reklam yüklenemedi: $error");
        },
      ),
    );
  }

  void _showAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show().catchError((error) {
        debugPrint('Error showing ad: $error');
      });
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final sortedEntries = puanTablosu.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Sonuçlar'),
          backgroundColor: Colors.blue.shade700,
          elevation: 8,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ajanfoto.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Column(
              children: [
                // 🔹 Puan Listesi
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];
                      return Card(
                        elevation: 8.0,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}- ${entry.key}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Text(
                                'Puan: ${entry.value}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🔹 Web için reklam bloğu (puan ekranı sonunda)
                if (kIsWeb)
                  const SizedBox(
                    height: 100,
                    child: HtmlElementView(viewType: 'puan-ekrani-reklami'),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Onay'),
                    content: const Text(
                        'Sonuçları geçmek istediğinize emin misiniz?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Hayır'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Evet'),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Sonuçları Bitir'),
          ),
        ),
      ),
    );
  }
}
