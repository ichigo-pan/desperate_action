import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/player_died_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // final DesperateAction game = DesperateAction();
  runApp(
    GameWidget(
      game: DesperateAction(),
      overlayBuilderMap: {
        'PlayerDied': (context, DesperateAction game) => PlayerDiedOverlay(),
      },
    ),
  );
}
