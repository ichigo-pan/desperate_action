import 'dart:async';
import 'package:desperate_action/components/checkpoints/exit.dart';
import 'package:desperate_action/components/checkpoints/finish.dart';
import 'package:desperate_action/components/platformsAndBlocks/invisible_blocks.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:desperate_action/components/platformsAndBlocks/platform.dart';
import 'package:desperate_action/utils/mixins/aabb_collision.dart';
import 'package:desperate_action/components/characters/ground_enemy.dart';
import 'package:desperate_action/components/characters/jumping_enemy.dart';
import 'package:desperate_action/components/platformsAndBlocks/collision_blocks.dart';

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
    with
        HasGameReference<DesperateAction>,
        KeyboardHandler,
        CollisionCallbacks,
        AABBcollision {
  Player({super.position, super.size});

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 100;
  final double jumpForce = 300;
  final double gravity = 9.8;
  final double maxVelocity = 200;
  final double _bounceHeight = 150;

  double? targetFinishPosition;

  int xMovement = 0;
  bool pressedJump = false;
  bool isOnGround = false;
  bool _controlsEnabled = true;
  bool _isUserMove = true;
  bool doExitFromLevel = false;

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
        position: Vector2(hitbox.positionX, hitbox.positionY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    _controlsEnabled = false;
    _isUserMove = true;
    velocity.setZero();
    // Добавляем таймер, который включит управление через 1 секунду
    add(
      TimerComponent(
        period: 1.0,
        repeat: false,
        onTick: () {
          _controlsEnabled = true;
        },
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.gameStarted) {
      if (_isUserMove) {
        _updateMovements(dt);
      } else {
        _moveRight(dt);
      }
    }
    if (!isOnGround) _applyGravity(dt);
    _changeSpriteScale();
    _changeAnimation();
    _checkIfFallFromScreen();
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is CollisionBlocks ||
        other is Platform ||
        (other is InvisibleBlocks && other.isVisible)) {
      final (normal, offset) = resolveCollision(other);

      // Дополнительная логика, зависящая от направления
      if (normal.y < 0) {
        // Столкновение снизу – стоим на земле
        isOnGround = true;
        velocity.y = 0;
      } else if (normal.y > 0) {
        // Удар головой
        if (velocity.y < 0) velocity.y = 0;
      }
      if (normal.x != 0) velocity.x = 0;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is CollisionBlocks ||
        other is Platform ||
        other is InvisibleBlocks) {
      isOnGround = false;
    }
    if (other is Exit) {
      Exit.isOnExit = false;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is GroundEnemy) {
      final (normal, offset) = resolveCollision(other);
      if (normal.y < 0) {
        other.die();
        velocity.y = -_bounceHeight;
      } else {
        _die();
      }
    }
    if (other is JumpingEnemy) {
      _die();
    }
    if (other is Platform) {
      if (other.fallOnPlayer && other.velocity.y > 0) {
        _die();
      } else if (other.fallWithPlayer) {
        isOnGround = true;
      }
    }
    if (other is Finish) {
      _isUserMove = false;
      targetFinishPosition = other.x + 100;
    }
    if (other is Exit) {
      Exit.isOnExit = true;
      print(Exit.isOnExit);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!_controlsEnabled) return false;
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

    doExitFromLevel =
        keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    if (doExitFromLevel && Exit.isOnExit) _exitFromLevel();
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

  void _moveRight(double dt) {
    // Двигаемся вправо с постоянной скоростью
    velocity.x = moveSpeed;
    position.x += velocity.x * dt;

    // Если достигли или превысили цель, останавливаем автоматическое движение
    if (position.x >= targetFinishPosition!) {
      velocity.x = 0;
      _isUserMove = true;
    }
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
      // position.x += 5;
    }
    if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
      // position.x -= 5;
    }
  }

  void _jump(double dt) {
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    pressedJump = false;
    // isOnGround = false;
  }

  void _applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, maxVelocity);
    position.y += velocity.y * dt;
  }

  void _checkIfFallFromScreen() {
    if (position.y > game.cameraHeight) _die();
  }

  void _die() {
    game.playerDied();
  }

  void _exitFromLevel() {
    game.exitLevel();
  }
}
