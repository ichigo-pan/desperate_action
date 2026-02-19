import 'dart:async';
import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/components/player.dart';

import 'package:desperate_action/utils/camera_follows_player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class DesperateAction extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final Player player = Player();
  final double cameraWidth = 900;
  final double cameraHeight = 450;

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    await images.loadAllImages();
    await _loadLevel('level-1');

    return super.onLoad();
  }

  Future<void> _loadLevel(String levelName) async {
    world = Level(levelName: levelName, player: player);
    camera = CameraComponent.withFixedResolution(
      width: cameraWidth,
      height: cameraHeight,
      world: world,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    addAll([world, camera]);
    world.add(CameraFollowSystem(player: player));
  }
}
