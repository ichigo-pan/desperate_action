import 'dart:async';
import 'package:desperate_action/components/collision_blocks.dart';
import 'package:desperate_action/components/ground_enemy.dart';
import 'package:desperate_action/components/jumping_enemy.dart';
import 'package:desperate_action/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'platform.dart';

// класс world - это специальный класс
// для инициализации мира, в котором всё и происходит
class Level extends World {
  final String levelName;
  late Player player;
  Level({required this.levelName, required this.player});

  late TiledComponent level;
  // поскольку эти переменные понадобятся нам в других классах,
  // и нет необходимости в этих других классах
  // создавать новые объекты класса level,
  // делаем эти переменные static
  static late int tileWidth;
  static late double mapSizeX;
  // сюда добавляем все блоки, по которым
  // игрок может двигаться и с которыми может сталкиваться
  // static final List<CollisionBlocks> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    // грузим background и получаем размеры карты, которые в дальнейшем используем
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(18));
    tileWidth = level.tileMap.map.tileWidth;
    mapSizeX = (level.tileMap.map.width * tileWidth).toDouble();
    level.priority = -1;
    add(level);
    // грузим блоки, по которым игрок может ходить
    // или с которыми может сталкиваться.
    // Нужно, чтобы игрок мог ходить, прыгать и падать
    _loadCollisionBlocks();
    // грузим всех персонажей - игрока,
    // врагов на земле, врагов в воздухе,
    // врагов выпрыгивающих
    _loadCharacters();
    _loadLuckyBlocks();
    _loadFallingPlatforms();
    return super.onLoad();
  }

  void _loadCollisionBlocks() {
    // выбираем нужный нам слой
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        final block = CollisionBlocks()
          ..position = collision.position
          ..size = collision.size;
        add(block);
      }
    }
  }

  void _loadCharacters() {
    // выбираем другой слой - Characters
    final charactersSpawnPointsLayer = level.tileMap.getLayer<ObjectGroup>(
      'Characters',
    );
    if (charactersSpawnPointsLayer != null) {
      // здесь проходимся по объектам в слое
      // и смотрим на их класс (который мы присвоили в Tiled).
      // После чего создаём объект нужного класса и передаём ему параметры
      for (final character in charactersSpawnPointsLayer.objects) {
        switch (character.class_) {
          // добавляем игрока
          case 'Player':
            player.position = character.position;
            player.size = character.size;
            player.scale.x = 1;
            add(player);
            break;
          case 'EnemyOnGround':
            final moveDirection = character.properties.getValue(
              'startDirection',
            );
            final groundEnemy = GroundEnemy(
              position: character.position,
              size: character.size,
              moveDirection: moveDirection,
            );
            groundEnemy.priority = -1;
            add(groundEnemy);
            break;
          case 'JumpingEnemy':
            final moveDirection = character.properties.getValue(
              'startDirection',
            );
            final jumpingEnemy = JumpingEnemy(
              position: character.position,
              size: character.size,
              moveDirection: moveDirection,
            );
            jumpingEnemy.priority = -2;
            add(jumpingEnemy);
            break;
        }
      }
    }
  }

  void _loadFallingPlatforms() {
    final fallingPlatformsLayer = level.tileMap.getLayer<ObjectGroup>(
      'FallingPlatforms',
    );

    if (fallingPlatformsLayer != null) {
      for (final object in fallingPlatformsLayer.objects) {
        switch (object.class_) {
          case 'Platform':
            final ignoreBottom = object.properties.getValue('ignoreBottom');
            final fallDown = object.properties.getValue('fallDown');
            final platform = Platform(
              position: object.position,
              size: object.size,
              ignoreBottom: ignoreBottom,
              fallDown: fallDown,
            );
            platform.priority = -2;
            add(platform);
            break;
        }
      }
    }
  }

  void _loadLuckyBlocks() {}
}
