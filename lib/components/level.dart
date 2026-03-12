import 'dart:async';
import 'package:desperate_action/components/checkpoints/checkpoint.dart';
import 'package:desperate_action/components/checkpoints/exit.dart';
import 'package:desperate_action/components/platformsAndBlocks/collision_blocks.dart';
import 'package:desperate_action/components/checkpoints/finish.dart';
import 'package:desperate_action/components/characters/ground_enemy.dart';
import 'package:desperate_action/components/platformsAndBlocks/invisible_blocks.dart';
import 'package:desperate_action/components/characters/jumping_enemy.dart';
import 'package:desperate_action/components/characters/player.dart';
import 'package:desperate_action/components/trigger.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'platformsAndBlocks/platform.dart';

// класс world - это специальный класс
// для инициализации мира, в котором всё и происходит
class Level extends World {
  final String levelName;
  final Player player;
  final int? lastCheckpointId;
  Level({
    required this.levelName,
    required this.player,
    required this.lastCheckpointId,
  });
  late TiledComponent level;
  // поскольку эти переменные понадобятся нам в других классах,
  // и нет необходимости в этих других классах
  // создавать новые объекты класса level,
  // делаем эти переменные static
  late int tileWidth;
  static late double mapSizeX;

  // static Vector2? lastCheckpointPosition;

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
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
    _loadAllCheckpoints();
    // грузим всех персонажей - игрока,
    // врагов на земле,
    // врагов выпрыгивающих
    _loadFallingPlatforms();
    _loadCharacters();
    _loadTriggers();
    return super.onLoad();
  }

  void _loadCollisionBlocks() {
    // выбираем нужный нам слой
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'InvisibleBlock':
            final block = InvisibleBlocks(
              position: collision.position,
              size: collision.size,
              spriteName: 'invisibleBlock',
            );
            add(block);
            break;
          default:
            final block = CollisionBlocks()
              ..position = collision.position
              ..size = collision.size;
            add(block);
            break;
        }
      }
    }
  }

  void _loadAllCheckpoints() {
    // выбираем нужный нам слой
    final checkpointsLayer = level.tileMap.getLayer<ObjectGroup>('Checkpoints');
    if (checkpointsLayer != null) {
      int id = 0;
      for (final flag in checkpointsLayer.objects) {
        switch (flag.class_) {
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: flag.position,
              size: flag.size,
              id: id,
            );
            if (lastCheckpointId == id) {
              checkpoint.isCurrentCheckpoint = true;
            }
            DesperateAction.checkpoints.addAll({id: flag.position});
            id += 1;
            checkpoint.priority = -1;
            add(checkpoint);
            break;

          case 'Finish':
            final finish = Finish(position: flag.position, size: flag.size);
            add(finish);
            break;
        }
      }
    }
  }

  Vector2? getLastCheckpointPlayerPosition() {
    final position = DesperateAction.checkpoints[lastCheckpointId];
    if (position != null) {
      return Vector2(position.x, position.y) + Vector2.all(64 / 3);
    }
    return null;
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
            final currentPlayerSpawnPosition =
                getLastCheckpointPlayerPosition() ?? character.position;
            player.position = currentPlayerSpawnPosition;
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
              id: character.id,
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
            final spriteName = object.properties.getValue('SpriteName');
            final fallOnPlayer = object.properties.getValue('fallOnPlayer');
            final fallWithPlayer = object.properties.getValue('fallWithPlayer');
            final platform = Platform(
              position: object.position,
              size: object.size,
              id: object.id,
              spriteName: spriteName,
              priority: 1,
              fallOnPlayer: fallOnPlayer,
              fallWithPlayer: fallWithPlayer,
            );
            add(platform);
            break;
        }
      }
    }
  }

  void _loadTriggers() {
    final triggersLayer = level.tileMap.getLayer<ObjectGroup>('Triggers');
    if (triggersLayer != null) {
      for (final object in triggersLayer.objects) {
        switch (object.class_) {
          case 'Trigger':
            final objectId = object.properties.getValue('objectId');
            final trigger = Trigger(
              position: object.position,
              size: object.size,
              objectId: objectId,
            );
            add(trigger);
            break;
          case 'Exit':
            final exit = Exit(position: object.position, size: object.size);
            add(exit);
        }
      }
    }
  }
}
