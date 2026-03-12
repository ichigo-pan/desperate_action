import 'dart:async';
import 'package:desperate_action/components/bgAndHUD/hud.dart';
import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/utils/camera_follows_player.dart';
import 'package:desperate_action/components/bgAndHUD/parallax_bg.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum Overlays { playerDied, gameOver }

class DesperateAction extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  int playerLifes = 3;
  int? lastCheckpointId;
  bool gameStarted = false;
  static final Map<int, Vector2> checkpoints = {};

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
    overlays.add('StartGame');

    return super.onLoad();
  }

  void _openOverlay(String name) {
    overlays.add(name);
    pauseEngine();
  }

  void addParallaxBackground() {
    final background = BackgroundImg(player: player);
    background.priority = -3;
    camera.backdrop.add(background);
  }

  Future<void> _loadLevel(String levelName) async {
    player = Player();
    world = Level(
      levelName: levelName,
      player: player,
      lastCheckpointId: lastCheckpointId,
    );
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

  void _updateScore() {
    playerLifes -= 1;
  }

  void playerDied() {
    _updateScore();
    score.updateLifeCount(playerLifes);
    _openOverlay('PlayerDied');
    Future.delayed(Duration(seconds: 4), () {
      restartGameEngine(false, 'PlayerDied');
    });
  }

  void exitLevel() {
    _openOverlay('GameOver');
  }

  void resetComplitly() {
    // for brand new Level
    playerLifes = 3;
    lastCheckpointId = null;
  }

  void restartGameEngine(bool completeRestart, String overlay) {
    Future.delayed(Duration(milliseconds: 40), () {
      _restartGameSycle(completeRestart);
      overlays.remove(overlay);
      resumeEngine();
    });
  }

  void _restartGameSycle(bool completeRestart) async {
    player.removeFromParent();
    world.removeFromParent();
    checkpoints.clear();
    if (completeRestart) resetComplitly();
    await _loadLevel('level-1');
    await player.loaded;
    if (lastCheckpointId == null) {
      camera.removeFromParent();
      await _loadCamera();
    } else {
      camera.viewfinder.position = Vector2(player.position.x - 30, 0);
    }
  }
}
