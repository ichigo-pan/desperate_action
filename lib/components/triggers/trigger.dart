import 'dart:async';
import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/components/checkpoints/finish.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/fallable.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Trigger extends PositionComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks {
  final int objectId;
  Trigger({
    required super.position,
    required super.size,
    required this.objectId,
  });

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
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
      final parentObjArr = game.world.children.whereType<Fallable>().where(
        (platform) => platform.id == objectId,
      );
      if (parentObjArr.isEmpty) return;
      final parentObj = parentObjArr.elementAt(0);
      if (parentObj.id == 32 && !Finish.checkedOnFinish) {
        return;
      } else {
        parentObj.doFall = true;
      }
    }
  }
}
