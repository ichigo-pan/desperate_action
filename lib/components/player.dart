import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:desperate_action/components/platform.dart';
import 'package:desperate_action/utils/mixins/aabb_collision.dart';
import 'package:desperate_action/components/ground_enemy.dart';
import 'package:desperate_action/components/jumping_enemy.dart';
import 'package:desperate_action/components/collision_blocks.dart';

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

  int xMovement = 0;
  bool pressedJump = false;
  bool isOnGround = false;

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

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateMovements(dt);
    if (!isOnGround) _applyGravity(dt);
    _changeSpriteScale();
    _changeAnimation();
    _checkIfFallFromScreen();
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is CollisionBlocks || other is Platform) {
      // Получаем хитбокс игрока (должен быть добавлен как RectangleHitbox)
      final myHitbox = children.whereType<RectangleHitbox>().first;
      // Получаем хитбокс другого объекта (предполагаем, что он есть)
      final otherHitbox = other.children
          .whereType<RectangleHitbox>()
          .firstOrNull;
      if (otherHitbox == null) return;

      // Используем метод миксина для определения нормали столкновения
      final normal = calculateNormal(other);
      if (normal == Vector2.zero()) return; // нет реального пересечения

      // Вычисляем актуальные перекрытия по осям на основе абсолютных координат
      final myRect = myHitbox.toAbsoluteRect();
      final otherRect = otherHitbox.toAbsoluteRect();

      final overlapX =
          min(myRect.right, otherRect.right) - max(myRect.left, otherRect.left);
      final overlapY =
          min(myRect.bottom, otherRect.bottom) - max(myRect.top, otherRect.top);

      // Разделяем объекты по направлению нормали
      if (normal.x != 0) {
        // Горизонтальное столкновение – смещаем игрока по X
        position.x += normal.x * overlapX;
        velocity.x = 0; // останавливаем горизонтальную скорость
      }
      if (normal.y != 0) {
        // Вертикальное столкновение – смещаем игрока по Y
        position.y += normal.y * overlapY;

        if (normal.y < 0) {
          // Столкновение снизу (игрок стоит на блоке)
          isOnGround = true;
          velocity.y = 0;
        } else if (normal.y > 0) {
          // Столкновение сверху (удар головой о блок)
          if (velocity.y < 0) velocity.y = 0; // гасим прыжок вверх
        }
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

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is GroundEnemy) {
      final normal = calculateNormal(other);
      if (normal.y < 0) {
        other.die();
        velocity.y = -_bounceHeight;
      } else {
        // ignore: avoid_print
        print('bonk!');
        _die();
      }
    }
    if (other is JumpingEnemy) {
      // ignore: avoid_print
      print('Air bonk!');
      _die();
    }
    if (other is Platform) {
      if (other.fallOnPlayer && other.velocity.y > 0) {
        _die();
      } else if (other.fallWithPlayer) {
        isOnGround = true;
      }
    }
  }

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
}
