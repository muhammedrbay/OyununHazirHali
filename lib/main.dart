import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'firebase_options.dart';
import 'soruveajan/soruveajaninternettenalma.dart';
import 'fonksiyon ve providerlar/kullanıcıbilgileriaktarma.dart';
import 'fonksiyon ve providerlar/oyunbilgileriaktarma.dart';
import 'başlangıç dosyaları/anasayfa.dart';
import 'package:provider/provider.dart';

void main() async {
  print('main dosyası başlatıldı');
  WidgetsFlutterBinding.ensureInitialized();

  /// 🚫 Simülatörde çalışmayı engelle (sadece gerçek cihazda izin iste)
  if (!kIsWeb && Platform.isIOS && !Platform.isMacOS) {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(Duration(milliseconds: 300)); // iOS bug fix
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  /// ✅ Google Mobile Ads başlat
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    print('✅ Reklamlar yüklendi');
  }

  /// ✅ Firebase başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseDatabase database = FirebaseDatabase.instance;
  database.databaseURL =
      'https://bukim-1a232-default-rtdb.europe-west1.firebasedatabase.app';

  if (!kIsWeb) {
    try {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      print("✅ Firebase Realtime Database Persistence Enabled!");
    } catch (e) {
      print("❌ Firebase Realtime Database Persistence Error: $e");
    }
  }

  await testFirebaseServices();
  await testRealtimeDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SoruProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> testFirebaseServices() async {
  try {
    print("🔄 Firebase servisleri test ediliyor...");

    final database = FirebaseDatabase.instance.ref();
    await database.child('test').set({
      'message': 'Realtime Database bağlantısı başarılı!',
      'timestamp': DateTime.now().toString(),
    });
    print("✅ Firebase Realtime Database başarılı!");

    print("🎉 Tüm Firebase servisleri başarıyla test edildi!");
  } catch (e) {
    print("❌ Firebase bağlantı hatası: $e");
  }
}

Future<void> testRealtimeDatabase() async {
  final databaseRef = FirebaseDatabase.instance.ref();

  try {
    await databaseRef.child("test").set({
      "message": "Realtime Database bağlantısı başarılı!",
      "timestamp": DateTime.now().toString(),
    });
    print("✅ Realtime Database'e veri yazıldı!");

    databaseRef.child("test").onValue.listen((event) {
      if (event.snapshot.exists) {
        print(
            "✅ Firebase Realtime Database'den veri okundu: ${event.snapshot.value}");
      } else {
        print("❌ Veri okunamadı!");
      }
    });
  } catch (e) {
    print("❌ Realtime Database Hatası: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giriş Sayfası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      builder: (context, child) {
        // Check if the platform is web
        if (kIsWeb) {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.9,
                      child: child ?? const SizedBox(),
                    ),
                  ],
                );
              },
            ),
          );
        }
        // For mobile platforms (iOS and Android)
        return child ?? const SizedBox();
      },
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Sayfası',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade200],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/ajanfoto.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: const Center(
          child: LoginButton(),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Giriş Yap',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Giriş Yap',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade800, Colors.blue.shade200],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/ajanfoto.png'),
              fit: BoxFit.cover,
              opacity: 0.6,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.blue.shade900),
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı giriniz',
                      labelStyle: TextStyle(color: Colors.blue.shade800),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_usernameController.text.isNotEmpty) {
                        Provider.of<UserProvider>(context, listen: false)
                            .updateUser(_usernameController.text);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
