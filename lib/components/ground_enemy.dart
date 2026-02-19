import 'dart:async';
import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum GroundEnemyState {
  hit('Hit', 5),
  run('Run', 14);

  final String name;
  final int amount;
  const GroundEnemyState(this.name, this.amount);
}

class GroundEnemy extends SpriteAnimationGroupComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks {
  final int maxMoveBlocks;
  int moveDirection;
  late int startPosition;
  late int moveRangeX;
  late final int maxLeftPos;
  late final int maxRightPos;

  GroundEnemy({
    required super.position,
    required super.size,
    required this.maxMoveBlocks,
    required this.moveDirection,
  }) {
    startPosition = (position.x).toInt();
    moveRangeX = Level.tileWidth * maxMoveBlocks;
    maxLeftPos = startPosition - moveRangeX;
    maxRightPos = startPosition + moveRangeX;
  }

  final double moveSpeed = 20;
  final Vector2 velocity = Vector2.zero();
  final CustomRectangleHitbox hitbox = CustomRectangleHitbox(
    positionX: 18,
    positionY: 5,
    width: 37,
    height: 27,
  );

  bool leftCollision = false;
  bool rightCollision = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    current = GroundEnemyState.run;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.positionX, hitbox.positionY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // _changeMoveDirection();
    _move(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);
  }

  void _changeMoveDirection() {
    if (startPosition - position.x - width / 2 - hitbox.positionX >
            moveRangeX ||
        position.x - width > startPosition && scale.x < 0) {
      moveDirection *= -1;
      flipHorizontallyAroundCenter();
    }
  }

  void _loadAllAnimations() {
    animations = {
      GroundEnemyState.run: _loadAnimation(GroundEnemyState.run),
      GroundEnemyState.hit: _loadAnimation(GroundEnemyState.hit)..loop = false,
    };
    current = GroundEnemyState.run;
  }

  SpriteAnimation _loadAnimation(GroundEnemyState state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/onGround/${state.name} (64x32).png'),
      SpriteAnimationData.sequenced(
        amount: state.amount,
        stepTime: 0.05,
        textureSize: size,
      ),
    );
  }

  void _move(double dt) {
    velocity.x = -moveDirection * moveSpeed;
    position.x += velocity.x * dt;
  }

  void kill() async {
    current = GroundEnemyState.hit;
    await animationTicker?.completed;
    removeFromParent();
  }
}
