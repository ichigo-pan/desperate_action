import 'package:desperate_action/components/player.dart';

double returnPlayerPosition(Player player) {
  return (player.scale.x > 0
      ? player.position.x +
            player.bottomHitbox.positionX +
            player.bottomHitbox.width
      : player.position.x -
            player.bottomHitbox.positionX -
            player.bottomHitbox.width);
}
