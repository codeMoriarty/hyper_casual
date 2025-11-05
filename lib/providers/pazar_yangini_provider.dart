import 'package:flutter/material.dart';
import 'package:hyper_casual/models/game_stats.dart';
import 'package:hyper_casual/models/mini_games/bolge_model.dart';
import 'package:hyper_casual/models/mini_games/zorluk_model.dart';
import 'package:hyper_casual/models/mini_games/guc_secimi_model.dart';
import 'dart.math';

// Mini oyunun sonucunu tanımlayan bir enum
enum MiniGameSonucTipi { tamBasari, kismiBasari, basarisizlik, felaket }

class MiniGameSonuc {
  final MiniGameSonucTipi tip;
  final String baslik;
  final String aciklama;
  final GameStats finalStats;

  MiniGameSonuc({
    required this.tip,
    required this.baslik,
    required this.aciklama,
    required this.finalStats,
  });
}

class PazarYanginiProvider extends ChangeNotifier {
  // --- DURUM (STATE) ---
  late GameStats _anaStats;
  late MiniGameZorluk _zorluk;
  int _mevcutTur = 1;
  Map<String, MiniGameBolge> _bolgeler = {};
  double _miniGameGolgeGucu = 0;
  final Random _random = Random();

  Map<String, GucTipi> _secimler = {};
  final Map<GucTipi, int> _kullanimSayaclari = {
    GucTipi.golge: 0,
    GucTipi.ordu: 0,
    GucTipi.halk: 0,
    GucTipi.buyucu: 0,
  };

  MiniGameSonuc? _sonuc; // Mini oyun bittiğinde bu dolar
  bool get isMiniGameOver => _sonuc != null;
  MiniGameSonuc? get sonuc => _sonuc;

  // --- GETTER'LAR (Arayüz için) ---
  int get mevcutTur => _mevcutTur;
  MiniGameZorluk get zorluk => _zorluk;
  List<MiniGameBolge> get bolgeler => _bolgeler.values.toList();
  double get miniGameGolgeGucu => _miniGameGolgeGucu;
  int get turSayisi => _zorluk.turSayisi;
  double get toplamYangin =>
      _bolgeler.values.fold(0.0, (prev, e) => prev + e.yanginSeviyesi);
  Map<String, GucTipi> get secimler => _secimler;

  // --- GDD SABİTLERİ  ---
  // Maliyetler
  final int GOLGE_MALIYETI = 50; // [cite: 394]
  final int ORDU_MALIYETI = 200; // [cite: 453]
  final int BUYUCU_MALIYETI = 400; // [cite: 579]
  final int HALK_GEREKLI_STAT = 30; // [cite: 42]

  // Başarı Şansları
  final int GOLGE_BASARI_SANSI = 100; // [cite: 394]
  final int ORDU_BASARI_SANSI = 90; // [cite: 453]
  final int HALK_BASARI_SANSI = 70; // [cite: 522]
  final int BUYUCU_BASARI_SANSI = 95; // [cite: 579]

  // Diğer
  final double BASARISIZLIK_CARPANI = 0.4; // [cite: 482, 540]
  final double KOMSU_YAYILMA_MIKTARI = 10.0; // [cite: 315]
  final double PAZAR_YAYILMA_MIKTARI = 10.0; // [cite: 224]
  final double YAYILMA_ESIGI = 50.0; // [cite: 314]

  // --- VERİTABANLARI (GDD'den) ---
  static final Map<String, MiniGameZorluk> _zorlukListesi = {
    'Kolay': MiniGameZorluk(
        ad: 'Kolay',
        baslangicYangin: 400,
        turSayisi: 4,
        temelArtis: 12.0,
        tamBasariHedef: 60,
        kismiBasariHedef: 140), // [cite: 191]
    'Normal': MiniGameZorluk(
        ad: 'Normal',
        baslangicYangin: 500,
        turSayisi: 3,
        temelArtis: 18.0,
        tamBasariHedef: 90,
        kismiBasariHedef: 180), // 
    'Zor': MiniGameZorluk(
        ad: 'Zor',
        baslangicYangin: 600,
        turSayisi: 3,
        temelArtis: 24.0,
        tamBasariHedef: 120,
        kismiBasariHedef: 220), // [cite: 193]
    'CokZor': MiniGameZorluk(
        ad: 'Çok Zor',
        baslangicYangin: 700,
        turSayisi: 3,
        temelArtis: 30.0,
        tamBasariHedef: 150,
        kismiBasariHedef: 260), // [cite: 195]
  };

