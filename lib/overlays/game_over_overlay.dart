import 'package:desperate_action/desperate_action.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends StatefulWidget {
  final DesperateAction game;
  const GameOverOverlay({super.key, required this.game});
  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Image.asset('assets/images/Player/head.png', scale: 0.4),
                    SizedBox(width: 20),
                    Text(
                      '${widget.game.playerLifes}',
                      style: TextStyle(
                        fontSize: 68,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    widget.game.restartGameEngine(true, 'GameOver');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.pink[300],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Start Brand New',
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
