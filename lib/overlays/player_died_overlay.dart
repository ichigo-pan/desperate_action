import 'package:desperate_action/desperate_action.dart';
import 'package:flutter/material.dart';

class PlayerDiedOverlay extends StatefulWidget {
  final DesperateAction game;
  const PlayerDiedOverlay({super.key, required this.game});
  @override
  State<PlayerDiedOverlay> createState() => _PlayerDiedOverlayState();
}

class _PlayerDiedOverlayState extends State<PlayerDiedOverlay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Color(0xFFbaebff)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Image.asset('assets/images/Player/head.png', scale: 0.4),
                SizedBox(width: 20),
                Text(
                  '${widget.game.state.playerLives}',
                  style: TextStyle(
                    fontSize: 68,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
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
