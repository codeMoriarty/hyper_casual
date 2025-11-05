class GameStats {
  // --- Eski Parametreler ---
  final int halk;
  final int
      golge; // Bu, Kart #3'teki eski GÖLGE idi, bunu şimdi 'Büyücü' olarak düşünebiliriz.
  final int hazine;
  final int bekciler;

  // --- GDD'den Gelen Yeni Ana Parametreler ---
  final int golgeDeposu;
  final int teknoloji;
  final int diplomasi;
  final int din;
  // Not: GDD Büyücü (40) ve Din (25) ayrı diyor ama [cite: 121] birleşik de olabileceğini belirtiyor.
  // Şimdilik Büyücü'yü 'golge' (eski) parametresiyle, Din'i 'din' ile yönetelim.

  GameStats({
    // Eski Başlangıçlar
    this.halk = 50,
    this.hazine = 2000, // GDD'ye göre başlangıç 2000 [cite: 47]
    this.bekciler = 50, // GDD'de 'Ordu' [cite: 79]

    // GDD'den Yeni Başlangıçlar
    this.golgeDeposu = 10, // [cite: 68]
    this.teknoloji =
        50, // GDD 0 veya 50 diyor [cite: 96], 50 seçelim [cite: 164]
    this.diplomasi = 50, // [cite: 108]
    this.din = 25, // [cite: 123]
    this.golge =
        40, // Eski 'golge' parametresini 'Büyücü' gücü (40) [cite: 123] olarak kullanalım
  });

  // Kopyalama metodu (Tüm yeni parametreleri içerecek şekilde güncellendi)
  GameStats copyWith({
    int? halk,
    int? golge,
    int? hazine,
    int? bekciler,
    int? golgeDeposu,
    int? teknoloji,
    int? diplomasi,
    int? din,
  }) {
    return GameStats(
      halk: halk ?? this.halk,
      golge: golge ?? this.golge,
      hazine: hazine ?? this.hazine,
      bekciler: bekciler ?? this.bekciler,
      golgeDeposu: golgeDeposu ?? this.golgeDeposu,
      teknoloji: teknoloji ?? this.teknoloji,
      diplomasi: diplomasi ?? this.diplomasi,
      din: din ?? this.din,
    );
  }
}