  Map<String, MiniGameBolge> _getBaslangicBolgeler() => {
        '1': MiniGameBolge(
            id: '1',
            ad: 'Pazar Merkezi',
            yanginSeviyesi: 120,
            komsular: ['2', '3'],
            bolgeCarpan: 1.0,
            ozelKural: 'Sönmezse tüm bölgelere +10 yayılır!', // [cite: 224]
            kritiklik: 3), // [cite: 216]
        '2': MiniGameBolge(
            id: '2',
            ad: 'Ahşap Dükkanlar',
            yanginSeviyesi: 100,
            komsular: ['1', '4'],
            bolgeCarpan: 1.3, // [cite: 354]
            ozelKural: 'Yangın artış hızı +30% daha fazla!', // [cite: 243]
            kritiklik: 2), // [cite: 235]
        '3': MiniGameBolge(
            id: '3',
            ad: 'Kumaş Hanı',
            yanginSeviyesi: 80,
            komsular: ['1', '5'],
            bolgeCarpan: 1.0,
            ozelKural: 'Normal yayılma',
            kritiklik: 1), // [cite: 255]
        '4': MiniGameBolge(
            id: '4',
            ad: 'Demirci Sokağı',
            yanginSeviyesi: 60,
            komsular: ['2', '5'],
            bolgeCarpan: 0.5, // [cite: 356]
            ozelKural: '+50% direnç! Yavaş yanar.', // [cite: 276]
            kritiklik: 0), // [cite: 271]
        '5': MiniGameBolge(
            id: '5',
            ad: 'Eski Tapınak',
            yanginSeviyesi: 140,
            komsular: ['3', '4'],
            bolgeCarpan: 1.0,
            ozelKural: 'Yanarsa: Halk -20, Din -15, Gölge +10', // [cite: 296, 297, 298]
            kritiklik: 4), // [cite: 289]
      };

  // --- ANA FONKSİYONLAR ---
  void startMiniGame(GameStats anaStats) {
    _anaStats = anaStats;
    _mevcutTur = 1;
    _secimler = {};
    _sonuc = null;
    _kullanimSayaclari.updateAll((key, value) => 0);

    double oyuncuGucu = (anaStats.halk +
            anaStats.bekciler +
            (anaStats.hazine / 100) +
            anaStats.golge + // Büyücü [cite: 181]
            anaStats.teknoloji) /
        5; // [cite: 176]

    if (oyuncuGucu <= 30) {
      _zorluk = _zorlukListesi['Kolay']!;
    } else if (oyuncuGucu <= 50) {
      _zorluk = _zorlukListesi['Normal']!;
    } else if (oyuncuGucu <= 70) {
      _zorluk = _zorlukListesi['Zor']!;
    } else {
      _zorluk = _zorlukListesi['CokZor']!;
    }

    _bolgeler = _getBaslangicBolgeler();
    double baslangicYanginFarki =
        (_zorluk.baslangicYangin - 500.0) / 5.0; 
    _bolgeler.forEach((key, bolge) {
      bolge.yanginSeviyesi = (bolge.yanginSeviyesi + baslangicYanginFarki)
          .clamp(0, double.infinity);
    });

    _miniGameGolgeGucu = (anaStats.golgeDeposu * 10).toDouble(); // [cite: 134]
    if (anaStats.golgeDeposu >= 100) {
      _miniGameGolgeGucu = double.infinity; // [cite: 139]
    }

    notifyListeners();
  }

  void gucAta(String bolgeId, GucTipi guc) {
    _secimler[bolgeId] = guc;
    notifyListeners();
  }

