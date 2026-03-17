import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/camera_follows_player.dart';

class LevelManager {
  final DesperateAction game;

  LevelManager(this.game);

  Future<void> loadLevel(String levelName) async {
    game.player = Player();

    game.world = Level(
      levelName: levelName,
      player: game.player,
      state: game.state,
    );

    game.add(game.world);
    game.world.add(CameraFollowSystem(player: game.player));
  }

  Future<void> reload(bool fullReset) async {
    game.state.gameStarted = false;

    game.player.removeFromParent();
    game.world.removeFromParent();
    game.state.checkpoints.clear();

    if (fullReset) {
      game.state.reset();
    }

    await loadLevel('level-1');
    await game.player.loaded;
    await game.world.loaded;
  }
}
