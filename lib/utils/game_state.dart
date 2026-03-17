import 'package:flame/components.dart';

class GameState {
  int playerLives = 3;
  bool gameStarted = false;

  final Map<int, Vector2> checkpoints = {};

  void reset() {
    playerLives = 3;
    gameStarted = false;
  }

  void decreaseLife() {
    playerLives--;
  }
}
