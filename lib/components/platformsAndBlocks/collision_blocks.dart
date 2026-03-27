import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlocks extends PositionComponent {
  CollisionBlocks({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }
}
