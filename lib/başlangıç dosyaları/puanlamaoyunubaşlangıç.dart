import 'package:flutter/material.dart';
import '../oyununoluşturulması/misafirodasıkurulumsayfası.dart';
import '../oyununoluşturulması/odaoluşturmasayfası.dart';
import 'puanlamanasiloyanir.dart';

class puanlamaOyunu extends StatelessWidget {
  bool buKim = false;

  // Renkler
  Color button1Color = Colors.blue;
  Color button2Color = Colors.green;
  Color button3Color = Colors.orange;

  puanlamaOyunu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sıralama Oyunu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: button1Color,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  context,
                  'Sıralama Odaya Katıl',
                  button1Color,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Misafirodakurulumsayfasi(buKim: buKim),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  'Sıralama Oda Kur',
                  button2Color,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OdaKurScreen(buKim: buKim)),
                  ),
                ),
                _buildButton(
                  context,
                  'Nasıl Oynanır',
                  button3Color,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PuanlamaNasilOynanirScreen()),
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
                style: TextStyle(
                  color: Colors.white,
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
