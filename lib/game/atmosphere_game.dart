import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class AtmosphereGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF110a1c); // Koyu mor/siyah

  @override
  Future<void> onLoad() async {
    // Arka plan resmi (opsiyonel, bulamazsa sadece renk kalır)
    try {
      final background = await Sprite.load('background.png');
      add(
        SpriteComponent(sprite: background, size: size)
          ..anchor = Anchor.center
          ..position = size / 2,
      );
    } catch (e) {
      //print("Arka plan resmi yüklenemedi: $e");
    }

    // Ekranda dolaşan "gölge fısıltıları" (partiküller)
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 20,
          lifespan: 5,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
                Random().nextDouble() * 100 - 50, -Random().nextDouble() * 50),
            child: CircleParticle(
              radius: Random().nextDouble() * 1.5 + 0.5,
              paint: Paint()..color = Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }
}
