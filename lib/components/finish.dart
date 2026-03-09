import 'dart:async';
import 'package:desperate_action/components/player.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum FinishState {
  pressed('Pressed', 8),
  idle('Idle', 1);

  final String name;
  final int amount;
  const FinishState(this.name, this.amount);
}

class Finish extends SpriteAnimationComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks {
  Finish({required super.position, required super.size});
  bool _checkedOnFinish = false;

  final CustomRectangleHitbox hitbox = CustomRectangleHitbox(
    positionX: 19,
    positionY: 20,
    width: 26,
    height: 44,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.positionX, hitbox.positionY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );

    animation = _loadAnimation(FinishState.idle);

    return super.onLoad();
  }

  SpriteAnimation _loadAnimation(FinishState state, {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Checkpoints/Finish/${state.name}.png'),
      SpriteAnimationData.sequenced(
        amount: state.amount,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: loop,
      ),
    );
  }

  void _finishPressed() async {
    animation = _loadAnimation(FinishState.pressed, loop: false);
    await animationTicker?.completed;
    animationTicker?.reset();
    animation = _loadAnimation(FinishState.idle);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      if (!_checkedOnFinish) {
        _checkedOnFinish = true;
        _finishPressed();
      }
    }
  }
}
