import 'package:flutter/material.dart';

class StatIcon extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final int? maxValue; // Yeni: 100 üzerinden mi, yoksa metin mi?

  const StatIcon({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.maxValue = 100, // Varsayılan olarak 100 (eski davranış)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 10, // Metnin sığması için biraz yükseltelim
          child: maxValue != null
              // Max değer varsa (örn: 100) Progress Bar göster
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value.clamp(0, maxValue!) / maxValue!,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              // Max değer yoksa (null ise) Metin göster
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
