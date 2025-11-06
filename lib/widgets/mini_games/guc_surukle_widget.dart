import 'package:flutter/material.dart';
import 'package:hyper_casual/models/mini_games/guc_secimi_model.dart';

// Alttaki barda sürüklediğimiz ikon
class GucSurukleWidget extends StatelessWidget {
  final GucTipi gucTipi;
  final IconData icon;
  final Color renk;
  final bool aktif;

  const GucSurukleWidget({
    super.key,
    required this.gucTipi,
    required this.icon,
    required this.renk,
    this.aktif = true,
  });

  @override
  Widget build(BuildContext context) {
    // Sürüklenirken parmağın altında görünecek widget
    final feedbackWidget = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: renk.withOpacity(0.8),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 5),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 40),
    );

    // Barda duran, sürüklenmeyi başlatan widget
    final childWidget = Opacity(
      opacity: aktif ? 1.0 : 0.3,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: renk.withOpacity(0.2),
          border: Border.all(color: renk, width: 2),
        ),
        child: Icon(icon, color: renk, size: 32),
      ),
    );

    // Eğer 'aktif' değilse sürüklenemez yap
    if (!aktif) {
      return childWidget;
    }

    // Bu widget'ı sürükle
    return Draggable<GucTipi>(
      data: gucTipi, // Sürüklerken taşıdığımız veri (örn: GucTipi.ordu)
      feedback: feedbackWidget, // Parmağın altındaki
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: childWidget, // Sürüklerken barda kalan
      ),
      child: childWidget, // Barda duran normal hali
    );
  }
}
