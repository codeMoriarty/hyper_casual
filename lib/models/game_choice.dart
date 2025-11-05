import 'package:hyper_casual/models/choice_effect.dart';

class GameChoice {
  final String text;
  final ChoiceEffect effect;
  final String? nextCardId; // Dallanma için
  final String? endingId; // Oyunu bitirmek için

  const GameChoice({
    required this.text,
    this.effect = const ChoiceEffect(),
    this.nextCardId,
    this.endingId,
  });
}
