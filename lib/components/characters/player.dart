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
  final double moveSpeed = 140;
  final double jumpForce = 340;
  final double gravity = 900;
  final double maxVelocity = 380;
  final double _bounceHeight = 320;
  int xMovement = 0;

  double? targetFinishPosition;

  bool pressedJump = false;
  bool isOnGround = true;
  bool _controlsEnabled = true;
  bool _moveAuto = true;
  bool _wasAutoMoved = false;
  bool _isDead = false;
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
    _moveAuto = false;
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
    if (game.state.gameStarted && !_isDead) {
      if (_controlsEnabled) {
        _updateMovements(dt);
      } else if (_moveAuto) {
        _autoMoveRight(dt);
      }
    }
    if (!isOnGround && isLoaded) _applyGravity(dt);
    _changeSpriteScale();
    _changeAnimation();
    _checkIfFallFromScreen();
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!_isDead) {
      if (other is CollisionBlocks ||
          other is Platform ||
          (other is InvisibleBlocks && other.isVisible)) {
        final (normal, offset) = resolveCollision(other);

        // Дополнительная логика, зависящая от направления
        if (normal.y < 0 && velocity.y >= 0) {
          // Столкновение снизу – стоим на земле
          isOnGround = true;
          velocity.y = 0;
        } else if (normal.y > 0) {
          // Удар головой
          if (velocity.y < 0) velocity.y = 0;
        }
        // Удар боком
        if (normal.x != 0) velocity.x = 0;
      }
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
    if (!_isDead) {
      if (other is GroundEnemy) {
        final (normal, offset) = resolveCollision(other);
        if (normal.y < 0 && velocity.y >= 0) {
          other.die();
          velocity.y = -_bounceHeight;
        } else {
          _die(true);
        }
      }
      if (other is JumpingEnemy) {
        _die(true);
      }
      if (other is Platform) {
        if (other.fallOnPlayer && other.velocity.y > 0) {
          _die(true);
        } else if (other.fallWithPlayer) {
          isOnGround = true;
        }
      }
      if (other is Finish) {
        // проверяем, сталкивались ли уже с финишом. Нельзя использовать статическое свойство, потому что коллизии вызываются не так как хотелось бы
        if (_wasAutoMoved) return;
        // отключаем движение от клавиатуры и включаем автодвижение
        _controlsEnabled = false;
        xMovement = 0;
        _moveAuto = true;
        targetFinishPosition = other.x + 100;
      }
      if (other is Exit) {
        Exit.isOnExit = true;
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!_controlsEnabled) return true;
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

  void _autoMoveRight(double dt) {
    // Двигаемся вправо с постоянной скоростью
    velocity.x = moveSpeed;
    position.x += velocity.x * dt;

    // Если достигли или превысили цель, останавливаем автоматическое движение
    if (position.x >= targetFinishPosition!) {
      _wasAutoMoved = true;
      _moveAuto = false;
      velocity.x = 0;
      _controlsEnabled = true;
    }
  }

  void _changeAnimation() {
    if (isOnGround) {
      current = velocity.x != 0 ? PlayerState.run : PlayerState.idle;
    } else {
      current = velocity.y < 0 ? PlayerState.jump : PlayerState.fall;
    }
  }

  void _changeSpriteScale() {
    if (velocity.x < 0 && scale.x > 0 || velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
  }

  void _jump(double dt) {
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    pressedJump = false;
  }

  void _applyGravity(double dt) {
    if (velocity.y < 0) {
      velocity.y += gravity * 0.7 * dt; // медленнее вверх
    } else {
      if (!_isDead) {
        velocity.y += gravity * 1.3 * dt; // быстрее вниз
      }
    }

    velocity.y = velocity.y.clamp(-jumpForce, maxVelocity);
    position.y += velocity.y * dt;
  }

  void _checkIfFallFromScreen() {
    if (position.y + height >= game.cameraHeight) _die(false);
  }

  void _die(bool doJump) {
    if (_isDead) return;
    _isDead = true;
    _controlsEnabled = false;
    velocity.x = 0;
    isOnGround = false;
    if (doJump) velocity.y = -300;
    Future.delayed(Duration(seconds: 1), () {
      game.onPlayerDeath();
    });
  }

  void _exitFromLevel() {
    game.onLevelFinished();
  }
}
