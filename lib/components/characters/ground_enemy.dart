import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/components/platformsAndBlocks/collision_blocks.dart';
import 'package:desperate_action/components/platformsAndBlocks/platform.dart';
import 'package:desperate_action/utils/mixins/aabb_collision.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';

enum GroundEnemyState {
  hit('Hit', 5),
  run('Run', 14);

  final String name;
  final int amount;
  const GroundEnemyState(this.name, this.amount);
}

class GroundEnemy extends SpriteAnimationGroupComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks, AABBcollision {
  int moveDirection;
  late Vector2 startingPosition;
  late int startDirection;

  GroundEnemy({
    required super.position,
    required super.size,
    required this.moveDirection,
  }) {
    startingPosition = position.clone();
    startDirection = moveDirection;
  }

  final double moveSpeed = 30;
  final double gravity = 9.8;
  final Vector2 velocity = Vector2.zero();

  static final CustomRectangleHitbox hitbox = CustomRectangleHitbox(
    positionX: 23,
    positionY: 7,
    width: 20,
    height: 25,
  );
  bool startMoving = false;
  bool isOnGround = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    current = GroundEnemyState.run;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.positionX, hitbox.positionY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.state.gameStarted) {
      _checkWherePlayer();

      if (!isOnGround) _applyGravity(dt);
      if (startMoving) {
        _move(dt);
      }
      _deleteIfFall();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CollisionBlocks || other is Platform) {
      final (normal, offset) = resolveCollision(other);
      if (normal.y < 0) {
        isOnGround = true;
        velocity.y = 0;
      } else if ((normal == Vector2(1, 0) || normal == Vector2(-1, 0))) {
        moveDirection *= -1;
        flipHorizontallyAroundCenter();
        position.x += moveDirection > 0 ? -10 : 10;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is CollisionBlocks || other is Platform) {
      isOnGround = false;
    }
  }

  void _checkWherePlayer() {
    final camera = game.camera.viewfinder;
    if (camera.position.x + game.cameraWidth >= position.x) startMoving = true;
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

  void _applyGravity(double dt) {
    velocity.y += gravity;
    position.y += velocity.y * dt;
  }

  void _deleteIfFall() {
    if (position.y > game.cameraHeight) removeFromParent();
  }

  void die() async {
    current = GroundEnemyState.hit;
    await animationTicker?.completed;
    removeFromParent();
  }
}
