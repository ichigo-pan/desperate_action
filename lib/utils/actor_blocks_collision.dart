import 'package:desperate_action/components/player.dart';
import 'package:flame/components.dart';

mixin AABBforPlayer {
  String? handleCollision(
    PositionComponent platform,
    Player actor, {
    bool ignoreBottom = false,
    bool fallDown = false,
  }) {
    final hb = actor.hitbox;

    // === Центр игрока ===
    final ax = actor.x;
    final ay = actor.y;
    final sx = actor.scale.x;

    final left = sx > 0 ? ax + hb.positionX : ax - hb.positionX - hb.width;

    final top = ay + hb.positionY;

    final halfW = hb.width * 0.5;
    final halfH = hb.height * 0.5;

    final centerAx = left + halfW;
    final centerAy = top + halfH;

    // === Центр платформы ===
    final halfPW = platform.width * 0.5;
    final halfPH = platform.height * 0.5;

    final centerPx = platform.x + halfPW;
    final centerPy = platform.y + halfPH;

    // === Разница центров ===
    final dx = centerAx - centerPx;
    final dy = centerAy - centerPy;

    final overlapX = halfW + halfPW - dx.abs();
    if (overlapX <= 0) return null;

    final overlapY = halfH + halfPH - dy.abs();
    if (overlapY <= 0) return null;

    // === Разрешение по меньшей оси ===
    if (overlapX < overlapY) {
      // Горизонталь
      if (dx > 0) {
        actor.x += overlapX;
        // actor.leftCollision = true;
        // return Vector2(1, 0);
      } else {
        actor.x -= overlapX;
        // actor.rightCollision = true;
        // return Vector2(-1, 0);
      }
    } else {
      // Вертикаль
      if (dy > 0) {
        // Удар головой
        // if (!ignoreBottom) {
        actor.y += overlapY;
        actor.velocity.y = 0.0;
        // return Vector2(0, 1);
        // }
      } else {
        // Приземление
        // if (fallDown) platform.doFall = true;
        actor.y -= overlapY;
        actor.velocity.y = 0.0;
        actor.isOnGround = true;
        // return Vector2(0, -1);
      }
    }
  }
}
