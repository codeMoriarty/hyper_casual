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
    // Mini oyun provider'ını DİNLE (watch), çünkü sayaçlar değişecek
    final provider = context.watch<PazarYanginiProvider>();

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
              basariSansi: '${provider.golgeBasariSansi}%',
              maliyet: '${provider.golgeMaliyeti} Gölge Gücü',
              etki: 'Tam Söndürme (Max 200)',
              yanEtki: 'Diplomasi -10 (İlk 2)',
              mevcutKaynak: provider.miniGameGolgeGucu,
              gerekliKaynak: provider.golgeMaliyeti.toDouble(),
            ),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.ordu,
              icon: Icons.shield,
              renk: Colors.red.shade300,
              basariSansi: '${provider.orduBasariSansi}%',
              maliyet: '${provider.orduMaliyeti} Hazine', // GÜNCELLENDİ
              etki: 'Orta-Yüksek Söndürme',
              // YENİ: Ordu limiti için yan etki metni
              yanEtki:
                  'Tur Limiti: ${provider.orduKullanilanBuTur}/${provider.maxOrduKullanimi}',
              mevcutKaynak: anaStats.hazine.toDouble(),
              gerekliKaynak: provider.orduMaliyeti.toDouble(), // GÜNCELLENDİ
            ),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.halk,
              icon: Icons.people,
              renk: Colors.blue.shade300,
              basariSansi: '${provider.halkBasariSansi}%', // GÜNCELLENDİ
              maliyet: 'ÜCRETSİZ',
              etki: 'Düşük Söndürme',
              yanEtki: 'Halk+5, Ordu+5 (Her 2)',
              mevcutKaynak: anaStats.halk.toDouble(),
              gerekliKaynak: provider.halkGerekliStat.toDouble(),
            ),
            _buildGucSecimi(
              context: context,
              provider: provider,
              tip: GucTipi.buyucu,
              icon: Icons.auto_awesome,
              renk: Colors.cyan.shade300,
              basariSansi: '${provider.buyucuBasariSansi}%',
              maliyet: '${provider.buyucuMaliyeti} Hazine', // GÜNCELLENDİ
              etki: 'Çok Yüksek Söndürme',
              yanEtki: 'Din+10, Diplomasi-5',
              mevcutKaynak: anaStats.hazine.toDouble(),
              gerekliKaynak: provider.buyucuMaliyeti.toDouble(), // GÜNCELLENDİ
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
              yanEtki: 'Tehlike Çarpanı artabilir',
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
    bool kullanilabilir = mevcutKaynak >= gerekliKaynak;

    // YENİ ZORLUK: Ordu limiti kontrolü
    if (tip == GucTipi.ordu) {
      // Eğer bu bölge zaten Ordu seçiliyse (veya değiştiriliyorsa), limiti kontrol etme
      // Ama yeni bir bölgeye Ordu atanıyorsa, limiti kontrol et
      final bool buBolgeyeZatenAtanmis =
          provider.secimler[bolge.id] == GucTipi.ordu;

      if (!buBolgeyeZatenAtanmis &&
          provider.orduKullanilanBuTur >= provider.maxOrduKullanimi) {
        kullanilabilir = false; // Limit dolu
      }
    }

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
              : null, // Kaynak yoksa veya limit doluysa buton pasif
        ),
      ),
    );
  }
}
