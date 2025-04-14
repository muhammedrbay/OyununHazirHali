
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fonksiyon ve providerlar/müzik.dart';

class AyarlarScreen extends StatelessWidget {
  const AyarlarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicPlayerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 8,
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
            color: Colors.black.withOpacity(0.6),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.settings,
                      size: 50,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ses Ayarları',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Müziği Aç / Kapat",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        secondary: Icon(
                          musicProvider.isPlaying ? Icons.music_note : Icons.music_off,
                          color: Colors.blue,
                        ),
                        value: musicProvider.isPlaying,
                        onChanged: (_) => musicProvider.toggleMusic(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Ses Seviyesi: ${(musicProvider.volume * 100).round()}%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: musicProvider.volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.withOpacity(0.3),
                      onChanged: (value) {
                        musicProvider.setVolume(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

