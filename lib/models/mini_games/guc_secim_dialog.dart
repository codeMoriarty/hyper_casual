import 'package:flutter/material.dart';
import 'package:hyper_casual/models/game_stats.dart';
import 'package:hyper_casual/models/mini_games/bolge_model.dart';
import 'package:hyper_casual/models/mini_games/guc_secimi_model.dart';
import 'package:hyper_casual/providers/pazar_yangini_provider.dart';
import 'package:provider/provider.dart';

class GucSecimDialog extends StatelessWidget {
  final MiniGameBolge bolge;
  final GameStats anaStats;

  const GucSecimDialog({
    super.key,
    required this.bolge,
    required this.anaStats,
  });

  @override
  Widget build(BuildContext context) {
    // Mini oyun provider'ını bul, ama dinleme (sadece fonksiyon çağırmak için)
    final provider = context.read<PazarYanginiProvider>();

    // GDD'deki  gibi bir arayüz oluşturalım
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(bolge.ad),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Yangın: ${bolge.yanginSeviyesi.toStringAsFixed(0)}'),
            Text(
              'Önemi: ${"☆" * bolge.kritiklik}${" " * (4 - bolge.kritiklik)}'
                  .trim(),
              style: TextStyle(color: Colors.yellow.shade300),
            ),
            const Divider(height: 20),
            Text(
              'HANGİ GÜCÜ KULLANMAK İSTERSİN?',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.golge,
              icon: Icons.nightlight_round,
              renk: Colors.purple.shade300,
              basariSansi: '100%', // [cite: 394]
              maliyet: '${provider.GOLGE_MALIYETI} Gölge Gücü', // [cite: 394]
              etki: 'Tam Söndürme (Max 200)', // [cite: 408]
              yanEtki: 'Diplomasi -10 (İlk 2)', // [cite: 417]
              mevcutKaynak: provider.miniGameGolgeGucu,
              gerekliKaynak: provider.GOLGE_MALIYETI.toDouble(),
            ),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.ordu,
              icon: Icons.shield,
              renk: Colors.red.shade300,
              basariSansi: '${provider.ORDU_BASARI_SANSI}%', // [cite: 453]
              maliyet: '${provider.ORDU_MALIYETI} Hazine', // [cite: 453]
              etki: 'Orta-Yüksek Söndürme',
              yanEtki: 'Ordu -5 (2. ve 3.)', // [cite: 487, 488]
              mevcutKaynak: anaStats.hazine.toDouble(),
              gerekliKaynak: provider.ORDU_MALIYETI.toDouble(),
            ),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.halk,
              icon: Icons.people,
              renk: Colors.blue.shade300,
              basariSansi: '${provider.HALK_BASARI_SANSI}%', // [cite: 522]
              maliyet: 'ÜCRETSİZ', // [cite: 522]
              etki: 'Düşük Söndürme',
              yanEtki: 'Halk+5, Ordu+5 (Her 2)', // [cite: 523]
              mevcutKaynak: anaStats.halk.toDouble(),
              gerekliKaynak: provider.HALK_GEREKLI_STAT.toDouble(),
            ),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.buyucu,
              icon: Icons.auto_awesome,
              renk: Colors.cyan.shade300,
              basariSansi: '${provider.BUYUCU_BASARI_SANSI}%', // [cite: 579]
              maliyet: '${provider.BUYUCU_MALIYETI} Hazine', // [cite: 579]
              etki: 'Çok Yüksek Söndürme',
              yanEtki: 'Din+10, Diplomasi-5', // [cite: 595]
              mevcutKaynak: anaStats.hazine.toDouble(),
              gerekliKaynak: provider.BUYUCU_MALIYETI.toDouble(),
            ),
            const Divider(height: 10),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.atla,
              icon: Icons.skip_next,
              renk: Colors.grey.shade600,
              basariSansi: '0%',
              maliyet: 'ÜCRETSİZ',
              etki: 'Yangın Artacak!',
              yanEtki: 'Tehlike Çarpanı artabilir', // [cite: 360, 361]
              mevcutKaynak: 1,
              gerekliKaynak: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGucSecimi({
    required BuildContext context,
    required PazarYanginiProvider provider,
    required GucTipi tip,
    required IconData icon,
    required Color renk,
    required String basariSansi,
    required String maliyet,
    required String etki,
    required String yanEtki,
    required double mevcutKaynak,
    required double gerekliKaynak,
  }) {
    // GDD'ye göre [cite: 90, 42, 461] kaynak kontrolü
    final bool kullanilabilir = mevcutKaynak >= gerekliKaynak;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Opacity(
        opacity: kullanilabilir ? 1.0 : 0.5,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: renk.withOpacity(0.2),
            foregroundColor: renk,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(12),
          ),
          icon: Icon(icon),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tip.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(basariSansi,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('$maliyet | $etki',
                  style: Theme.of(context).textTheme.bodySmall),
              Text(
                'Yan Etki: $yanEtki',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          onPressed: kullanilabilir
              ? () {
                  // Seçimi provider'a bildir
                  provider.gucAta(bolge.id, tip);
                  Navigator.of(context).pop(); // Diyalogu kapat
                }
              : null, // Kaynak yoksa buton pasif
        ),
      ),
    );
  }
}
