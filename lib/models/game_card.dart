import 'package:hyper_casual/models/game_choice.dart';

class GameCard {
  final String id;
  final String title;
  final String text;
  final List<GameChoice> choices;

  const GameCard({
    required this.id,
    required this.title,
    required this.text,
    required this.choices,
  });
}
