import 'package:desperate_action/components/level.dart';
import 'package:flutter/material.dart';

class PlayerDiedOverlay extends StatefulWidget {
  const PlayerDiedOverlay({super.key});
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
            decoration: BoxDecoration(color: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Image.asset('assets/images/Player/head.png', scale: 0.4),
                SizedBox(width: 20),
                Text(
                  '${Level.playerLifes}',
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
