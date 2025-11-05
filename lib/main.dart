import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_casual/game/atmosphere_game.dart';
import 'package:hyper_casual/providers/game_provider.dart';
// Yeni provider'ı import et
import 'package:hyper_casual/providers/pazar_yangini_provider.dart';
import 'package:hyper_casual/screens/game_screen.dart';
import 'package:hyper_casual/screens/mini_games/pazar_yangini_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Ana GameProvider
    ChangeNotifierProvider(
      create: (context) => GameProvider()..startGame(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kader Şehri',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.cinzelDecorativeTextTheme(
          // Google Fonts'u burada yüklüyoruz
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const Scaffold(
        body: GameWidget.controlled(
          gameFactory: AtmosphereGame.new,
          overlayBuilderMap: {
            'GameUI': _buildGameUI,
            // GÜNCELLEME: 'PazarYangini' overlay'i artık kendi Provider'ını oluşturacak
            'PazarYangini': _buildPazarYanginiUI,
          },
          initialActiveOverlays: ['GameUI'],
        ),
      ),
    );
  }

  static Widget _buildGameUI(BuildContext context, Game game) {
    return GameScreen(game: game);
  }

  // GÜNCELLENDİ: Mini oyun başladığında, PazarYanginiProvider'ı oluştur
  static Widget _buildPazarYanginiUI(BuildContext context, Game game) {
    // Ana GameProvider'ı bul
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => PazarYanginiProvider()
        ..startMiniGame(gameProvider.stats), // Başlangıç statlarını ver
      child: const PazarYanginiScreen(),
    );
  }
}
