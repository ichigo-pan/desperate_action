import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/overlays/game_over_overlay.dart';
import 'package:desperate_action/overlays/player_died_overlay.dart';
import 'package:desperate_action/overlays/start_game_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = DesperateAction();

  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        'StartGame': (context, DesperateAction game) =>
            StartGameOverlay(game: game),
        'PlayerDied': (context, DesperateAction game) =>
            PlayerDiedOverlay(game: game),
        'GameOver': (context, DesperateAction game) =>
            GameOverOverlay(game: game),
      },
      initialActiveOverlays: ['StartGame'],
    ),
  );
}
