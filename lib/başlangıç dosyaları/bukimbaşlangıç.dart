import 'package:flutter/material.dart';
import '../oyununoluşturulması/misafirodasıkurulumsayfası.dart';
import 'bukimnasiloynanir.dart';
import '../oyununoluşturulması/odaoluşturmasayfası.dart';
class BukimSayfasi extends StatelessWidget {
  static const bool buKim = true;
  static const Color primaryColor = Colors.orange;
  static const Color secondaryColor = Colors.yellow;
  static const Color backgroundColor = Colors.white;
  static const Color thirdColor = Colors.red;

  const BukimSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bu Kim',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 8,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ajanbaslangic.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  context,
                  'Bu Kim Odaya Katıl',
                  thirdColor,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const Misafirodakurulumsayfasi(buKim: buKim),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  'Bu Kim Oda Kur',
                  primaryColor,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OdaKurScreen(buKim: buKim),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  'Nasıl Oynanır',
                  secondaryColor,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NasilOynanirScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: backgroundColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
