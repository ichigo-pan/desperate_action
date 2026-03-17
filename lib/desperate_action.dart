import 'dart:async';
import 'dart:ui';
import 'package:desperate_action/components/checkpoints/finish.dart';
import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/utils/camera_manager.dart';
import 'package:desperate_action/utils/game_state.dart';
import 'package:desperate_action/utils/level_manager.dart';
import 'package:desperate_action/utils/overlay_manager.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum Overlays { playerDied, gameOver }

class DesperateAction extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final GameState state;
  late final LevelManager levelManager;
  late final CameraManager cameraManager;
  late final OverlayManager overlayManager;

  late Player player;

  final double cameraWidth = 500;
  final double cameraHeight = 450;

  @override
  Color backgroundColor() {
    return Color(0xFFbaebff);
  }

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    state = GameState();
    levelManager = LevelManager(this);
    cameraManager = CameraManager(this);
    overlayManager = OverlayManager(this);

    await images.loadAllImages();
    await levelManager.loadLevel('level-1');
    await cameraManager.initialize();

    overlays.add('StartGame');

    return super.onLoad();
  }

  void onPlayerDeath() {
    state.decreaseLife();
    overlayManager.show('PlayerDied');
    restartAfterOverlay(false, 'PlayerDied');
  }

  void onLevelFinished() {
    overlayManager.show('GameOver');
  }

  void restartAfterOverlay(
    bool completeRestart,
    String overlay, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _reloadLevelAndPlayer(completeRestart);
    Finish.checkedOnFinish = false;
    Future.delayed(duration, () {
      overlayManager.hide(overlay);
      state.gameStarted = true;
    });
  }

  void _reloadLevelAndPlayer(bool completeRestart) async {
    await levelManager.reload(completeRestart);
    await cameraManager.resetIfNeeded();
  }
}
