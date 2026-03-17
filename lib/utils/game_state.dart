import 'package:flame/components.dart';

class GameState {
  int playerLives = 3;
  int? lastCheckpointId;
  bool gameStarted = false;

  final Map<int, Vector2> checkpoints = {};

  void reset() {
    playerLives = 3;
    lastCheckpointId = null;
    checkpoints.clear();
    gameStarted = false;
  }

  void decreaseLife() {
    playerLives--;
  }
}
