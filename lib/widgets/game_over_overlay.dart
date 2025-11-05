import 'package:flutter/material.dart';
import 'package:hyper_casual/models/game_ending.dart';

class GameOverOverlay extends StatelessWidget {
  final GameEnding ending;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.ending,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(color: Colors.red.shade900),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ending.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.red.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            ending.text,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade300,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            onPressed: onRestart,
            child: const Text("Yeniden Başla"),
          ),
        ],
      ),
    );
  }
}
