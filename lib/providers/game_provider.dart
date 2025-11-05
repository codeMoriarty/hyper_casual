import 'package:flutter/material.dart';
// Proje adını 'hyper_casual' olarak düzeltiyorum
import 'package:hyper_casual/data/card_database.dart';
import 'package:hyper_casual/models/game_card.dart';
import 'package:hyper_casual/models/game_choice.dart';
import 'package:hyper_casual/models/game_ending.dart';
import 'package:hyper_casual/models/game_stats.dart';

class GameProvider extends ChangeNotifier {
  GameStats _stats = GameStats();
  GameCard _currentCard = CardDatabase.cards['1']!;
  GameEnding? _currentEnding;

  // UI'ın erişmesi için getter'lar
  GameStats get stats => _stats;
  GameCard get currentCard => _currentCard;
  GameEnding? get currentEnding => _currentEnding;
  bool get isGameOver => _currentEnding != null;

  // Mini oyunu tetiklemek için bir bayrak (flag)
  // UI bunu dinleyecek ve PazarYangini overlay'ini gösterecek
  bool _isMiniGameActive = false;
  bool get isMiniGameActive => _isMiniGameActive;

  // Oyunu başlat / yeniden başlat
  void startGame() {
    _stats =
        GameStats(); // Statları sıfırla (artık tüm yeni değerleri içeriyor)
    _currentCard = CardDatabase.cards['1']!; // İlk karttan başla
    _currentEnding = null; // Oyun sonunu temizle
    _isMiniGameActive = false; // Mini oyunu kapat
    notifyListeners();
  }

  // Mini oyundan ana oyuna dönerken (PazarYanginiProvider'dan çağrılacak)
  void endMiniGame(GameStats updatedStats) {
    _stats = updatedStats; // Mini oyundan güncellenmiş statları al
    _isMiniGameActive = false;
    _goToNextCard(); // Mini oyundan sonraki karta geç
    notifyListeners();
  }

  // Bir seçim yapıldığında
  void makeChoice(GameChoice choice) {
    if (isGameOver || _isMiniGameActive) {
      return; // Oyun bittiyse veya mini oyundaysa işlem yapma
    }

    // *** YENİ: Mini Oyun Tetikleyicisi ***
    // Kart #3'ün özel seçeneğini kontrol et
    if (_currentCard.id == '3' && choice.text.contains("Hemen müdahale et!")) {
      _isMiniGameActive = true;
      notifyListeners();
      return; // Statları uygulama, sadece mini oyunu aç
    }

    // 1. Statları uygula (TÜM YENİ PARAMETRELER EKLENDİ)
    // Not: Kart efektleri henüz yeni parametreleri etkilemiyor (örn. golgeDeposu),
    // ama ChoiceEffect modelimiz güncellendiği için altyapı hazır.
    _stats = _stats.copyWith(
      halk: (_stats.halk + choice.effect.halk).clamp(0, 100),
      // 'golge' (Büyücü) ve 'din' parametreleri de artık güncellenebilir
      golge: (_stats.golge + choice.effect.golge).clamp(0, 100),
      din: (_stats.din + choice.effect.din).clamp(0, 100),
      hazine: (_stats.hazine +
          choice.effect.hazine), // Hazinenin üst limiti olmasın [cite: 45]
      bekciler: (_stats.bekciler + choice.effect.bekciler).clamp(0, 100),
      golgeDeposu: (_stats.golgeDeposu + choice.effect.golgeDeposu)
          .clamp(0, 100), // Gölge Deposu da artık etkilenebilir
      teknoloji: (_stats.teknoloji + choice.effect.teknoloji).clamp(0, 100),
      diplomasi: (_stats.diplomasi + choice.effect.diplomasi).clamp(0, 100),
    );

    // 2. Stat bazlı oyun sonu kontrolü
    if (_stats.halk <= 0 ||
        _stats.bekciler <=
            0 || // GDD'ye göre Ordu (Bekçiler) 5'in altı [cite: 90]
        _stats.diplomasi < 0) {
      // GDD'ye göre Diplomasi < 0 [cite: 117]
      _currentEnding = CardDatabase.endings['STAT_DEATH'];
      notifyListeners();
      return;
    }

    // 3. Seçim bazlı oyun sonu kontrolü
    if (choice.endingId != null) {
      _currentEnding = CardDatabase.endings[choice.endingId];
      notifyListeners();
      return;
    }

    // 4. Sonraki karta geç
    _goToNextCard(choice.nextCardId);
  }

  void _goToNextCard([String? nextCardId]) {
    String cardIdToLoad;
    if (nextCardId != null) {
      // Dallanma varsa
      cardIdToLoad = nextCardId;
    } else {
      // Normal akış (mevcut kart ID'sini 1 artır)
      int currentId = int.parse(_currentCard.id);
      cardIdToLoad = (currentId + 1).toString();
    }

    // Yeni kartı yükle
    if (CardDatabase.cards.containsKey(cardIdToLoad)) {
      _currentCard = CardDatabase.cards[cardIdToLoad]!;
    } else {
      // Eğer sonraki kart bulunamazsa (oyun bitti ama son yoksa)
      _currentEnding = CardDatabase.endings['SURGUN'];
    }

    notifyListeners();
  }
}
