import 'package:desperate_action/desperate_action.dart';

class OverlayManager {
  final DesperateAction game;

  OverlayManager(this.game);

  void show(String name) {
    game.overlays.add(name);
    game.pauseEngine();
  }

  void hide(String name) {
    game.overlays.remove(name);
    game.resumeEngine();
  }
}
