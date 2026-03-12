import 'dart:async';
import 'package:desperate_action/desperate_action.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hud extends PositionComponent with HasGameReference<DesperateAction> {
  final headSprite = SpriteComponent();
  late final TextComponent lifeCount;

  @override
  FutureOr<void> onLoad() async {
    headSprite.sprite = await game.loadSprite('Player/head.png');
    lifeCount = TextComponent(
      text: '${game.playerLifes}',
      anchor: Anchor.topLeft,
      priority: 10,

      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          color: Colors.pink[200],
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
    add(headSprite);
    add(lifeCount);
    headSprite.position = Vector2(0, headSprite.height / 3);
    lifeCount.position = Vector2(25, 0);
    return super.onLoad();
  }

  void updateLifeCount(int lifes) {
    lifeCount.text = '$lifes';
  }
}
