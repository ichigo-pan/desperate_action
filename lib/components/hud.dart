import 'dart:async';

import 'package:desperate_action/components/level.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hud extends PositionComponent with HasGameReference<DesperateAction> {
  final headSprite = SpriteComponent();
  final lifeCount = TextComponent(
    text: '${Level.playerLifes}',
    anchor: Anchor.topLeft,
    priority: 10,

    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 36,
        color: Colors.pink[200],
        fontWeight: FontWeight.bold,
        height: 1.0,
      ),
    ),
  );

  @override
  FutureOr<void> onLoad() async {
    headSprite.sprite = await game.loadSprite('Player/head.png');
    add(headSprite);
    add(lifeCount);
    headSprite.position = Vector2(0, headSprite.height / 3);
    lifeCount.position = Vector2(25, 0);
    return super.onLoad();
  }

  void updateLifeCount() {
    Level.playerLifes -= 1;
    lifeCount.text = '${Level.playerLifes}';
  }
}
