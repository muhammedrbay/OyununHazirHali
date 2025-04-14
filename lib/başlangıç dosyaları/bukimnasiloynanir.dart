import 'package:flutter/material.dart';

class NasilOynanirScreen extends StatelessWidget {
  const NasilOynanirScreen({super.key});

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
          // Saydam arka planlı yazılar
          Container(
            color: Colors.black.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Bu Kim? — Kişilik Tahmin Oyunu",
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
                    "   • Yeni turda ajan yeniden rastgele seçilir.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "3. Soru Sistemi:\n"
                    "   • Köylülere aynı soru, ajana benzer ama farklı bir soru gönderilir.\n"
                    "   • Herkes soruya göre bir kişiyi seçer.",
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
                    "   • Köylülere aynı soru, ajana farklı ama benzer bir soru gelir.\n"
                    "   • Her oyuncu soruya göre bir kişiyi işaretler.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "2. Kim Kimi Seçti:\n"
                    "   • Ajan dahil herkese aynı soru gider: (Bu sayede ajan dahil herkes asıl sorunun ne olduğunu görür)\n"
                    "   • Oyuncular ajanı tahmin eder, herkesin kime oy verdiği gösterilir.\n"
                    "   • Ajan puan almaz veya kaybetmez.\n"
                    "   • Köylüler doğru tahminde +5, yanlışta -5 puan alır.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "3. Kime Kaç Oy:\n"
                    "   • Her oyuncunun kaç oy aldığı gösterilir.\n"
                    "   • Şüpheli görünen oyuncular ortaya çıkar.",
                    style: _ruleStyle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Puanlama:",
                    style: _sectionTitleStyle,
                  ),
                  Text(
                    "• Doğru tahmin: +5 puan\n"
                    "• Yanlış tahmin: -5 puan\n"
                    "• Ajan puan almaz veya kaybetmez",
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
