import 'dart:async';
import 'package:desperate_action/desperate_action.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum JumpingEnemyState {
  fly('Flying', 9);

  final String name;
  final int amount;
  const JumpingEnemyState(this.name, this.amount);
}

class JumpingEnemy extends SpriteAnimationGroupComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks {
  int moveDirection;
  late Vector2 startPosition;

  JumpingEnemy({
    required super.position,
    required super.size,
    required this.moveDirection,
  }) {
    startPosition = position.clone();
  }

  final double moveSpeed = 600;
  final Vector2 velocity = Vector2.zero();
  final double hitboxRadius = 10;
  bool _isPlayerNear = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    add(
      CircleHitbox(
        position: Vector2(10, 5),
        radius: hitboxRadius,
        collisionType: CollisionType.passive,
      ),
    );
    _changeMoveDirection();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // _checkWherePlayer();
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

  void _loadAllAnimations() {
    animations = {JumpingEnemyState.fly: _loadAnimation(JumpingEnemyState.fly)};
    current = JumpingEnemyState.fly;
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

  // void _checkWherePlayer() {
  //   final player = game.player.scale.x > 0
  //       ? game.player.position.x +
  //             game.player.hitbox.positionX +
  //             game.player.hitbox.width
  //       : game.player.position.x -
  //             game.player.hitbox.positionX -
  //             game.player.hitbox.width;
  //   final birdCenter = position.x + width / 2;
  //   if ((birdCenter - player).abs() < 20) {
  //     _isPlayerNear = true;
  //   }
  // }

  void _respawnWhenNotInCamera() {
    final cameraLeftX = game.camera.viewfinder.position.x;
    final cameraRightX = cameraLeftX + game.cameraWidth;
    if (cameraLeftX > position.x + width || cameraRightX < position.x) {
      _isPlayerNear = false;
      position = startPosition;
    }
  }
}
