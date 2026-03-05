import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

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
