import 'package:desperate_action/components/bgAndHUD/parallax_bg.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:flame/components.dart';

class CameraManager {
  final DesperateAction game;

  CameraManager(this.game);

  Future<void> initialize() async {
    game.camera = CameraComponent.withFixedResolution(
      width: game.cameraWidth,
      height: game.cameraHeight,
      world: game.world,
    );

    game.camera.viewfinder.anchor = Anchor.topLeft;

    game.add(game.camera);
    _addParallax();
  }

  void _addParallax() {
    final background = BackgroundImg(player: game.player);
    background.priority = -3;
    game.camera.backdrop.add(background);
  }

  Future<void> resetIfNeeded() async {
    game.camera.removeFromParent();
    await initialize();
  }
}
