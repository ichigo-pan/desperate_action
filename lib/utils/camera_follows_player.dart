import 'dart:async';
import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/components/player.dart';
import 'package:flame/components.dart';
import 'package:desperate_action/desperate_action.dart';

class CameraFollowSystem extends Component
    with HasGameReference<DesperateAction> {
  final Player player;
  CameraFollowSystem({required this.player});

  late double screenHalfWidth;
  static bool isMoving = false;

  @override
  FutureOr<void> onLoad() {
    screenHalfWidth = game.cameraWidth / 2;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final playerCenter = player.position.x + player.width / 2;
    final playerLeft = player.position.x - player.width * 1.5;
    final playerDir = player.scale.x;
    final camera = game.camera.viewfinder;
    final cameraCenter = camera.position.x + screenHalfWidth;
    isMoving = false;
    double? target;

    //проверить если середина игрока дошла до середины камеры --
    // координаты = середина игрока - половина экрана
    if (playerCenter > cameraCenter &&
        playerDir > 0 &&
        cameraCenter + screenHalfWidth < Level.mapSizeX) {
      target = playerCenter - screenHalfWidth;
    }
    // проверить если игрок находится в чуть левее чем камера от лева --
    // координаты = этой самой позиции игрока
    else if (playerLeft < camera.position.x &&
        camera.position.x > 0 &&
        playerDir < 0) {
      target = playerLeft;
    }

    if (target != null) {
      final newX = (target - camera.position.x) * 8 * dt;
      if (camera.position.x + newX > 0 &&
          camera.position.x + newX < Level.mapSizeX - game.cameraWidth &&
          newX.abs() > 0.1) {
        camera.position += Vector2(newX, 0);
        isMoving = true;
      }
    }
  }
}
