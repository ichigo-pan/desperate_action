import 'dart:async';
import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/utils/camera_follows_player.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/rendering.dart';

class BackgroundImg extends ParallaxComponent {
  late Player player;
  final screenWidth = 800;

  BackgroundImg({required this.player});

  final Vector2 baseVelocity = Vector2.zero();
  @override
  FutureOr<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('Background/3 - Big_mountain_BG.png'),
        ParallaxImageData('Background/2 - Smaller_mountains.png'),
        ParallaxImageData('Background/1 - Snowy_foreground_area.png'),
      ],

      baseVelocity: baseVelocity,
      velocityMultiplierDelta: Vector2(1.8, 0),
      repeat: ImageRepeat.repeatX,
    );
    position = Vector2(0, -60);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    double targetVelocity = 0;

    if (CameraFollowSystem.isMoving && player.xMovement > 0) {
      targetVelocity = 5;
    } else if (CameraFollowSystem.isMoving && player.xMovement < 0) {
      targetVelocity = -5;
    }

    // плавное приближение к targetVelocity
    const double smoothing = 0.3; // коэффициент сглаживания
    baseVelocity.x += (targetVelocity - baseVelocity.x) * smoothing;
  }
}
