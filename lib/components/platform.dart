import 'dart:async';

import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:desperate_action/utils/player_utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends SpriteComponent
    with HasGameReference<DesperateAction>
    implements HasCollisionCategory {
  final bool fallOnPlayer;
  final bool fallWithPlayer;
  Platform({
    required super.position,
    required super.size,
    required this.fallOnPlayer,
    required this.fallWithPlayer,
  });

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

  @override
  CollisionCategory get collisionCategory {
    if (doFall) return CollisionCategory.platform;
    return CollisionCategory.solid;
  }

  void _checkPlayerY() {
    final playerX = returnPlayerPosition(game.player);

    final platformCenter = position.x + width / 2;
    if ((platformCenter - playerX).abs() < width / 2) {
      if (game.player.position.y > position.y + height) {
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
