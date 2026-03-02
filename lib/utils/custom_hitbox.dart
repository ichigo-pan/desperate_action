import 'dart:math';

import 'package:desperate_action/components/collision_blocks.dart';
import 'package:desperate_action/components/ground_enemy.dart';
import 'package:desperate_action/components/platform.dart';
import 'package:desperate_action/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

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

// class HeadHitbox extends RectangleHitbox {
//   HeadHitbox({
//     required super.position,
//     required super.size,
//     super.angle,
//     super.anchor,
//     super.priority,
//     super.isSolid = false,
//     super.collisionType = CollisionType.active,
//   });

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollision(intersectionPoints, other);
//     var block = other.parent;
//     if (block is CollisionBlocks) {
//       block = other.parent;
//     } else if (block is Platform) {
//       block = other.parent;
//     } else {
//       block = null;
//     }
//     final hitboxParent = parent;
//     if (hitboxParent is Player) {
//       if (block != null) {
//         dontPushThroughCeiling(block, hitboxParent);
//       }
//     }
//   }

//   void dontPushThroughCeiling(block, Player actor) {
//     if (actor.velocity.y < 0) {
//       actor.velocity.y = 0;
//     }
//   }
// }

// class SideHitbox extends RectangleHitbox {
//   SideHitbox({
//     required super.position,
//     required super.size,
//     super.angle,
//     super.anchor,
//     super.priority,
//     super.isSolid = false,
//     super.collisionType = CollisionType.active,
//   });
//   @override
//   void onCollisionStart(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollisionStart(intersectionPoints, other);
//     if (other.parent is CollisionBlocks || other.parent is Platform) {
//       final hitboxParent = parent;
//       if (hitboxParent is GroundEnemy) {
//         hitboxParent.moveDirection *= -1;
//         hitboxParent.flipHorizontallyAroundCenter();
//         hitboxParent.position.x += hitboxParent.moveDirection > 0 ? -10 : 10;
//       }
//     }
//   }

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollision(intersectionPoints, other);
//     var block = other.parent;
//     if (block is CollisionBlocks) {
//       block = other.parent;
//     } else if (block is Platform) {
//       block = other.parent;
//     } else {
//       block = null;
//     }
//     final hitboxParent = parent;
//     if (hitboxParent is Player) {
//       if (block != null) {
//         dontPushThroughWalls(block, hitboxParent);
//       }
//     }
//   }

//   void dontPushThroughWalls(block, Player actor) {
//     if (actor.velocity.x > 0) {
//       // игрок слева от блока
//       actor.position.x =
//           block.x -
//           actor.sideHitbox.width -
//           actor.bottomHitbox.width -
//           actor.bottomHitbox.positionX;
//     } else if (actor.velocity.x < 0) {
//       // игрок справа от блока
//       // actor.velocity.x = 0.0;
//       actor.position.x =
//           block.x +
//           block.width +
//           actor.sideHitbox.width +
//           actor.bottomHitbox.width +
//           actor.bottomHitbox.positionX;
//     }
//     actor.velocity.x = 0.0;
//   }
// }

// class BottomHitbox extends RectangleHitbox {
//   BottomHitbox({
//     required super.position,
//     required super.size,
//     super.angle,
//     super.anchor,
//     super.priority,
//     super.isSolid = false,
//     super.collisionType = CollisionType.active,
//   });

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollision(intersectionPoints, other);
//     if (other.parent is CollisionBlocks || other.parent is Platform) {
//       final hitboxParent = parent;
//       if (hitboxParent is GroundEnemy) {
//         hitboxParent.isOnGround = true;
//       } else if (hitboxParent is Player) {
//         hitboxParent.isOnGround = true;
//       }
//     }
//   }
// }

mixin AABBcollision on PositionComponent {
  Vector2 calculateNormal(PositionComponent other) {
    // Берём свой хитбокс
    final myHitbox = children.whereType<RectangleHitbox>().first;

    // Берём хитбокс другого объекта
    final otherHitbox = other.children.whereType<RectangleHitbox>().first;

    final a = myHitbox.toAbsoluteRect();
    final b = otherHitbox.toAbsoluteRect();

    final overlapX = min(a.right, b.right) - max(a.left, b.left);
    final overlapY = min(a.bottom, b.bottom) - max(a.top, b.top);

    if (overlapX <= 0 || overlapY <= 0) {
      return Vector2.zero(); // нет пересечения
    }

    final centerA = a.center;
    final centerB = b.center;

    if (overlapY < overlapX) {
      // Вертикальное столкновение
      if (centerA.dy < centerB.dy) {
        return Vector2(0, -1); // стоим на земле
      } else {
        return Vector2(0, 1); // удар головой
      }
    } else {
      // Горизонтальное столкновение
      if (centerA.dx < centerB.dx) {
        return Vector2(-1, 0);
      } else {
        return Vector2(1, 0);
      }
    }
  }
}

// mixin AABBforPlayer on PositionComponent {
//   Vector2 calculateNormal(PositionComponent other) {
//     // Берём свой хитбокс
//     final myHitbox = children.whereType<RectangleHitbox>().first;

//     // Берём хитбокс другого объекта
//     final otherHitbox = other.children.whereType<RectangleHitbox>().first;

//     final a = myHitbox.toAbsoluteRect();
//     final b = otherHitbox.toAbsoluteRect();

//     final overlapX = min(a.right, b.right) - max(a.left, b.left);
//     final overlapY = min(a.bottom, b.bottom) - max(a.top, b.top);

//     if (overlapX <= 0 || overlapY <= 0) {
//       return Vector2.zero(); // нет пересечения
//     }

//     final centerA = a.center;
//     final centerB = b.center;
//     if (overlapX < overlapY) {
//       // Горизонтальное столкновение
//       if (centerA.dx < centerB.dx) {
//         return Vector2(-1, 0); // препятствие справа
//       } else {
//         return Vector2(1, 0); // препятствие слева
//       }
//     } else {
//       // Вертикальное столкновение
//       if (centerA.dy < centerB.dy) {
//         return Vector2(0, -1); // стоим на земле
//       } else {
//         return Vector2(0, 1); // удар головой
//       }
//     }
//   }
// }
