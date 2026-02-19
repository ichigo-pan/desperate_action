import 'dart:async';
import 'package:desperate_action/components/collision_blocks.dart';
import 'package:desperate_action/components/ground_enemy.dart';
import 'package:desperate_action/components/jumping_enemy.dart';
import 'package:desperate_action/components/platform.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/actor_blocks_collision.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

// создать один общий класс и сделать от него наследование. Также посмотри что такое миксины. Возможно лучше миксинами

class GroundCharacters extends SpriteAnimationGroupComponent
    with
        HasGameReference<DesperateAction>,
        KeyboardHandler,
        CollisionCallbacks {
  GroundCharacters({super.position, super.size});

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 100;
  final double jumpForce = 300;
  final double gravity = 9.8;
  final double maxVelocity = 200;
  final double _bounceHeight = 150;

  int xMovement = 0;
  bool pressedJump = false;
  bool isOnGround = true;
  bool leftCollision = false;
  bool rightCollision = false;

  final CustomRectangleHitbox hitbox = CustomRectangleHitbox(
    positionX: 10,
    positionY: 5,
    width: 14,
    height: 27,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    add(
      RectangleHitbox(
        size: Vector2(hitbox.width, hitbox.height),
        position: Vector2(hitbox.positionX, hitbox.positionY),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateMovements(dt);
    _applyGravity(dt);
    _changeAnimation();
    _changeSpriteScale();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is GroundEnemy) {
      if (velocity.y > 0) {
        other.kill();
        velocity.y = -_bounceHeight;
      } else {
        // ignore: avoid_print
        print('bonk!');
      }
    }
    if (other is JumpingEnemy) {
      // ignore: avoid_print
      print('Air bonk!');
    }
    if (other is Platform) {
      if (other.ignoreBottom && other.velocity.y > 0) {
        print('Die');
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is CollisionBlocks) {
      if (isOnGround) {
        isOnGround = false;
      }
      if (rightCollision) {
        rightCollision = false;
      }
      if (leftCollision) {
        leftCollision = false;
      }
    }
    if (other is Platform) {
      if (isOnGround) {
        isOnGround = false;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is CollisionBlocks) {
      handleCollisionWithSolid(other, this);
    }
    if (other is Platform) {
      if (other.velocity.y == 0) {
        handleCollisionWithSolid(
          other,
          this,
          ignoreBottom: other.ignoreBottom,
          fallDown: other.fallDown,
        );
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // horizontal movemets
    xMovement = 0;
    final isKeyLeft =
        (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA)) &&
        (!leftCollision);
    final isKeyRight =
        (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD)) &&
        (!rightCollision);

    xMovement += isKeyLeft ? -1 : 0;
    xMovement += isKeyRight ? 1 : 0;

    // vertical movements
    pressedJump =
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    animations = {
      for (final state in PlayerState.values) state: _loadAnimation(state),
    };
  }

  SpriteAnimation _loadAnimation(PlayerState state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Player/${state.name} (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: state.amount,
        stepTime: 0.05,
        textureSize: size,
      ),
    );
  }

  void _updateMovements(double dt) {
    if (pressedJump && isOnGround) _jump(dt);
    velocity.x = xMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _changeAnimation() {
    if (isOnGround) {
      if (velocity.x != 0) {
        current = PlayerState.run;
      } else {
        current = PlayerState.idle;
      }
    } else {
      if (velocity.y < 0) {
        current = PlayerState.jump;
      } else if (velocity.y > 0) {
        current = PlayerState.fall;
      }
    }
  }

  void _changeSpriteScale() {
    if (velocity.x < 0 && scale.x > 0) flipHorizontallyAroundCenter();
    if (velocity.x > 0 && scale.x < 0) flipHorizontallyAroundCenter();
  }

  void _jump(double dt) {
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    pressedJump = false;
    isOnGround = false;
  }

  void _applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, maxVelocity);
    position.y += velocity.y * dt;
  }
}
