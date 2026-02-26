import 'package:desperate_action/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum HitboxSide { head, side, bottom }

enum CollisionPhase { start, stay }

enum CollisionCategory { groundEnemy, jumpingEnemy, player, solid, platform }

class CustomRectangleHitboxSize {
  final double positionX;
  final double positionY;
  final double width;
  final double height;

  CustomRectangleHitboxSize({
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
//   void onCollisionStart(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollisionStart(intersectionPoints, other);
//     if (checkIfCollisionValid(parent, other.parent)) {
//       (parent as CustomHitboxesCollision).onHeadCollision(
//         other,
//         CollisionPhase.start,
//         (other.parent as HasCollisionCategory).collisionCategory,
//       );
//     }
//   }

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollision(intersectionPoints, other);
//     if (checkIfCollisionValid(parent, other.parent)) {
//       (parent as CustomHitboxesCollision).onHeadCollision(
//         other,
//         CollisionPhase.stay,
//         (other.parent as HasCollisionCategory).collisionCategory,
//       );
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
//     if (checkIfCollisionValid(parent, other.parent)) {
//       (parent as CustomHitboxesCollision).onSideCollision(
//         other,
//         CollisionPhase.start,
//         (other.parent as HasCollisionCategory).collisionCategory,
//       );
//     }
//   }

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollision(intersectionPoints, other);

//     if (checkIfCollisionValid(parent, other.parent)) {
//       (parent as CustomHitboxesCollision).onSideCollision(
//         other,
//         CollisionPhase.stay,
//         (other.parent as HasCollisionCategory).collisionCategory,
//       );
//     }
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
//   void onCollisionStart(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollisionStart(intersectionPoints, other);
//     if (checkIfCollisionValid(parent, other.parent)) {
//       (parent as CustomHitboxesCollision).onBottomCollision(
//         other,
//         CollisionPhase.start,
//         (other.parent as HasCollisionCategory).collisionCategory,
//       );
//     }
//   }

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
//     super.onCollision(intersectionPoints, other);
//     if (checkIfCollisionValid(parent, other.parent)) {
//       (parent as CustomHitboxesCollision).onBottomCollision(
//         other,
//         CollisionPhase.stay,
//         (other.parent as HasCollisionCategory).collisionCategory,
//       );
//     }
//   }
// }

class CustomHitbox extends RectangleHitbox {
  final HitboxSide side;
  CustomHitbox({
    required this.side,
    required super.position,
    required super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.isSolid = false,
    super.collisionType = CollisionType.active,
  });

  bool _checkIfCollisionBetweenCustomAndRectangle(parent, other) {
    return (parent is CustomHitboxesCollision &&
        other.parent is HasCollisionCategory);
  }

  void _handleCollision(ShapeHitbox other, CollisionPhase phase) {
    if (_checkIfCollisionBetweenCustomAndRectangle(parent, other)) {
      final category = (other.parent as HasCollisionCategory).collisionCategory;
      (parent as CustomHitboxesCollision).handleCollision(
        side,
        other,
        phase,
        category,
      );
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    super.onCollisionStart(intersectionPoints, other);
    _handleCollision(other, CollisionPhase.start);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    super.onCollision(intersectionPoints, other);
    _handleCollision(other, CollisionPhase.stay);
  }
}

abstract interface class CustomHitboxesCollision {
  // void onHeadCollision(
  //   ShapeHitbox other,
  //   CollisionPhase phase,
  //   CollisionCategory category,
  // );
  // void onSideCollision(
  //   ShapeHitbox other,
  //   CollisionPhase phase,
  //   CollisionCategory category,
  // );
  // void onBottomCollision(
  //   ShapeHitbox other,
  //   CollisionPhase phase,
  //   CollisionCategory category,
  // );
  void handleCollision(
    HitboxSide side,
    ShapeHitbox other,
    CollisionPhase phase,
    CollisionCategory category,
  );
}

abstract interface class HasCollisionCategory {
  CollisionCategory get collisionCategory;
}


// ✅ Способ 1 — Через AABB и overlap (самый популярный)

// Это стандарт для прямоугольников без вращения.

// Идея

// Берём глобальные границы двух RectangleHitbox

// Считаем пересечение по X и Y

// Смотрим, по какой оси проникновение меньше

// Эта ось и есть направление нормали

// Логика вычисления

// Пусть есть:

// rectA

// rectB

// 1️⃣ Получаем мировые координаты
// final a = hitboxA.toAbsoluteRect();
// final b = hitboxB.toAbsoluteRect();
// 2️⃣ Вычисляем пересечение
// final overlapX = min(a.right, b.right) - max(a.left, b.left);
// final overlapY = min(a.bottom, b.bottom) - max(a.top, b.top);

// Если overlapX <= 0 или overlapY <= 0 → нет столкновения.

// 3️⃣ Определяем минимальную ось
// if (overlapX < overlapY) {
//   // горизонтальное столкновение
// } else {
//   // вертикальное столкновение
// }
// 4️⃣ Определяем направление нормали
// final centerA = a.center;
// final centerB = b.center;

// if (overlapX < overlapY) {
//   if (centerA.dx < centerB.dx) {
//     normal = Vector2(-1, 0); // удар справа
//   } else {
//     normal = Vector2(1, 0);  // удар слева
//   }
// } else {
//   if (centerA.dy < centerB.dy) {
//     normal = Vector2(0, -1); // приземление
//   } else {
//     normal = Vector2(0, 1);  // удар головой
//   }
// }
// 🎯 Что это даёт
// Normal	Значение в платформере
// (0, -1)	игрок приземлился
// (0, 1)	удар головой
// (1, 0)	столкновение слева
// (-1, 0)	столкновение справа

// Это именно то, что используют большинство 2D платформеров.