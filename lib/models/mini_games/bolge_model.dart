// 5 Pazar Bölgesinden  her birinin anlık durumunu tutan model
class MiniGameBolge {
  final String id;
  final String ad;
  double yanginSeviyesi;
  final List<String> komsular;
  final double
      bolgeCarpan; // Ahşap için 1.3 [cite: 354], Demirci için 0.5 [cite: 356]
  final String ozelKural;
  final int kritiklik; // 1-4 (yıldız sayısı) [cite: 216, 235, 255, 271, 289]
  bool mudaleEdilmedi = false; // Tehlike çarpanı için

  MiniGameBolge({
    required this.id,
    required this.ad,
    required this.yanginSeviyesi,
    required this.komsular,
    required this.bolgeCarpan,
    required this.ozelKural,
    required this.kritiklik,
  });

  // Durumu kopyalamak için
  MiniGameBolge copyWith({
    double? yanginSeviyesi,
    bool? mudaleEdilmedi,
  }) {
    return MiniGameBolge(
      id: id,
      ad: ad,
      yanginSeviyesi: yanginSeviyesi ?? this.yanginSeviyesi,
      komsular: komsular,
      bolgeCarpan: bolgeCarpan,
      ozelKural: ozelKural,
      kritiklik: kritiklik,
      mudaleEdilmedi: mudaleEdilmedi ?? this.mudaleEdilmedi,
    );
  }
}
