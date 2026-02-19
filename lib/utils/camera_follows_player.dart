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
      camera.position += Vector2((target - camera.position.x) * 8 * dt, 0);
    }
  }
}





























  //   final camera = game.camera.viewfinder;
  //   final cameraLeft = camera.position.x;
  //   // final cameraRight = camera.position.x + screenCenterX;

  //   final leftDeadzone = cameraLeft;
  //   final rightDeadzone = cameraLeft + screenCenterX;

  //   final playerLeft = player.position.x - player.width * 1.5;
  //   final playerRight = player.position.x + player.hitbox.width;

  //   double? targetX;

  //   // если игрок вышел за правую границу — двигаем камеру вправо
  //   if (playerRight > rightDeadzone) {
  //     targetX = playerRight - screenCenterX;
  //   }
  //   // если игрок вышел за левую границу — двигаем камеру влево
  //   else if (playerLeft < leftDeadzone) {
  //     targetX = playerLeft; // камера догоняет левый край игрока
  //   }

  //   if (targetX != null) {
  //     camera.position += Vector2((targetX - camera.position.x) * 8 * dt, 0);
  //   }
  // }