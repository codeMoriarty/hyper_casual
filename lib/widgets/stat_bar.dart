import 'package:flutter/material.dart';
import 'package:hyper_casual/providers/game_provider.dart';
import 'package:hyper_casual/widgets/stat_icon.dart';
import 'package:provider/provider.dart';

class StatBar extends StatelessWidget {
  const StatBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Değişiklikleri dinlemek için Consumer kullan
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        // Wrap widget'ı 8 ikonu 4x2 şeklinde sığdırır
        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          runSpacing: 12.0, // Dikey boşluk
          spacing: 8.0, // Yatay boşluk
          children: [
            // --- Ana Kaynaklar ---
            StatIcon(
                icon: Icons.people,
                value: stats.halk,
                color: Colors.blue.shade300,
                maxValue: 100),
            StatIcon(
                icon: Icons.paid,
                value: stats.hazine, // Artık 2000
                color: Colors.yellow.shade300,
                maxValue: null), // Metin olarak göster
            StatIcon(
                icon: Icons.shield,
                value: stats.bekciler, // Ordu
                color: Colors.red.shade300,
                maxValue: 100),
            StatIcon(
                icon: Icons.auto_awesome, // Büyücü (eski 'golge')
                value: stats.golge,
                color: Colors.cyan.shade300,
                maxValue: 100),

            // --- Yeni İkincil Kaynaklar (GDD'den)  ---
            StatIcon(
                icon: Icons.visibility, // Gölge Deposu
                value: stats.golgeDeposu,
                color: Colors.purple.shade300,
                maxValue: 100),
            StatIcon(
                icon: Icons.engineering, // Teknoloji
                value: stats.teknoloji,
                color: Colors.grey.shade400,
                maxValue: 100),
            StatIcon(
                icon: Icons.handshake, // Diplomasi
                value: stats.diplomasi,
                color: Colors.orange.shade300,
                maxValue: 100),
            StatIcon(
                icon: Icons.mosque, // Din
                value: stats.din,
                color: Colors.brown.shade300,
                maxValue: 100),
          ],
        );
      },
    );
  }
}
