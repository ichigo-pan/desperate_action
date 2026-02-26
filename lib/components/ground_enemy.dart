import 'dart:async';
import 'package:desperate_action/components/collision_blocks.dart';
import 'package:desperate_action/components/platform.dart';
import 'package:desperate_action/components/player.dart';
import 'package:desperate_action/desperate_action.dart';
import 'package:desperate_action/utils/custom_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum GroundEnemyState {
  hit('Hit', 5),
  run('Run', 14);

  final String name;
  final int amount;
  const GroundEnemyState(this.name, this.amount);
}

class GroundEnemy extends SpriteAnimationGroupComponent
    with HasGameReference<DesperateAction>, CollisionCallbacks
    implements CustomHitboxesCollision {
  int moveDirection;

  GroundEnemy({
    required super.position,
    required super.size,
    required this.moveDirection,
  });

  final double moveSpeed = 30;
  final double gravity = 9.8;
  final Vector2 velocity = Vector2.zero();
  static final CustomRectangleHitboxSize headHitbox = CustomRectangleHitboxSize(
    positionX: 20,
    positionY: 5,
    width: 25,
    height: 4,
  );
  static final CustomRectangleHitboxSize sideHitbox = CustomRectangleHitboxSize(
    positionX: 20,
    positionY: 13,
    width: 5,
    height: 7,
  );
  static final CustomRectangleHitboxSize bottomHitbox =
      CustomRectangleHitboxSize(
        positionX: 38,
        positionY: 28,
        width: 5,
        height: 4,
      );
  bool startMoving = false;
  bool isOnGround = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    current = GroundEnemyState.run;
    addAll([
      CustomHitbox(
        side: HitboxSide.head,
        position: Vector2(headHitbox.positionX, headHitbox.positionY),
        size: Vector2(headHitbox.width, headHitbox.height),
        collisionType: CollisionType.passive,
      ),
      CustomHitbox(
        side: HitboxSide.side,
        position: Vector2(sideHitbox.positionX, sideHitbox.positionY),
        size: Vector2(sideHitbox.width, sideHitbox.height),
      ),
      CustomHitbox(
        side: HitboxSide.bottom,
        position: Vector2(bottomHitbox.positionX, bottomHitbox.positionY),
        size: Vector2(bottomHitbox.width, bottomHitbox.height),
      ),
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkWherePlayer();
    if (!isOnGround) {
      _applyGravity(dt);
    } else if (startMoving) {
      _move(dt);
    }
    _deleteIfFall();
    isOnGround = false;
  }

  void _checkWherePlayer() {
    final camera = game.camera.viewfinder;
    if (camera.position.x + game.cameraWidth >= position.x) startMoving = true;
  }

  void _loadAllAnimations() {
    animations = {
      GroundEnemyState.run: _loadAnimation(GroundEnemyState.run),
      GroundEnemyState.hit: _loadAnimation(GroundEnemyState.hit)..loop = false,
    };
    current = GroundEnemyState.run;
  }

  SpriteAnimation _loadAnimation(GroundEnemyState state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/onGround/${state.name} (64x32).png'),
      SpriteAnimationData.sequenced(
        amount: state.amount,
        stepTime: 0.05,
        textureSize: size,
      ),
    );
  }

  void _move(double dt) {
    velocity.x = -moveDirection * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _applyGravity(double dt) {
    velocity.y += gravity;
    position.y += velocity.y * dt;
  }

  void _deleteIfFall() {
    if (position.y > game.cameraHeight) removeFromParent();
  }

  void _die() async {
    current = GroundEnemyState.hit;
    await animationTicker?.completed;
    removeFromParent();
  }

  @override
  void handleCollision(
    HitboxSide side,
    ShapeHitbox other,
    CollisionPhase phase,
    CollisionCategory category,
  ) {
    // head collision with player
    if (other.parent is Player && phase == CollisionPhase.start) {
      if (side == HitboxSide.head) {
        _die();
      }
    }

    // side collisions
    if (side == HitboxSide.side) {
      if (phase == CollisionPhase.start &&
          category == CollisionCategory.solid) {
        moveDirection *= -1;
        flipHorizontallyAroundCenter();
        position.x += moveDirection > 0 ? -10 : 10;
      }
    }

    // bottom collisions
    if (side == HitboxSide.bottom) {
      if (phase == CollisionPhase.stay &&
          (category == CollisionCategory.solid ||
              category == CollisionCategory.platform)) {
        isOnGround = true;
      }
    }
  }
}



// 1️⃣ Разделение логики коллизий: “Hitbox vs Collider”

// Идея:

// Каждый объект имеет один или несколько hitbox’ов (геометрия для столкновений)

// И объект знает свою категорию (player, enemy, platform, projectile)

// Коллизия обрабатывается через систему коллайдеров, которая знает правила взаимодействия категорий

// Пример в платформерах:

// Игрок → хитбоксы: голова, туловище, ноги

// Враг → хитбоксы: корпус, атака

// Платформа → один хитбокс

// Система проверяет пересечение хитбоксов и вызывает нужный обработчик в зависимости от категорий и стороны столкновения

// Плюсы:

// Легко добавлять новые типы хитбоксов

// Не нужно дублировать код коллизий в каждом объекте

// Можно сделать слои коллизий (collision layers), как в Unity или Godot

// 2️⃣ Использование “Collision Layers & Masks”

// Что это:

// Каждая категория объекта имеет слой

// Указываются маски, с кем этот слой может сталкиваться

// Пример:

// Категория	Маска столкновений
// Player	Ground, Enemy, Platform
// Enemy	Player, Solid
// Projectile	Enemy, Solid

// Как работает:

// Когда хитбоксы пересекаются, проверяется сначала маска → если совпадает, вызывается обработка

// Если нет → пропускаем, не тратим ресурсы на коллизии

// Плюсы:

// Огромная оптимизация

// Легко контролировать, кто с кем может сталкиваться

// Используется в популярных движках: Unity 2D, Godot, Cocos2d

// 3️⃣ “Component-Based Collision” / Компонентная архитектура

// Идея:

// Каждый объект имеет HitboxComponent или ColliderComponent, который отдельно отвечает за коллизии

// Родитель объекта не хранит логику столкновения напрямую

// Логика “что делать при столкновении” вынесена в систему или компонент обработчик

// Пример:

// PlayerCollisionComponent знает, что делать при столкновении с платформой (наземный), головой (под потолок), боками (отталкивает)

// EnemyCollisionComponent знает, что делать при контакте с игроком

// CollisionSystem проверяет пересечения всех коллайдеров в сцене

// Плюсы:

// Чистый код

// Можно добавлять новые виды хитбоксов без переписывания родительского объекта

// Подходит для Entity Component System (ECS) архитектуры

// 4️⃣ “Custom Hitboxes per Action”

// Идея:

// У каждого объекта разные хитбоксы для разных состояний / действий

// Например:

// Прыжок → ноги расширены

// Атака → руки с мечом активны

// Стандарт → туловище, ноги

// Использование:

// Кастомные хитбоксы активируются только когда нужно

// Позволяет точно рассчитывать коллизии, не перегружая игру

// Популярно в:

// Платформерах как Celeste, Hollow Knight, Dead Cells

// 5️⃣ Универсальный подход в 2D платформерах (мой опыт)

// Если проектировать архитектуру с нуля, оптимально сочетать:

// Компоненты хитбоксов (HitboxComponent) для каждого объекта

// Категории + слои столкновений (CollisionLayer, CollisionMask)

// Систему обработки столкновений, которая умеет:

// Определять сторону столкновения (верх, низ, бок)

// Вызвать универсальный обработчик (handleCollision)

// Игнорировать коллизии, которые не нужны

// Поддержку кастомных хитбоксов (например CustomHitbox) без дублирования кода

// Оптимизацию: проверка столкновений только между нужными слоями

// Почему это работает:

// Можно добавлять новых врагов/игроков с любыми хитбоксами

// Можно смешивать кастомные хитбоксы и обычные прямоугольники

// Масштабируемо для большого количества объектов

// Если хочешь, я могу нарисовать схему архитектуры столкновений, где видно как Player, Enemy, Platform, CustomHitbox и RectangleHitbox взаимодействуют через универсальную систему. Это даст тебе полное понимание, как реализовать оптимально.

// Хочешь, чтобы я это сделал?

// да

// Отлично. Ниже — оптимальная архитектура системы коллизий для 2D платформера, которую используют в современных играх. Это гибкий, масштабируемый и производительный подход.

// 🧠 Общая концепция

// Архитектура строится из 4 уровней:

// GameObject (Player / Enemy / Platform)
//         ↓
// ColliderComponent (один или несколько)
//         ↓
// CollisionSystem (глобальная система)
//         ↓
// Collision Rules (layers + masks + resolution)
// 1️⃣ GameObject (Игрок, враг, платформа)

// Объект не проверяет коллизии сам.
// Он только:

// Имеет категорию (Player, Enemy, Solid, Platform)

// Имеет один или несколько ColliderComponent

// Реализует интерфейс вроде CollisionListener

// Пример логической структуры:
// Player
//  ├── BodyCollider
//  ├── FeetCollider
//  ├── HeadCollider
//  └── PlayerCollisionHandler

// Объект не знает, с кем он столкнётся.
// Он просто получает событие:

// onCollision(CollisionInfo info)
// 2️⃣ ColliderComponent (хитбоксы)

// Каждый коллайдер:

// Имеет форму (Rectangle, Circle, Polygon)

// Имеет CollisionLayer

// Имеет CollisionMask

// Имеет ссылку на владельца

// Важно:

// Коллайдер не содержит игровую логику.
// Он только хранит данные.

// 3️⃣ Collision Layers + Masks (как в Unity)

// Это ключевой момент профессиональной архитектуры.

// CollisionLayer — кто я
// CollisionMask — с кем я могу сталкиваться

// Пример таблицы:

// Layer	Collides With
// Player	Enemy, Solid, Platform
// Enemy	Player, Solid
// Platform	Player
// Projectile	Enemy, Solid

// Сначала система проверяет маски →
// если не совпадают — коллизия даже не считается.

// 🔥 Это даёт большую оптимизацию.

// 4️⃣ CollisionSystem (самое важное)

// Это глобальная система, которая:

// Собирает все коллайдеры сцены

// Делает broad-phase (грубая проверка по AABB)

// Делает narrow-phase (точная проверка)

// Определяет:

// факт столкновения

// сторону столкновения

// penetration depth

// Создаёт CollisionInfo

// Отправляет событие владельцам

// 5️⃣ CollisionInfo (универсальный объект столкновения)

// Он содержит:

// Collider A

// Collider B

// Owner A

// Owner B

// Normal (вектор направления)

// Side (top / bottom / left / right)

// Phase (start / stay / end)

// Объекты получают один универсальный объект, а не 10 разных методов.

// 6️⃣ Разрешение столкновения (Separation of Concerns)

// Важно разделить:

// A) Detection (обнаружение)
// B) Resolution (разрешение)

// Detection — CollisionSystem
// Resolution — либо PhysicsSystem, либо сам объект

// 7️⃣ Как определяют сторону столкновения в платформерах

// В 2D платформерах обычно:

// Проверяют penetration vector

// Или сравнивают previousPosition и currentPosition

// Или используют collision normal

// Пример логики:

// Normal (0, -1) → удар снизу → игрок приземлился

// Normal (0, 1) → удар головой

// Normal (1, 0) → удар слева

// Normal (-1, 0) → удар справа

// ❗ Это лучше, чем делать 3 отдельных хитбокса (head/side/bottom).
// Современные платформеры чаще используют один collider + анализ нормали.

// 8️⃣ Когда использовать несколько хитбоксов

// Множественные хитбоксы используют когда:

// Есть зона урона

// Есть зона атаки

// Есть триггер-зоны

// Нужно точное попадание по частям тела

// Пример:

// Enemy
//  ├── BodyCollider (solid)
//  ├── AttackCollider (damage)
//  └── VisionCollider (trigger)
// 9️⃣ Что популярно в современных 2D платформерах

// Большинство используют:

// ✅ Component-based architecture
// ✅ Collision layers + masks
// ✅ Single collider + collision normal
// ✅ Отдельный Physics / Collision system
// ✅ Event-based collision handling

// Так работают:

// Celeste

// Dead Cells

// Hollow Knight

// Ori

// Unity 2D проекты

// Godot 2D проекты

// 🔟 Лучшая архитектура для твоего случая

// Если перепроектировать:

// Убрать:

// Разные классы для head/side/bottom

// Сделать:

// Один ColliderComponent

// CollisionLayer + CollisionMask

// CollisionSystem

// CollisionInfo с normal

// Внутри Player:

// if (info.normal.y < 0) -> landing
// if (info.normal.y > 0) -> head bump
// if (info.normal.x != 0) -> side collision
// 🎯 Почему это лучше твоей текущей архитектуры
// Текущий подход	Новый подход
// Много хитбоксов	Один коллайдер
// Много методов	Один универсальный
// Жёсткая логика	Гибкая система
// Сложно масштабировать	Легко добавлять типы
// 🏆 Итог — самый оптимальный подход

// Если кратко:

// Component-based + CollisionSystem + Layers/Masks + Normal-based resolution

// Это:

// Самый масштабируемый

// Самый гибкий

// Самый производительный

// Самый популярный в 2D платформерах

// Если хочешь, дальше можем:

// разобрать, как правильно организовать CollisionSystem в Flame

// или сравнить normal-based vs multi-hitbox подход конкретно для твоей игры

// или я могу помочь спроектировать финальную архитектуру под твой проект

// Куда копаем глубже? 🚀