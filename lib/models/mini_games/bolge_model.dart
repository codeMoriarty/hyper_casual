// 5 Pazar Bölgesinden her birinin anlık durumunu tutan model
class MiniGameBolge {
  final String id;
  final String ad;
  double yanginSeviyesi;
  final List<String> komsular;
  final double bolgeCarpan; // Ahşap için 1.3, Demirci için 0.5
  final String ozelKural;
  final int kritiklik; // 1-4 (yıldız sayısı)
  bool
      mudaleEdilmedi; // Tehlike çarpanı için (DÜZELTME 1: = false buradan kaldırıldı)

  MiniGameBolge({
    required this.id,
    required this.ad,
    required this.yanginSeviyesi,
    required this.komsular,
    required this.bolgeCarpan,
    required this.ozelKural,
    required this.kritiklik,
    this.mudaleEdilmedi = false, // DÜZELTME 2: Parametre buraya eklendi
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
      // Bu satır artık hata vermeyecek
      mudaleEdilmedi: mudaleEdilmedi ?? this.mudaleEdilmedi,
    );
  }
}
