import 'dart:async';
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
  int moveDirection;

  GroundEnemy({
    required super.position,
    required super.size,
    required this.moveDirection,
  });

  final double moveSpeed = 30;
  final double gravity = 9.8;
  final Vector2 velocity = Vector2.zero();
  static final CustomRectangleHitbox headHitbox = CustomRectangleHitbox(
    positionX: 20,
    positionY: 5,
    width: 25,
    height: 4,
  );
  static final CustomRectangleHitbox sideHitbox = CustomRectangleHitbox(
    positionX: 20,
    positionY: 13,
    width: 5,
    height: 7,
  );
  static final CustomRectangleHitbox bottomHitbox = CustomRectangleHitbox(
    positionX: 38,
    positionY: 28,
    width: 5,
    height: 4,
  );
  bool startMoving = false;
  bool isOnGround = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    current = GroundEnemyState.run;
    add(
      SideHitbox(
        position: Vector2(sideHitbox.positionX, sideHitbox.positionY),
        size: Vector2(sideHitbox.width, sideHitbox.height),
      ),
    );
    add(
      BottomHitbox(
        position: Vector2(bottomHitbox.positionX, bottomHitbox.positionY),
        size: Vector2(bottomHitbox.width, bottomHitbox.height),
      ),
    );
    add(
      HeadHitbox(
        position: Vector2(headHitbox.positionX, headHitbox.positionY),
        size: Vector2(headHitbox.width, headHitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkWherePlayer();
    if (!isOnGround) {
      _applyGravity(dt);
    } else if (startMoving) {
      _move(dt);
    }
    _deleteIfFall();
    isOnGround = false;
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
