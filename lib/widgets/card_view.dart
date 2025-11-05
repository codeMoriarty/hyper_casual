import 'package:flutter/material.dart';
import 'package:hyper_casual/models/game_card.dart';
import 'package:hyper_casual/models/game_choice.dart';

class CardView extends StatelessWidget {
  final GameCard card;
  final ValueChanged<GameChoice> onChoiceSelected;

  const CardView({
    super.key,
    required this.card,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            spreadRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık
          Text(
            card.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Metin
          Text(
            card.text,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade300,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(),

          // Seçenekler
          ...card.choices.map((choice) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                onPressed: () => onChoiceSelected(choice),
                child: Text(
                  choice.text,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
