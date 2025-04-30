import 'package:flutter/material.dart';

class PuanlamaNasilOynanirScreen extends StatelessWidget {
  const PuanlamaNasilOynanirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan görseli
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_dark.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Saydam siyah kutu üstüne yazılar
          Container(
            color: Colors.black.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Puanlama — Kişilik Tahmin Oyunu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "• Oyuncu Sayısı: 3 - 8 kişi\n"
                    "• Amaç: Gizli ajanı bulmak ve en çok puanı toplayarak oyunu kazanmak.\n",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Oyun Kuralları:",
                    style: _sectionTitleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "1. Oda Kurulumu:\n"
                    "   • Odayı kuran kişi kaç tur oynanacağını belirler.\n"
                    "   • Her turda yalnızca 1 ajan olur, diğerleri köylüdür.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "2. Tur Yapısı:\n"
                    "   • Her tur 3 elden oluşur.\n"
                    "   • Aynı ajan 3 el boyunca değişmeden kalır.\n"
                    "   • Yeni turda ajan yeniden seçilir.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "3. Soru Sistemi:\n"
                    "   • Köylülere: Net bir sıralama sorusu gelir.\n"
                    "     Örn: “Bu grubun 3. en kibar olanı kim?”\n"
                    "   • Ajana: Belirsiz bir sıralama aralığı sorulur.\n"
                    "     Örn: “Bu grubun 2., 3. veya 4. en kibar olanı kim?” (Buradaki verilen sayılardan biri köylülere giden değerle aynı)\n"
                    "   • Ajan, bu belirsizlikle doğru tahminde bulunmaya çalışır.\n",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Oylama Aşamaları (Her El):",
                    style: _sectionTitleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "1. Kişi Seçme:\n"
                    "   • Her oyuncu, kendisine gelen soruya göre bir kişiyi işaretler.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "2. Kim Kimi Seçti:\n"
                    "   • Herkese aynı soru gider: (Köylülere sorulan asıl soru, bu sayede ajan dahil herkes asıl soruyu görür))\n"
                    "   • Herkes bir kişiyi ajan olarak tahmin eder.\n"
                    "   • Kim kime oy verdiği açıkça gösterilir.\n"
                    "   • Köylüler: Doğru tahmin +5, yanlış tahmin -5 puan.\n"
                    "   • Ajan: Puan almaz ve kaybetmez.\n"
                    "   • Ajanın amacı: Şüphe çekmeden diğerlerini yanıltmak.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "3. Kime Kaç Oy:\n"
                    "   • Her oyuncunun kaç oy aldığı gösterilir.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Puanlama:",
                    style: _sectionTitleStyle,
                  ),
                  Text(
                    "• Doğru tahmin (köylü): +5 puan\n"
                    "• Yanlış tahmin (köylü): -5 puan\n"
                    "• Ajan: Her durumda 0 puan",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Oyun Sonu:\n"
                    "• Belirlenen tur sayısı sonunda en yüksek puana sahip oyuncu kazanır.",
                    style: _ruleStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _ruleStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w600,
  fontSize: 16,
);

const TextStyle _sectionTitleStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 18,
);
