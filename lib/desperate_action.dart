import 'dart:async';
import 'package:desperate_action/utils/hud.dart';
import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/components/player.dart';
import 'package:desperate_action/utils/camera_follows_player.dart';
import 'package:desperate_action/components/parallax_bg.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class DesperateAction extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  final score = Hud();
  final double cameraWidth = 800;
  final double cameraHeight = 450;

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    await images.loadAllImages();
    await _loadLevel('level-1');
    await _loadCamera();

    score.position = Vector2(20, 5);

    return super.onLoad();
  }

  void addParallaxBackground() {
    final background = BackgroundImg(player: player);
    background.priority = -3;
    camera.backdrop.add(background);
  }

  Future<void> _loadLevel(String levelName) async {
    player = Player();
    world = Level(levelName: levelName, player: player);
    add(world);
    world.add(CameraFollowSystem(player: player));
  }

  Future<void> _loadCamera() async {
    camera = CameraComponent.withFixedResolution(
      width: cameraWidth,
      height: cameraHeight,
      world: world,
      hudComponents: [score],
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    add(camera);
    addParallaxBackground();
  }

  void playerDied() {
    score.updateLifeCount();
    overlays.add('PlayerDied');
    pauseEngine();
    Future.delayed(Duration(seconds: 5), () {
      _restart();
      overlays.remove('PlayerDied');
      resumeEngine();
    });
  }

  void _restart() async {
    player.removeFromParent();
    world.removeFromParent();
    await _loadLevel('level-1');
    if (Level.lastCheckpointId == null) {
      camera.removeFromParent();
      await _loadCamera();
    }
  }
}
