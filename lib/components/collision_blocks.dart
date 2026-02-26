import 'dart:async';

import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlocks extends PositionComponent
    implements HasCollisionCategory {
  CollisionBlocks({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  CollisionCategory get collisionCategory => CollisionCategory.solid;
}
