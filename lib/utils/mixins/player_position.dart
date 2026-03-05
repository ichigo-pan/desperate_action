import 'package:desperate_action/components/player.dart';

mixin PlayerPosition {
  double returnPlayerPositionX(Player player) {
    return player.scale.x > 0
        ? player.position.x + player.hitbox.positionX + player.hitbox.width / 3
        : player.position.x - player.hitbox.positionX - player.hitbox.width / 3;
  }
}
