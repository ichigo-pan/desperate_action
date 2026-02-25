import 'dart:async';

import 'package:desperate_action/desperate_action.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends SpriteComponent with HasGameReference<DesperateAction> {
  final bool ignoreBottom;
  final bool fallDown;
  Platform({
    required super.position,
    required super.size,
    required this.ignoreBottom,
    required this.fallDown,
  });

  bool doFall = false;
  final double moveSpeed = 300;
  final Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    sprite = Sprite(game.images.fromCache('FallingPlatform/Platform3.png'));
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // _checkPlayerY();
    if (doFall) {
      _fall(dt);
    }
  }

  // void _checkPlayerY() {
  //   final playerX = game.player.scale.x > 0
  //       ? game.player.position.x +
  //             game.player.hitbox.positionX +
  //             game.player.hitbox.width
  //       : game.player.position.x -
  //             game.player.hitbox.positionX -
  //             game.player.hitbox.width;
  //   if (ignoreBottom) {
  //     final platformCenter = position.x + width / 2;
  //     if ((platformCenter - playerX).abs() < width / 2) {
  //       if (game.player.position.y > position.y + height) {
  //         doFall = true;
  //       }
  //     }
  //   }
  // }

  void _fall(double dt) {
    if (position.y > game.cameraHeight) removeFromParent();
    velocity.y = moveSpeed;
    position.y += velocity.y * dt;
  }
}
