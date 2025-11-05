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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatIcon(
                icon: Icons.people,
                value: stats.halk,
                color: Colors.blue.shade300),
            StatIcon(
                icon: Icons.nightlight_round,
                value: stats.golge,
                color: Colors.purple.shade300),
            StatIcon(
                icon: Icons.paid,
                value: stats.hazine,
                color: Colors.yellow.shade300),
            StatIcon(
                icon: Icons.shield,
                value: stats.bekciler,
                color: Colors.red.shade300),
          ],
        );
      },
    );
  }
}
