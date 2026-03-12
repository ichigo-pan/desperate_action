import 'dart:async';
import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum CheckpointState {
  noFlag('No Flag', 1),
  flagOut('Flag Out', 26),
  idle('Flag Idle', 10);

  final String name;
  final int amount;
  const CheckpointState(this.name, this.amount);
}

class Checkpoint extends SpriteAnimationComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks {
  final int id;
  Checkpoint({required super.position, required super.size, required this.id});
  bool isCurrentCheckpoint = false;

  final CustomRectangleHitbox hitbox = CustomRectangleHitbox(
    positionX: 19,
    positionY: 19,
    width: 9,
    height: 45,
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
    if (isCurrentCheckpoint) {
      animation = _loadAnimation(CheckpointState.idle);
    } else {
      animation = _loadAnimation(CheckpointState.noFlag);
    }
    return super.onLoad();
  }

  SpriteAnimation _loadAnimation(CheckpointState state, {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Checkpoints/Checkpoint/${state.name}.png'),
      SpriteAnimationData.sequenced(
        amount: state.amount,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: loop,
      ),
    );
  }

  void _raiseCheckpoint() async {
    animation = _loadAnimation(CheckpointState.flagOut, loop: false);
    await animationTicker?.completed;
    animationTicker?.reset();
    animation = _loadAnimation(CheckpointState.idle);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      if (!isCurrentCheckpoint) {
        isCurrentCheckpoint = true;
        _raiseCheckpoint();
        game.lastCheckpointId = id;
      }
    }
  }
}
