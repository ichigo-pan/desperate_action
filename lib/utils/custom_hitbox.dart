import 'package:desperate_action/components/collision_blocks.dart';
import 'package:desperate_action/components/ground_enemy.dart';
import 'package:desperate_action/components/platform.dart';
import 'package:desperate_action/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CustomRectangleHitbox {
  final double positionX;
  final double positionY;
  final double width;
  final double height;

  CustomRectangleHitbox({
    required this.positionX,
    required this.positionY,
    required this.width,
    required this.height,
  });
}

class HeadHitbox extends RectangleHitbox {
  HeadHitbox({
    required super.position,
    required super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.isSolid = false,
    super.collisionType = CollisionType.active,
  });

  @override
  void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    super.onCollision(intersectionPoints, other);
    var block = other.parent;
    if (block is CollisionBlocks) {
      block = other.parent;
    } else if (block is Platform) {
      block = other.parent;
    } else {
      block = null;
    }
    final hitboxParent = parent;
    if (hitboxParent is Player) {
      if (block != null) {
        dontPushThroughCeiling(block, hitboxParent);
      }
    }
  }

  void dontPushThroughCeiling(block, Player actor) {
    if (actor.velocity.y < 0) {
      actor.velocity.y = 0;
    }
  }
}

class SideHitbox extends RectangleHitbox {
  SideHitbox({
    required super.position,
    required super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.isSolid = false,
    super.collisionType = CollisionType.active,
  });
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other.parent is CollisionBlocks || other.parent is Platform) {
      final hitboxParent = parent;
      if (hitboxParent is GroundEnemy) {
        hitboxParent.moveDirection *= -1;
        hitboxParent.flipHorizontallyAroundCenter();
        hitboxParent.position.x += hitboxParent.moveDirection > 0 ? -10 : 10;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    super.onCollision(intersectionPoints, other);
    var block = other.parent;
    if (block is CollisionBlocks) {
      block = other.parent;
    } else if (block is Platform) {
      block = other.parent;
    } else {
      block = null;
    }
    final hitboxParent = parent;
    if (hitboxParent is Player) {
      if (block != null) {
        dontPushThroughWalls(block, hitboxParent);
      }
    }
  }

  void dontPushThroughWalls(block, Player actor) {
    if (actor.velocity.x > 0) {
      // игрок слева от блока
      actor.position.x =
          block.x -
          actor.sideHitbox.width -
          actor.bottomHitbox.width -
          actor.bottomHitbox.positionX;
    } else if (actor.velocity.x < 0) {
      // игрок справа от блока
      // actor.velocity.x = 0.0;
      actor.position.x =
          block.x +
          block.width +
          actor.sideHitbox.width +
          actor.bottomHitbox.width +
          actor.bottomHitbox.positionX;
    }
    actor.velocity.x = 0.0;
  }
}

class BottomHitbox extends RectangleHitbox {
  BottomHitbox({
    required super.position,
    required super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.isSolid = false,
    super.collisionType = CollisionType.active,
  });

  @override
  void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    super.onCollision(intersectionPoints, other);
    if (other.parent is CollisionBlocks || other.parent is Platform) {
      final hitboxParent = parent;
      if (hitboxParent is GroundEnemy) {
        hitboxParent.isOnGround = true;
      } else if (hitboxParent is Player) {
        hitboxParent.isOnGround = true;
      }
    }
  }
}
