import 'package:flutter/material.dart';
import 'package:hyper_casual/models/game_stats.dart';
import 'package:hyper_casual/models/mini_games/bolge_model.dart';
import 'package:hyper_casual/models/mini_games/guc_secimi_model.dart';
import 'package:hyper_casual/providers/game_provider.dart';
import 'package:hyper_casual/providers/pazar_yangini_provider.dart';
import 'package:hyper_casual/widgets/mini_games/guc_secim_dialog.dart';
import 'package:provider/provider.dart';

class BolgeKartWidget extends StatelessWidget {
  final MiniGameBolge bolge;

  const BolgeKartWidget({super.key, required this.bolge});

  @override
  Widget build(BuildContext context) {
    // Ana statları al (Hazine, Ordu vb. için)
    final anaStats = context.watch<GameProvider>().stats;
    // Mini oyun provider'ını al (seçimi görmek için)
    final miniGameProvider = context.watch<PazarYanginiProvider>();

    final secilenGuc = miniGameProvider.secimler[bolge.id];
    final bool secimYapildi = secilenGuc != null && secilenGuc != GucTipi.atla;

    return Card(
      color: secimYapildi ? Colors.green.shade900 : Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          secimYapildi ? Icons.check_circle : Icons.local_fire_department,
          color: secimYapildi ? Colors.green.shade300 : Colors.red.shade400,
        ),
        title: Text(bolge.ad, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          secimYapildi
              ? 'Atanan Güç: ${secilenGuc.name.toUpperCase()}'
              : bolge.ozelKural,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        trailing: Text(
          bolge.yanginSeviyesi.toStringAsFixed(0), // Yangını göster
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.orange.shade300),
        ),
        onTap: () {
          // GÜNCELLEME: Diyalogu aç
          showDialog(
            context: context,
            builder: (dialogContext) {
              // Diyalogun kendi provider'larına erişebilmesi için
              // Ana provider'ları (GameProvider ve PazarYanginiProvider)
              // ona iletiyoruz.
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: context.read<PazarYanginiProvider>(),
                  ),
                  Provider.value(
                    value: context.read<GameProvider>().stats,
                  ),
                ],
                // Diyalogu, anaStats'ı alacak şekilde güncelliyoruz
                child: GucSecimDialog(bolge: bolge, anaStats: anaStats),
              );
            },
          );
        },
      ),
    );
  }
}
