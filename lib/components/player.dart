import 'dart:async';
import 'package:desperate_action/components/collision_blocks.dart';
import 'package:desperate_action/components/ground_enemy.dart';
import 'package:desperate_action/components/jumping_enemy.dart';
import 'package:desperate_action/components/platform.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  fall('Fall', 1),
  idle('Idle', 11),
  jump('Jump', 1),
  run('Run', 12);

  final String name;
  final int amount;
  const PlayerState(this.name, this.amount);
}

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<DesperateAction>, KeyboardHandler, CollisionCallbacks
    implements CustomHitboxesCollision, HasCollisionCategory {
  Player({super.position, super.size});

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 100;
  final double jumpForce = 300;
  final double gravity = 9.8;
  final double maxVelocity = 200;
  final double _bounceHeight = 150;

  int xMovement = 0;
  bool pressedJump = false;
  bool isOnGround = false;

  // final CustomRectangleHitbox hitbox = CustomRectangleHitbox(
  //   positionX: 10,
  //   positionY: 5,
  //   width: 14,
  //   height: 27,
  // );

  final CustomRectangleHitboxSize headHitbox = CustomRectangleHitboxSize(
    positionX: 7,
    positionY: 5,
    width: 19,
    height: 4,
  );
  final CustomRectangleHitboxSize sideHitbox = CustomRectangleHitboxSize(
    positionX: 24,
    positionY: 14,
    width: 6,
    height: 11,
  );
  final CustomRectangleHitboxSize bottomHitbox = CustomRectangleHitboxSize(
    positionX: 10,
    positionY: 27,
    width: 13,
    height: 5,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    addAll([
      CustomHitbox(
        side: HitboxSide.head,
        position: Vector2(headHitbox.positionX, headHitbox.positionY),
        size: Vector2(headHitbox.width, headHitbox.height),
      ),
      CustomHitbox(
        side: HitboxSide.side,
        position: Vector2(sideHitbox.positionX, sideHitbox.positionY),
        size: Vector2(sideHitbox.width, sideHitbox.height),
      ),
      CustomHitbox(
        side: HitboxSide.bottom,
        position: Vector2(bottomHitbox.positionX, bottomHitbox.positionY),
        size: Vector2(bottomHitbox.width, bottomHitbox.height),
      ),
    ]);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateMovements(dt);
    if (!isOnGround) _applyGravity(dt);
    _changeAnimation();
    _changeSpriteScale();
    isOnGround = false;
  }

  @override
  CollisionCategory get collisionCategory => CollisionCategory.player;

  // @override
  // void onCollisionStart(
  //   Set<Vector2> intersectionPoints,
  //   PositionComponent other,
  // ) {
  //   super.onCollisionStart(intersectionPoints, other);
  //   if (other is GroundEnemy) {
  //     if (velocity.y != 0) {
  //       other.die();
  //       velocity.y = -_bounceHeight;
  //     } else {
  //       // ignore: avoid_print
  //       print('bonk!');
  //       game.score.updateLifeCount();
  //     }
  //   }
  //   if (other is JumpingEnemy) {
  //     // ignore: avoid_print
  //     print('Air bonk!');
  //     die()
  //   }
  //   if (other is Platform) {
  //     if (other.ignoreBottom && other.velocity.y > 0) {
  //       print('Die');
  //       game.score.updateLifeCount();
  //     }
  //   }
  // }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // horizontal movemets
    xMovement = 0;
    final isKeyLeft =
        (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA));
    final isKeyRight =
        (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD));

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
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
      position.x += 5;
    }
    if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
      position.x -= 5;
    }
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

  void _dontPushThroughCeiling() {
    if (velocity.y < 0) {
      velocity.y = 0;
    }
  }

  void _dontPushThroughWalls(block) {
    if (velocity.x > 0) {
      // игрок слева от блока
      position.x =
          block.x -
          sideHitbox.width -
          bottomHitbox.width -
          bottomHitbox.positionX;
    } else if (velocity.x < 0) {
      // игрок справа от блока
      position.x =
          block.x +
          block.width +
          sideHitbox.width +
          bottomHitbox.width +
          bottomHitbox.positionX;
    }
    velocity.x = 0.0;
  }

  void die() {
    game.score.updateLifeCount();
  }

  @override
  void handleCollision(
    HitboxSide side,
    ShapeHitbox other,
    CollisionPhase phase,
    CollisionCategory category,
  ) {
    // head collisions
    if (side == HitboxSide.head) {
      if (category == CollisionCategory.solid &&
          phase == CollisionPhase.start) {
        _dontPushThroughCeiling();
      }
    }

    // side collisions
    if (side == HitboxSide.side) {
      if (phase == CollisionPhase.stay && category == CollisionCategory.solid) {
        _dontPushThroughWalls(other.parent);
      }
    }

    // bottom collisions
    if (side == HitboxSide.bottom) {
      if (category == CollisionCategory.solid && phase == CollisionPhase.stay) {
        isOnGround = true;
      }
    }
  }

  //   @override
  //   void onBottomCollision(
  //     ShapeHitbox other,
  //     CollisionPhase phase,
  //     CollisionCategory category,
  //   ) {
  //     if ()
  //     if (category == CollisionCategory.solid && phase == CollisionPhase.stay) {
  //       isOnGround = true;
  //     }
  //   }

  //   @override
  //   void onHeadCollision(
  //     ShapeHitbox other,
  //     CollisionPhase phase,
  //     CollisionCategory category,
  //   ) {
  //     if (category == CollisionCategory.solid && phase == CollisionPhase.start) {
  //       _dontPushThroughCeiling();
  //     }
  //   }

  //   @override
  //   void onSideCollision(
  //     ShapeHitbox other,
  //     CollisionPhase phase,
  //     CollisionCategory category,
  //   ) {
  //     if (phase == CollisionPhase.stay && category == CollisionCategory.solid) {
  //       _dontPushThroughWalls(other.parent);
  //     }
  //   }
}
