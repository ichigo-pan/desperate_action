class GameState {
  int playerLives = 3;
  bool gameStarted = false;

  void reset() {
    playerLives = 3;
    gameStarted = false;
  }

  void decreaseLife() {
    playerLives--;
  }
}