  // "Turu Bitir" butonuna basıldığında
  Future<void> turuBitir() async {
    if (isMiniGameOver) return;

    GameStats turBasiStatlari = _anaStats.copyWith();
    Map<String, double> sondurmeEtkileri = {};
    Map<String, double> artisEtkileri = {};
    Map<String, double> yayilmaEtkileri = {};
    List<String> hikayeLoglari = [];

    double teknolojiBonusu =
        turBasiStatlari.teknoloji * 0.20; // [cite: 627]
    double ruzgarFaktoru =
        _random.nextDouble() * (1.15 - 0.85) + 0.85; // [cite: 344]

    // --- 1. SÖNDÜRME ve YAN ETKİ HESAPLAMA ---
    _bolgeler.forEach((bolgeId, bolge) {
      final guc = _secimler[bolgeId] ?? GucTipi.atla;
      if (guc == GucTipi.atla) return;

      _kullanimSayaclari[guc] = _kullanimSayaclari[guc]! + 1;
      int kullanim = _kullanimSayaclari[guc]!;
      double sondurmeMiktari = 0;
      bool basarili = true;

      switch (guc) {
        case GucTipi.golge:
          // Söndürme [cite: 408]
          sondurmeMiktari = min(200, bolge.yanginSeviyesi * 1.0);
          _miniGameGolgeGucu -= GOLGE_MALIYETI;
          // Yan Etki [cite: 415-421]
          turBasiStatlari = turBasiStatlari.copyWith(
            golgeDeposu: turBasiStatlari.golgeDeposu + 5,
            halk: (kullanim <= 2) ? turBasiStatlari.halk + 5 : turBasiStatlari.halk,
            bekciler: (kullanim <= 2) ? turBasiStatlari.bekciler + 5 : turBasiStatlari.bekciler,
            diplomasi: (kullanim <= 2) ? turBasiStatlari.diplomasi - 10 : turBasiStatlari.diplomasi,
          );
          break;
        case GucTipi.ordu:
          // Söndürme [cite: 474]
          double temelEtki = (turBasiStatlari.bekciler * 0.7) +
              (_random.nextInt(15) + 15) +
              teknolojiBonusu;
          basarili = (_random.nextInt(100) < ORDU_BASARI_SANSI);
          sondurmeMiktari = basarili ? temelEtki : temelEtki * BASARISIZLIK_CARPANI; [cite: 482]
          // Yan Etki [cite: 484-490]
          turBasiStatlari = turBasiStatlari.copyWith(
            hazine: turBasiStatlari.hazine - ORDU_MALIYETI,
            bekciler: (kullanim == 2 || kullanim == 3) ? turBasiStatlari.bekciler - 5 : turBasiStatlari.bekciler,
          );
          break;
        case GucTipi.halk:
          // Söndürme [cite: 531]
          double temelEtki = (turBasiStatlari.halk * 0.5) +
              (_random.nextInt(10) + 5) +
              teknolojiBonusu;
          basarili = (_random.nextInt(100) < HALK_BASARI_SANSI);
          sondurmeMiktari = basarili ? temelEtki : temelEtki * BASARISIZLIK_CARPANI; [cite: 540]
          // Yan Etki [cite: 542-554]
          if (kullanim % 2 == 0) {
            turBasiStatlari = turBasiStatlari.copyWith(
              halk: turBasiStatlari.halk + 5,
              bekciler: turBasiStatlari.bekciler + 5,
            );
          }
          break;
        case GucTipi.buyucu:
          // Söndürme [cite: 583]
          double temelEtki = (turBasiStatlari.golge * 1.3) + // Büyücü puanı
              (_random.nextInt(20) + 35) +
              teknolojiBonusu;
          basarili = (_random.nextInt(100) < BUYUCU_BASARI_SANSI);
          sondurmeMiktari = basarili ? temelEtki : temelEtki * 0.5; // GDD'de %50 diyor [cite: 591]
          // Yan Etki [cite: 593-597]
          turBasiStatlari = turBasiStatlari.copyWith(
            hazine: turBasiStatlari.hazine - BUYUCU_MALIYETI,
            din: turBasiStatlari.din + 10,
            diplomasi: (kullanim <= 2) ? turBasiStatlari.diplomasi - 5 : turBasiStatlari.diplomasi,
            bekciler: (kullanim <= 2) ? turBasiStatlari.bekciler - 5 : turBasiStatlari.bekciler,
          );
          break;
        default:
          break;
      }
      sondurmeEtkileri[bolgeId] = sondurmeMiktari;
    });

    // --- 2. YANGIN ARTIŞI HESAPLAMA ---
    _bolgeler.forEach((bolgeId, bolge) {
      final guc = _secimler[bolgeId] ?? GucTipi.atla;
      if (guc != GucTipi.atla) {
        bolge.mudaleEdilmedi = false; // Müdahale edildi
        return;
      }

      // Tehlike Çarpanı [cite: 359-361]
      double tehlikeCarpani = 1.0;
      if (bolge.mudaleEdilmedi) { 
        // 2 tur üst üste müdahale edilmediyse
        tehlikeCarpani = 1.5;
      }

      // Yangın Artış Formülü [cite: 332]
      double yanginArtisi = _zorluk.temelArtis *
          ruzgarFaktoru *
          bolge.bolgeCarpan *
          tehlikeCarpani;
      
      artisEtkileri[bolgeId] = yanginArtisi;
      bolge.mudaleEdilmedi = true; // Bir sonraki tur için işaretle
    });

    // --- 3. YANGINLARI GÜNCELLEME (Söndürme ve Artış) ---
    _bolgeler.forEach((bolgeId, bolge) {
      double sondurme = sondurmeEtkileri[bolgeId] ?? 0;
      double artis = artisEtkileri[bolgeId] ?? 0;
      bolge.yanginSeviyesi = (bolge.yanginSeviyesi - sondurme + artis);
    });

    // --- 4. KOMŞU YAYILMASI HESAPLAMA [cite: 313] ---
    final pazar = _bolgeler['1']!;
    bool pazarYayiyor = pazar.yanginSeviyesi > YAYILMA_ESIGI &&
        (_secimler['1'] ?? GucTipi.atla) == GucTipi.atla; // [cite: 223]

    _bolgeler.forEach((bolgeId, bolge) {
      if (bolge.yanginSeviyesi > YAYILMA_ESIGI &&
          (_secimler[bolgeId] ?? GucTipi.atla) == GucTipi.atla) {
        for (var komsiId in bolge.komsular) {
          yayilmaEtkileri[komsiId] = (yayilmaEtkileri[komsiId] ?? 0) + KOMSU_YAYILMA_MIKTARI;
        }
      }
      if (pazarYayiyor && bolgeId != '1') {
        yayilmaEtkileri[bolgeId] = (yayilmaEtkileri[bolgeId] ?? 0) + PAZAR_YAYILMA_MIKTARI; // [cite: 224]
      }
    });

    // --- 5. YAYILMAYI UYGULAMA ve Clamp ---
    _bolgeler.forEach((bolgeId, bolge) {
      double yayilma = yayilmaEtkileri[bolgeId] ?? 0;
      bolge.yanginSeviyesi = (bolge.yanginSeviyesi + yayilma).clamp(0, double.infinity);
    });

    // --- 6. TURU BİTİRME ---
    _anaStats = turBasiStatlari; // Statları GÜNCELLE
    _mevcutTur++;
    _secimler = {};

    // --- 7. OYUN BİTTİ Mİ KONTROLÜ ---
    if (_mevcutTur > _zorluk.turSayisi) {
      _miniOyunuBitir();
    }

    notifyListeners();
  }

