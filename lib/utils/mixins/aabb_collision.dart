import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

mixin AABBcollision on PositionComponent {
  // 1. Прямоугольник собственного хитбокса
  Rect get myHitboxRect {
    return children.whereType<RectangleHitbox>().first.toAbsoluteRect();
  }

  // 2. Прямоугольник хитбокса другого объекта
  Rect otherHitboxRect(PositionComponent other) {
    return other.children.whereType<RectangleHitbox>().first.toAbsoluteRect();
  }

  // 3. Вычисление перекрытий
  (double x, double y) computeOverlap(Rect a, Rect b) {
    final overlapX = min(a.right, b.right) - max(a.left, b.left);
    final overlapY = min(a.bottom, b.bottom) - max(a.top, b.top);
    return (overlapX, overlapY);
  }

  // 4. Вычисление нормали по прямоугольникам и перекрытиям
  Vector2 computeNormal(Rect a, Rect b, double overlapX, double overlapY) {
    if (overlapX <= 0.1 || overlapY <= 0.1) return Vector2.zero();

    if (overlapY < overlapX) {
      // Вертикальное столкновение
      return a.center.dy < b.center.dy
          ? Vector2(0, -1) // столкновение снизу
          : Vector2(0, 1); // столкновение сверху
    } else {
      // Горизонтальное столкновение
      return a.center.dx < b.center.dx ? Vector2(-1, 0) : Vector2(1, 0);
    }
  }

  // 5. Вычисление смещения для разрешения коллизии
  Vector2 separationOffset(Vector2 normal, double overlapX, double overlapY) {
    return Vector2(normal.x * overlapX, normal.y * overlapY);
  }

  // 6. (Опционально) Полный метод разрешения коллизии
  /// Возвращает нормаль столкновения и смещение, которое уже применено к позиции.
  (Vector2 normal, Vector2 offset) resolveCollision(PositionComponent other) {
    final a = myHitboxRect;
    final b = otherHitboxRect(other);
    final (overlapX, overlapY) = computeOverlap(a, b);
    final normal = computeNormal(a, b, overlapX, overlapY);
    if (normal == Vector2.zero()) return (Vector2.zero(), Vector2.zero());

    final offset = separationOffset(normal, overlapX, overlapY);
    position += offset;
    return (normal, offset);
  }
}
