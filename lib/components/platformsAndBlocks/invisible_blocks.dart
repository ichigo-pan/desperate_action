import 'dart:async';

import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/mixins/aabb_collision.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class InvisibleBlocks extends SpriteComponent
    with
        HasGameReference<DesperateAction>,
        CollisionCallbacks,
        HasVisibility,
        AABBcollision {
  String spriteName;
  InvisibleBlocks({
    required super.position,
    required super.size,
    required this.spriteName,
  });

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('InvisibleBlocks/$spriteName.png'));
    isVisible = false;

    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      if (!isVisible) {
        final a = myHitboxRect;
        // final a = otherHitboxRect(this);
        final b = otherHitboxRect(other);
        final (overlapX, overlapY) = computeOverlap(a, b);
        final normal = computeNormal(a, b, overlapX, overlapY);
        if (normal.y < 0) {
          isVisible = true;
        }
      }
    }
  }
}
