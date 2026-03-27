import 'dart:async';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/fallable.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends SpriteComponent
    with HasGameReference<DesperateAction>
    implements Fallable {
  final bool fallOnPlayer;
  final bool fallWithPlayer;
  final String spriteName;
  @override
  final int id;
  Platform({
    required super.position,
    required super.size,
    required super.priority,
    required this.id,
    required this.spriteName,
    required this.fallOnPlayer,
    required this.fallWithPlayer,
  });

  @override
  bool doFall = false;
  final double moveSpeed = 300;
  final Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('FallingPlatform/$spriteName.png'));
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (doFall) _fall(dt);
  }

  void _fall(double dt) {
    if (position.y > game.cameraHeight) removeFromParent();
    velocity.y = moveSpeed;
    position.y += velocity.y * dt;
  }
}
