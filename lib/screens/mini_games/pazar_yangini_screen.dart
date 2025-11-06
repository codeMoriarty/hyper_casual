import 'package:flutter/material.dart';
import 'package:hyper_casual/models/mini_games/bolge_model.dart';
import 'package:hyper_casual/models/mini_games/guc_secimi_model.dart';
import 'package:hyper_casual/providers/game_provider.dart';
import 'package:hyper_casual/providers/pazar_yangini_provider.dart';
import 'package:hyper_casual/widgets/mini_games/guc_surukle_widget.dart';
import 'package:provider/provider.dart';

class PazarYanginiScreen extends StatelessWidget {
  const PazarYanginiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PazarYanginiProvider>(
      builder: (context, provider, child) {
        // Mini oyun bittiyse, sonuç ekranını göster
        if (provider.isMiniGameOver) {
          return _buildSonucEkrani(context, provider.sonuc!);
        }

        // Mini oyun devam ediyorsa, oyun ekranını göster
        return _buildOyunEkrani(context, provider);
      },
    );
  }

  // OYUN EKRANI (Güncellendi)
  Widget _buildOyunEkrani(BuildContext context, PazarYanginiProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Bilgi (Tur, Hedef)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    'PAZAR YANGINI - TUR ${provider.mevcutTur}/${provider.turSayisi}',
                    style: textTheme.headlineMedium
                        ?.copyWith(color: Colors.red.shade300),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TOPLAM YANGIN: ${provider.toplamYangin.toStringAsFixed(0)}',
                    style: textTheme.headlineSmall
                        ?.copyWith(color: Colors.orange.shade300),
                  ),
                  Text(
                    '(Hedef: < ${provider.zorluk.tamBasariHedef})',
                    style: textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            // 2. Harita Alanı
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey.shade700),
                  ),
                  image: const DecorationImage(
                      image:
                          AssetImage("assets/images/map.png"), // Harita resmi
                      fit: BoxFit.contain,
                      opacity: 0.3),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildBolgeHedef(context, provider, provider.bolgeler[0],
                        const Offset(0, -120)),
                    _buildBolgeHedef(context, provider, provider.bolgeler[1],
                        const Offset(-100, 0)),
                    _buildBolgeHedef(context, provider, provider.bolgeler[2],
                        const Offset(100, 0)),
                    _buildBolgeHedef(context, provider, provider.bolgeler[3],
                        const Offset(-100, 120)),
                    _buildBolgeHedef(context, provider, provider.bolgeler[4],
                        const Offset(100, 120)),
                  ],
                ),
              ),
            ),

            // 3. Güç Barı
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                children: [
                  DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return _buildGucBari(context, provider);
                    },
                    onAccept: (bolgeId) {
                      provider.gucKaldir(bolgeId);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      provider.turuBitir();
                    },
                    child: const Text('TURU BİTİR'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBolgeHedef(
    BuildContext context,
    PazarYanginiProvider provider,
    MiniGameBolge bolge,
    Offset pozisyon,
  ) {
    final atananGuc = provider.secimler[bolge.id];
    final bool secimYapildi = atananGuc != null && atananGuc != GucTipi.atla;

    Widget bolgeIcerigi(Color borderColor) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              bolge.ad,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              bolge.yanginSeviyesi.toStringAsFixed(0),
              style: TextStyle(
                  color: Colors.orange.shade300,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "☆" * bolge.kritiklik,
              style: TextStyle(color: Colors.yellow.shade300, fontSize: 12),
            ),
            if (secimYapildi)
              Icon(_getIconForGuc(atananGuc),
                  color: Colors.green.shade300, size: 16),
          ],
        ),
      );
    }

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 40 + pozisyon.dx,
      top: MediaQuery.of(context).size.height / 4.5 - 40 + pozisyon.dy,
      child: Draggable<String>(
        data: secimYapildi ? bolge.id : null,
        feedback: secimYapildi
            ? Icon(_getIconForGuc(atananGuc), color: Colors.white, size: 50)
            : Container(),
        childWhenDragging: bolgeIcerigi(Colors.grey.shade700),
        child: DragTarget<GucTipi>(
          builder: (context, candidateData, rejectedData) {
            Color borderColor =
                secimYapildi ? Colors.green.shade300 : Colors.red.shade400;
            if (candidateData.isNotEmpty) {
              borderColor = Colors.blue.shade300;
            }
            return bolgeIcerigi(borderColor);
          },
          onAccept: (gucTipi) {
            provider.gucAta(bolge.id, gucTipi);
          },
        ),
      ),
    );
  }

  // GÜÇ BARI (GÜNCELLENDİ)
  Widget _buildGucBari(BuildContext context, PazarYanginiProvider provider) {
    final anaStats = context.read<GameProvider>().stats;

    // Ordu ve Halk limitlerini kontrol et
    final bool orduLimitiDolu =
        provider.orduKullanilanBuTur >= provider.maxOrduKullanimi;
    final bool halkLimitiDolu = // YENİ
        provider.halkKullanilanBuTur >= provider.maxHalkKullanimi;

    // Tek kullanımlık güçleri kontrol et
    final Set<GucTipi> kullanilanGucler = provider.secimler.values.toSet();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GucSurukleWidget(
          gucTipi: GucTipi.ordu,
          icon: Icons.shield,
          renk: Colors.red.shade300,
          aktif: anaStats.hazine >= provider.orduMaliyeti && !orduLimitiDolu,
        ),
        GucSurukleWidget(
          gucTipi: GucTipi.halk,
          icon: Icons.people,
          renk: Colors.blue.shade300,
          // GÜNCELLENDİ: Artık tek kullanımlık değil, limite bağlı
          aktif: anaStats.halk >= provider.halkGerekliStat && !halkLimitiDolu,
        ),
        GucSurukleWidget(
          gucTipi: GucTipi.buyucu,
          icon: Icons.auto_awesome,
          renk: Colors.cyan.shade300,
          aktif: anaStats.hazine >= provider.buyucuMaliyeti &&
              !kullanilanGucler.contains(GucTipi.buyucu),
        ),
        GucSurukleWidget(
          gucTipi: GucTipi.golge,
          icon: Icons.nightlight_round,
          renk: Colors.purple.shade300,
          aktif: provider.miniGameGolgeGucu >= provider.golgeMaliyeti &&
              !kullanilanGucler.contains(GucTipi.golge),
        ),
      ],
    );
  }

  IconData _getIconForGuc(GucTipi? guc) {
    switch (guc) {
      case GucTipi.ordu:
        return Icons.shield;
      case GucTipi.halk:
        return Icons.people;
      case GucTipi.buyucu:
        return Icons.auto_awesome;
      case GucTipi.golge:
        return Icons.nightlight_round;
      default:
        return Icons.question_mark;
    }
  }

  // SONUÇ EKRANI (Değişiklik yok)
  Widget _buildSonucEkrani(BuildContext context, MiniGameSonuc sonuc) {
    final textTheme = Theme.of(context).textTheme;
    Color renk = Colors.blue;
    if (sonuc.tip == MiniGameSonucTipi.basarisizlik ||
        sonuc.tip == MiniGameSonucTipi.felaket) {
      renk = Colors.red.shade400;
    } else if (sonuc.tip == MiniGameSonucTipi.tamBasari) {
      renk = Colors.green.shade400;
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  sonuc.baslik,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(color: renk),
                ),
                const SizedBox(height: 24),
                Text(
                  sonuc.aciklama,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: renk.withOpacity(0.8),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    context.read<GameProvider>().endMiniGame(sonuc.finalStats);
                  },
                  child: const Text('Devam Et'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
