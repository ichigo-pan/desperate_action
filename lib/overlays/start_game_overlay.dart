import 'package:desperate_action/desperate_action.dart';
import 'package:flutter/material.dart';

class StartGameOverlay extends StatefulWidget {
  final DesperateAction game;
  const StartGameOverlay({super.key, required this.game});
  @override
  State<StartGameOverlay> createState() => _StartGameOverlayState();
}

class _StartGameOverlayState extends State<StartGameOverlay> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () {
          widget.game.restartGameEngine(false, 'StartGame');
          widget.game.gameStarted = true;
        },
        style: FilledButton.styleFrom(backgroundColor: Colors.pink[300]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Start',
            style: TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