  void _miniOyunuBitir() {
    double sonToplamYangin = toplamYangin;
    GameStats finalStats = _anaStats.copyWith();
    String baslik, aciklama;
    MiniGameSonucTipi tip;

    // Özel Felaket Kontrolü [cite: 869]
    if (_bolgeler['5']!.yanginSeviyesi >= 250) {
      tip = MiniGameSonucTipi.felaket;
      baslik = 'FELAKET!';
      aciklama = 'Eski Tapınak çöktü! Gölgeler serbest kaldı.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk - 20, // [cite: 875]
        din: finalStats.din - 15, // [cite: 876]
        golgeDeposu: finalStats.golgeDeposu + 10, // [cite: 877]
      );
    }
    // Başarısızlık Kontrolü [cite: 814]
    else if (sonToplamYangin > _zorluk.kismiBasariHedef) {
      tip = MiniGameSonucTipi.basarisizlik;
      baslik = 'BAŞARISIZLIK';
      aciklama = 'Pazar tamamen yok oldu. Halk öfkeli.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk - 30, // [cite: 860]
        hazine: finalStats.hazine - 1500, // [cite: 861]
        bekciler: finalStats.bekciler - 15, // [cite: 862]
        diplomasi: finalStats.diplomasi - 20, // [cite: 863]
      );
    }
    // Kısmi Başarı Kontrolü [cite: 814]
    else if (sonToplamYangin > _zorluk.tamBasariHedef) {
      tip = MiniGameSonucTipi.kismiBasari;
      baslik = 'KISMİ BAŞARI';
      aciklama = 'Pazar zarar gördü ama kurtarıldı.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk + 10, // [cite: 843]
        hazine: finalStats.hazine - 300, // [cite: 844]
        diplomasi: finalStats.diplomasi + 5, // [cite: 845]
      );
    }
    // Tam Başarı [cite: 814]
    else {
      tip = MiniGameSonucTipi.tamBasari;
      baslik = 'TAM BAŞARI!';
      aciklama = 'Pazar tamamen kurtarıldı! Halk sizi kahraman ilan etti.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk + 25, // [cite: 826]
        hazine: finalStats.hazine + 500, // [cite: 827]
        diplomasi: finalStats.diplomasi + 15, // [cite: 828]
        bekciler: finalStats.bekciler + 10, // [cite: 829]
        golge: finalStats.golge + 10, // Büyücü [cite: 829]
      );
    }
    
    // GDD Din 60+ Eşiği [cite: 599-604]
    if (finalStats.din >= 60) {
      int halkCezasi = ((finalStats.din - 60) / 5).floor() * -5;
      finalStats = finalStats.copyWith(halk: finalStats.halk + halkCezasi);
    }

    // GDD Gölge Deposu 70+ Eşiği [cite: 423-424] (Tur başına idi, bunu ana oyunda uygulamak gerekebilir)
    // Şimdilik sadece sonucu sakla
    _sonuc = MiniGameSonuc(
      tip: tip,
      baslik: baslik,
      aciklama: aciklama,
      finalStats: finalStats,
    );
  }
}