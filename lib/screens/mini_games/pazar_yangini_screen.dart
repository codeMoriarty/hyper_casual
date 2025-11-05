import 'package:flutter/material.dart';
import 'package:hyper_casual/providers/game_provider.dart';
import 'package:hyper_casual/providers/pazar_yangini_provider.dart';
import 'package:hyper_casual/widgets/mini_games/bolge_kart_widget.dart';
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

  // OYUN EKRANI (Eski build metodu buraya taşındı)
  Widget _buildOyunEkrani(BuildContext context, PazarYanginiProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                style:
                    textTheme.bodyLarge?.copyWith(color: Colors.grey.shade400),
              ),
              const Divider(color: Colors.grey, height: 24),
              Expanded(
                child: ListView(
                  children: provider.bolgeler
                      .map((bolge) => BolgeKartWidget(bolge: bolge))
                      .toList(),
                ),
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
      ),
    );
  }

  // SONUÇ EKRANI (YENİ)
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
                    // Ana GameProvider'ı bul ve mini oyunu bitir,
                    // güncellenmiş statları ona yolla.
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
