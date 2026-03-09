import 'dart:async';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/mixins/player_position.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum JumpingEnemyState {
  fly('Flying', 9);

  final String name;
  final int amount;
  const JumpingEnemyState(this.name, this.amount);
}

class JumpingEnemy extends SpriteAnimationComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks, PlayerPosition {
  int moveDirection;
  late Vector2 startPosition;
  late final double birdCenter;

  JumpingEnemy({
    required super.position,
    required super.size,
    required this.moveDirection,
  }) {
    startPosition = position.clone();
    birdCenter = position.x + width / 2;
  }

  final double moveSpeed = 600;
  final Vector2 velocity = Vector2.zero();
  final double hitboxRadius = 10;
  bool _isPlayerNear = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
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
    super.update(dt);
    _checkWherePlayer();
    if (_isPlayerNear) {
      _move(dt);
      _respawnWhenNotInCamera();
    }
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

  void _checkWherePlayer() {
    final player = returnPlayerPositionX(game.player);

    if ((birdCenter - player).abs() < width / 2) {
      _isPlayerNear = true;
    }
  }

  void _respawnWhenNotInCamera() {
    final cameraLeftX = game.camera.viewfinder.position.x;
    final cameraRightX = cameraLeftX + game.cameraWidth;
    if (cameraLeftX > position.x + width || cameraRightX < position.x) {
      _isPlayerNear = false;
      position = startPosition;
    }
  }
}
