import 'package:flame/game.dart'; // Game nesnesi için
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // PostFrameCallback için
import 'package:hyper_casual/providers/game_provider.dart';
import 'package:hyper_casual/widgets/card_view.dart';
import 'package:hyper_casual/widgets/game_over_overlay.dart';
import 'package:hyper_casual/widgets/stat_bar.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  // GÜNCELLEME: 'game' nesnesini main.dart'tan alıyoruz
  final Game game;

  const GameScreen({
    super.key,
    required this.game, // Constructor'a ekledik
  });

  @override
  Widget build(BuildContext context) {
    // Ekranın en üstüne ve altına sistem çubukları için boşluk bırak
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Stat Barları
            const StatBar(),
            const SizedBox(height: 24),

            // 2. Kart / Oyun Bitiş Ekranı
            Expanded(
              child: Consumer<GameProvider>(
                builder: (context, provider, child) {
                  // --- YENİ OVERLAY YÖNETİMİ ---
                  // Build bittikten sonra overlay'i güvenle yönet
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    final miniGameActive =
                        game.overlays.isActive('PazarYangini');

                    if (provider.isMiniGameActive && !miniGameActive) {
                      game.overlays.add('PazarYangini');
                    } else if (!provider.isMiniGameActive && miniGameActive) {
                      game.overlays.remove('PazarYangini');
                    }
                  });
                  // --- BİTTİ ---

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: provider.isGameOver
                        ? GameOverOverlay(
                            key: const ValueKey('game_over'),
                            ending: provider.currentEnding!,
                            onRestart: () => provider.startGame(),
                          )
                        : CardView(
                            key: ValueKey(provider.currentCard.id),
                            card: provider.currentCard,
                            onChoiceSelected: (choice) {
                              provider.makeChoice(choice);
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
