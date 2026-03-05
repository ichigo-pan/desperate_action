import 'dart:async';

import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/mixins/player_position.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends SpriteComponent
    with HasGameReference<DesperateAction>, PlayerPosition {
  final bool fallOnPlayer;
  final bool fallWithPlayer;
  late final double platformCenter;
  Platform({
    required super.position,
    required super.size,
    required this.fallOnPlayer,
    required this.fallWithPlayer,
  }) {
    platformCenter = position.x + width / 2;
  }

  bool doFall = false;
  final double moveSpeed = 250;
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
    _checkPlayerY();
    if (doFall) {
      _fall(dt);
    }
  }

  void _checkPlayerY() {
    final playerX = returnPlayerPositionX(game.player);

    if ((platformCenter - playerX).abs() < width / 2) {
      if (fallWithPlayer && game.player.isOnGround) {
        doFall = true;
      } else if (fallOnPlayer && game.player.position.y > position.y + height) {
        doFall = true;
      }
    }
  }

  void _fall(double dt) {
    if (position.y > game.cameraHeight) removeFromParent();
    velocity.y = moveSpeed;
    position.y += velocity.y * dt;
  }
}
