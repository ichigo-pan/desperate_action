import 'dart:async';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/fallable.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum JumpingEnemyState {
  fly('Flying', 9);

  final String name;
  final int amount;
  const JumpingEnemyState(this.name, this.amount);
}

class JumpingEnemy extends SpriteAnimationComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks
    implements Fallable {
  int moveDirection;
  @override
  final int id;

  late Vector2 startPosition;
  late final double birdCenter;

  JumpingEnemy({
    required super.position,
    required super.size,
    required this.id,
    required this.moveDirection,
  }) {
    startPosition = position.clone();
    birdCenter = position.x + width / 2;
  }

  final double moveSpeed = 560;
  final Vector2 velocity = Vector2.zero();
  final double hitboxRadius = 10;
  @override
  bool doFall = false;

  @override
  FutureOr<void> onLoad() {
    _changeMoveDirection();
    animation = _loadAnimation(JumpingEnemyState.fly);
    add(
      CircleHitbox(
        position: Vector2(10, 5),
        radius: hitboxRadius,
        collisionType: CollisionType.passive,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.state.gameStarted) {
      if (doFall) {
        _move(dt);
        _respawnWhenNotInCamera();
      }
    }
    super.update(dt);
  }

  void _changeMoveDirection() {
    if (moveDirection > 0) {
      flipVerticallyAroundCenter();
    }
  }

  SpriteAnimation _loadAnimation(JumpingEnemyState state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Enemies/jumpingFromEdges/${state.name} (32x32).png',
      ),
      SpriteAnimationData.sequenced(
        amount: state.amount,
        stepTime: 0.05,
        textureSize: size,
      ),
    );
  }

  void _move(double dt) {
    if (position.y > game.cameraHeight || position.y + height < 0) return;
    velocity.y = moveDirection * moveSpeed;
    position.y += velocity.y * dt;
  }

  void _respawnWhenNotInCamera() {
    final cameraLeftX = game.camera.viewfinder.position.x;
    final cameraRightX = cameraLeftX + game.cameraWidth;
    if (cameraLeftX > position.x + width || cameraRightX < position.x) {
      doFall = false;
      position = startPosition;
    }
  }
}
