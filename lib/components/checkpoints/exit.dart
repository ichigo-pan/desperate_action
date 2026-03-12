import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Exit extends PositionComponent {
  Exit({required super.position, required super.size});

  static bool isOnExit = false;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }
}
