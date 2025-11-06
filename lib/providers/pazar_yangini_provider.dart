import 'package:flutter/material.dart';
import 'package:hyper_casual/models/game_stats.dart';
import 'package:hyper_casual/models/mini_games/bolge_model.dart';
import 'package:hyper_casual/models/mini_games/zorluk_model.dart';
import 'package:hyper_casual/models/mini_games/guc_secimi_model.dart';
import 'dart:math';

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

  // YENİ: Ordu kullanım limitini takip etmek için
  int _orduKullanilanBuTur = 0;

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

  // YENİ: Ordu limiti için getter'lar
  int get orduKullanilanBuTur => _orduKullanilanBuTur;
  int get maxOrduKullanimi =>
      (_anaStats.bekciler / 10).floor(); // Ordu Puanı / 10

  // --- GDD SABİTLERİ (GÜNCELLENDİ) ---
  // Maliyetler
  final int golgeMaliyeti = 50;
  final int orduMaliyeti = 100; // GÜNCELLENDİ: 200 -> 100
  final int buyucuMaliyeti = 300; // GÜNCELLENDİ: 400 -> 300
  final int halkGerekliStat = 30;

  // Başarı Şansları
  final int golgeBasariSansi = 100;
  final int orduBasariSansi = 90;
  final int halkBasariSansi = 50; // GÜNCELLENDİ: 70 -> 50
  final int buyucuBasariSansi = 95;

  // Diğer
  final double basarisizlikCarpani = 0.4;
  final double komsuYayilmaMiktari = 10.0;
  final double pazarYayilmaMiktari = 10.0;
  final double yayilmaEsigi = 50.0;

  // --- VERİTABANLARI (GDD'den) ---
  static final Map<String, MiniGameZorluk> _zorlukListesi = {
    'Kolay': MiniGameZorluk(
        ad: 'Kolay',
        baslangicYangin: 400,
        turSayisi: 4,
        temelArtis: 12.0,
        tamBasariHedef: 60,
        kismiBasariHedef: 140),
    'Normal': MiniGameZorluk(
        ad: 'Normal',
        baslangicYangin: 500,
        turSayisi: 3,
        temelArtis: 18.0,
        tamBasariHedef: 90,
        kismiBasariHedef: 180),
    'Zor': MiniGameZorluk(
        ad: 'Zor',
        baslangicYangin: 600,
        turSayisi: 3,
        temelArtis: 24.0,
        tamBasariHedef: 120,
        kismiBasariHedef: 220),
    'CokZor': MiniGameZorluk(
        ad: 'Çok Zor',
        baslangicYangin: 700,
        turSayisi: 3,
        temelArtis: 30.0,
        tamBasariHedef: 150,
        kismiBasariHedef: 260),
  };

  Map<String, MiniGameBolge> _getBaslangicBolgeler() => {
        '1': MiniGameBolge(
            id: '1',
            ad: 'Pazar Merkezi',
            yanginSeviyesi: 120,
            komsular: ['2', '3'],
            bolgeCarpan: 1.0,
            ozelKural: 'Sönmezse tüm bölgelere +10 yayılır!',
            kritiklik: 3),
        '2': MiniGameBolge(
            id: '2',
            ad: 'Ahşap Dükkanlar',
            yanginSeviyesi: 100,
            komsular: ['1', '4'],
            bolgeCarpan: 1.3,
            ozelKural: 'Yangın artış hızı +30% daha fazla!',
            kritiklik: 2),
        '3': MiniGameBolge(
            id: '3',
            ad: 'Kumaş Hanı',
            yanginSeviyesi: 80,
            komsular: ['1', '5'],
            bolgeCarpan: 1.0,
            ozelKural: 'Normal yayılma',
            kritiklik: 1),
        '4': MiniGameBolge(
            id: '4',
            ad: 'Demirci Sokağı',
            yanginSeviyesi: 60,
            komsular: ['2', '5'],
            bolgeCarpan: 0.5,
            ozelKural: '+50% direnç! Yavaş yanar.',
            kritiklik: 0),
        '5': MiniGameBolge(
            id: '5',
            ad: 'Eski Tapınak',
            yanginSeviyesi: 140,
            komsular: ['3', '4'],
            bolgeCarpan: 1.0,
            ozelKural: 'Yanarsa: Halk -20, Din -15, Gölge +10',
            kritiklik: 4),
      };

  // --- ANA FONKSİYONLAR ---
  void startMiniGame(GameStats anaStats) {
    _anaStats = anaStats;
    _mevcutTur = 1;
    _secimler = {};
    _sonuc = null;
    _kullanimSayaclari.updateAll((key, value) => 0);
    _orduKullanilanBuTur = 0; // YENİ: Ordu sayacını sıfırla

    double oyuncuGucu = (anaStats.halk +
            anaStats.bekciler +
            (anaStats.hazine / 100) +
            anaStats.golge + // Büyücü
            anaStats.teknoloji) /
        5;

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
    double baslangicYanginFarki = (_zorluk.baslangicYangin - 500.0) / 5.0;
    _bolgeler.forEach((key, bolge) {
      bolge.yanginSeviyesi = (bolge.yanginSeviyesi + baslangicYanginFarki)
          .clamp(0, double.infinity);
    });

    _miniGameGolgeGucu = (anaStats.golgeDeposu * 10).toDouble();
    if (anaStats.golgeDeposu >= 100) {
      _miniGameGolgeGucu = double.infinity;
    }

    notifyListeners();
  }

  // YENİ: Ordu sayacını güncellemek için gucAta değiştirildi
  void gucAta(String bolgeId, GucTipi guc) {
    final eskiSecim = _secimler[bolgeId];

    // Eğer eski seçim Ordu ise ve yeni seçim farklıysa, sayacı azalt
    if (eskiSecim == GucTipi.ordu && guc != GucTipi.ordu) {
      _orduKullanilanBuTur--;
    }
    // Eğer yeni seçim Ordu ise ve eski seçim Ordu değilse, sayacı artır
    else if (guc == GucTipi.ordu && eskiSecim != GucTipi.ordu) {
      _orduKullanilanBuTur++;
    }

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

    double teknolojiBonusu = turBasiStatlari.teknoloji * 0.20;
    double ruzgarFaktoru = _random.nextDouble() * (1.15 - 0.85) + 0.85;

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
          sondurmeMiktari = min(200, bolge.yanginSeviyesi * 1.0);
          _miniGameGolgeGucu -= golgeMaliyeti;
          turBasiStatlari = turBasiStatlari.copyWith(
            golgeDeposu: turBasiStatlari.golgeDeposu + 5,
            halk: (kullanim <= 2)
                ? turBasiStatlari.halk + 5
                : turBasiStatlari.halk,
            bekciler: (kullanim <= 2)
                ? turBasiStatlari.bekciler + 5
                : turBasiStatlari.bekciler,
            diplomasi: (kullanim <= 2)
                ? turBasiStatlari.diplomasi - 10
                : turBasiStatlari.diplomasi,
          );
          break;
        case GucTipi.ordu:
          double temelEtki = (turBasiStatlari.bekciler * 0.7) +
              (_random.nextInt(15) + 15) +
              teknolojiBonusu;
          basarili = (_random.nextInt(100) < orduBasariSansi);
          sondurmeMiktari =
              basarili ? temelEtki : temelEtki * basarisizlikCarpani;
          turBasiStatlari = turBasiStatlari.copyWith(
            hazine: turBasiStatlari.hazine - orduMaliyeti, // GÜNCELLENDİ
            bekciler: (kullanim == 2 || kullanim == 3)
                ? turBasiStatlari.bekciler - 5
                : turBasiStatlari.bekciler,
          );
          break;
        case GucTipi.halk:
          double temelEtki = (turBasiStatlari.halk * 0.5) +
              (_random.nextInt(10) + 5) +
              teknolojiBonusu;
          basarili = (_random.nextInt(100) < halkBasariSansi); // GÜNCELLENDİ
          sondurmeMiktari =
              basarili ? temelEtki : temelEtki * basarisizlikCarpani;
          if (kullanim % 2 == 0) {
            turBasiStatlari = turBasiStatlari.copyWith(
              halk: turBasiStatlari.halk + 5,
              bekciler: turBasiStatlari.bekciler + 5,
            );
          }
          break;
        case GucTipi.buyucu:
          double temelEtki = (turBasiStatlari.golge * 1.3) + // Büyücü puanı
              (_random.nextInt(20) + 35) +
              teknolojiBonusu;
          basarili = (_random.nextInt(100) < buyucuBasariSansi);
          sondurmeMiktari = basarili ? temelEtki : temelEtki * 0.5;
          turBasiStatlari = turBasiStatlari.copyWith(
            hazine: turBasiStatlari.hazine - buyucuMaliyeti, // GÜNCELLENDİ
            din: turBasiStatlari.din + 10,
            diplomasi: (kullanim <= 2)
                ? turBasiStatlari.diplomasi - 5
                : turBasiStatlari.diplomasi,
            bekciler: (kullanim <= 2)
                ? turBasiStatlari.bekciler - 5
                : turBasiStatlari.bekciler,
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
      double tehlikeCarpani = 1.0;
      if (bolge.mudaleEdilmedi) {
        tehlikeCarpani = 1.5;
      }
      double yanginArtisi = _zorluk.temelArtis *
          ruzgarFaktoru *
          bolge.bolgeCarpan *
          tehlikeCarpani;

      artisEtkileri[bolgeId] = yanginArtisi;
      bolge.mudaleEdilmedi = true;
    });

    // --- 3. YANGINLARI GÜNCELLEME (Söndürme ve Artış) ---
    _bolgeler.forEach((bolgeId, bolge) {
      double sondurme = sondurmeEtkileri[bolgeId] ?? 0;
      double artis = artisEtkileri[bolgeId] ?? 0;
      bolge.yanginSeviyesi = (bolge.yanginSeviyesi - sondurme + artis);
    });

    // --- 4. KOMŞU YAYILMASI HESAPLAMA ---
    final pazar = _bolgeler['1']!;
    bool pazarYayiyor = pazar.yanginSeviyesi > yayilmaEsigi &&
        (_secimler['1'] ?? GucTipi.atla) == GucTipi.atla;

    _bolgeler.forEach((bolgeId, bolge) {
      if (bolge.yanginSeviyesi > yayilmaEsigi &&
          (_secimler[bolgeId] ?? GucTipi.atla) == GucTipi.atla) {
        for (var komsiId in bolge.komsular) {
          yayilmaEtkileri[komsiId] =
              (yayilmaEtkileri[komsiId] ?? 0) + komsuYayilmaMiktari;
        }
      }
      if (pazarYayiyor && bolgeId != '1') {
        yayilmaEtkileri[bolgeId] =
            (yayilmaEtkileri[bolgeId] ?? 0) + pazarYayilmaMiktari;
      }
    });

    // --- 5. YAYILMAYI UYGULAMA ve Clamp ---
    _bolgeler.forEach((bolgeId, bolge) {
      double yayilma = yayilmaEtkileri[bolgeId] ?? 0;
      bolge.yanginSeviyesi =
          (bolge.yanginSeviyesi + yayilma).clamp(0, double.infinity);
    });

    // --- 6. TURU BİTİRME ---
    _anaStats = turBasiStatlari; // Statları GÜNCELLE
    _mevcutTur++;
    _secimler = {};
    _orduKullanilanBuTur = 0; // YENİ: Ordu sayacını sıfırla

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

    // Özel Felaket Kontrolü
    if (_bolgeler['5']!.yanginSeviyesi >= 250) {
      tip = MiniGameSonucTipi.felaket;
      baslik = 'FELAKET!';
      aciklama = 'Eski Tapınak çöktü! Gölgeler serbest kaldı.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk - 20,
        din: finalStats.din - 15,
        golgeDeposu: finalStats.golgeDeposu + 10,
      );
    }
    // Başarısızlık Kontrolü
    else if (sonToplamYangin > _zorluk.kismiBasariHedef) {
      tip = MiniGameSonucTipi.basarisizlik;
      baslik = 'BAŞARISIZLIK';
      aciklama = 'Pazar tamamen yok oldu. Halk öfkeli.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk - 30,
        hazine: finalStats.hazine - 1500,
        bekciler: finalStats.bekciler - 15,
        diplomasi: finalStats.diplomasi - 20,
      );
    }
    // Kısmi Başarı Kontrolü
    else if (sonToplamYangin > _zorluk.tamBasariHedef) {
      tip = MiniGameSonucTipi.kismiBasari;
      baslik = 'KISMİ BAŞARI';
      aciklama = 'Pazar zarar gördü ama kurtarıldı.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk + 10,
        hazine: finalStats.hazine - 300,
        diplomasi: finalStats.diplomasi + 5,
      );
    }
    // Tam Başarı
    else {
      tip = MiniGameSonucTipi.tamBasari;
      baslik = 'TAM BAŞARI!';
      aciklama = 'Pazar tamamen kurtarıldı! Halk sizi kahraman ilan etti.';
      finalStats = finalStats.copyWith(
        halk: finalStats.halk + 25,
        hazine: finalStats.hazine + 500,
        diplomasi: finalStats.diplomasi + 15,
        bekciler: finalStats.bekciler + 10,
        golge: finalStats.golge + 10, // Büyücü
      );
    }

    // GDD Din 60+ Eşiği
    if (finalStats.din >= 60) {
      int halkCezasi = ((finalStats.din - 60) / 5).floor() * -5;
      finalStats = finalStats.copyWith(halk: finalStats.halk + halkCezasi);
    }

    _sonuc = MiniGameSonuc(
      tip: tip,
      baslik: baslik,
      aciklama: aciklama,
      finalStats: finalStats,
    );
  }
}
