# Compositional Game Framework - Feature Summary

This document summarizes the features provided by this compositional game framework built with Godot 4.x

## Overview

This framework uses **composition-driven development** where game entities are built from independent, composable systems rather than deep inheritance hierarchies

Each system contains its own states, stats/data, functions, and features necessary to operate independently

## Core Compositional Patterns

### NodeBuilder Pattern

A fluent API for declarative node creation and configuration

```gdscript
game_state_responder.spawn(mob)
    .at(position)
    .with_rotation(rotation)
    .as_child_of(parent)
    .in_group("Mobs")
    .create()
```

#### Features

- Fluent chainable API
- Deferred child addition
- Position, rotation, grouping configuration
- Scene instantiation and setup

### Actions System

A declarative input action binding system with run conditions

```gdscript
@export var actions: Actions
@export var movementSpeed: Quantity
@export var body: CharacterBody2D

# Run action with optional conditions
action.run(_implementation, optionalRunConditions)
```

#### Supported Action Types

- `Direction`: UP, DOWN, LEFT, RIGHT, FORWARD, BACK, TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT
- `Movement`: WALK, RUN, CROUCH, SWIM, SLIDE, JUMP, DASH, GRAPPLE, CLIMB
- `Interaction`: USE, PICKUP, INSPECT, TALK, OPEN, CLOSE, PUSH, PULL, THROW
- `Attack`: SLASH, STAB, BLOCK, PARRY, THRUST, LUNGE, COUNTER, PUNCH, KICK, SWEEP
- `Inventory`: EQUIP, DROP, CONSUME, SORT
- `MetaActions`: INVENTORY, HELP, PAUSE, SAVE, LOAD, QUIT

#### Features

- Signal-based action begin/end events
- Optional run conditions (e.g., check health, stun state)
- Input-agnostic binding

### Quantity System

A flexible stat management system with overflow handling and events

```gdscript
class_name Quantity
extends Resource

# Events
signal gained, lost, modified, none_left, full
signal maximum_increased, maximum_decreased
signal overflow_cleared, overflow_added

# Core Functions
func add(value: float, storeOverflow: bool = false) -> void
func remove(value: float) -> void
func set_to(value: float) -> void
func increase_max(value: float) -> void
func decrease_max(value: float) -> void
func add_from_overflow() -> void
```

#### Features

- Min/max/current tracking with overflow support
- Overflow storage and later application
- Event system for all stat changes
- Deep duplication for entity instances

#### QuantityVector2

Vector2 variant for 2D vector stat

```gdscript
class_name QuantityVector2
extends Resource

# For knockback, velocity, direction vectors
func add(value: Vector2) -> void
func remove(value: Vector2) -> void
func set_to(value: Vector2) -> void
```

## Entity Management

### GameStateResponder

Centralized game state management

```gdscript
class_name GameStateResponder
extends Node2D

func spawn(ref: PackedScene) -> NodeBuilder
func disable_self(ref: Node2D)
func disable_self_and_physics(ref: Node2D)
func enable_self(ref: Node2D)
func enable_self_and_physics(ref: Node2D)
```

#### Features

- Centralized spawning via NodeBuilder
- Process mode control (pause-aware)
- Damage numbers display integration

### GameEventsEmitter

Global game event system

```gdscript
class_name GameEventsEmitter
extends Node2D

signal game_paused
signal game_unpaused
signal magnet_picked_up

func pause_game()
func unpause_game()
func emit_magnet_picked_up()
```

#### Features

- Game pause/unpause with physics server control
- Pickup events
- Global signal hub for game-wide events

### EntityTracker

Entity discovery and tracking

```gdscript
class_name EntityTracker
extends Node

func player() -> Player
func enemies() -> Array[Node]
func find_nearest_enemy(ref: Node2D) -> Node2D
```

#### Features

- Player singleton access via group
- Enemy collection via group
- Nearest enemy finding

## Combat Systems

### Damageable

Health and damage reception system

```gdscript
class_name Damageable
extends Node

@export var target: Node
@export var health: Quantity
@export var damageableBy: Dictionary = {}

func try_get_damagers_2d(nodes: Array[Node2D]) -> Array[Damager]
func try_get_damager(node: Node) -> Damager
```

#### Features

- Health tracking via Quantity
- Script-based damageableBy filtering
- Damager detection in nodes/children
- Events: lost, none_left, modified

### Damager

Damage dealing system

```gdscript
class_name Damager
extends Node

@export var damage: Quantity
@export var useDamageNumbers: bool = true

signal pre_damage_step, post_damage_step
func deal_damage(amount: float, stat: Quantity, target: Node) -> void
```

#### Features

- Damage amount via Quantity
- Optional damage number display
- Damage step events
- Damageable detection

### DamageOnBodyEntered2D

Area-based damage on body entry

```gdscript
class_name DamageOnBodyEntered2D
extends Node

@export var area2d: Area2D
@export var damager: Damager
```

#### Features

- Trigger damage on overlapping bodies
- Self-destruct after damage execution
- Integration with Damageable/Damager

### SurvivorLikeProximityDamager

Survivor-like player damage from nearby enemies

```gdscript
class_name SurvivorLikeProximityDamager
extends Node

@export var hitbox: Area2D
@export var recipientNode: Node2D
@export var damageable: Damageable
```

#### Features

- Continuous proximity damage
- Mobs-only filtering
- Damage from multiple sources

## Movement Systems

### FreeMovementFourDirectional2D

```gdscript
class_name FreeMovementFourDirectional2D
extends Node

@export var actions: Actions
@export var movementSpeed: Quantity
@export var body: CharacterBody2D

var optionalRunConditions: Array[Callable]
var isInputBeingPressed: bool
var isVelocityAboveZero: bool
```

#### Features

- Input-based directional movement
- Optional run conditions (e.g., health check)
- Velocity and input state tracking
- Walk/Run movement types

### LinearForwardMovement2D

```gdscript
class_name LinearForwardMovement2D
extends Node
```

#### Features

- Constant direction movement
- Projectile trajectory

## Spawning and Loot

### Droptable

Loot table resource for drops

```gdscript
class_name Droptable
extends Resource

@export var drops: Array[PackedScene]

func drop(parent: Node2D)
func drop_at(position: Vector2, parent: Node2D)
func drop_chosen(chosen: int, parent: Node2D)
func drop_chosen_at(position: Vector2, chosen: int, parent: Node2D)
```

#### Features

- Multiple drop types
- Position-specific drops
- Random selection support

### SpawnerOutsideView

Spawn mobs outside camera view

```gdscript
class_name SpawnerOutsideView
extends Node2D

@export var mob: PackedScene
func spawn_mob()
```

#### Features

- PathFollow2D-based spawn position
- Group assignment ("Mobs")
- Timer-based spawning

### Loot Drops

Specialized loot types

- **Coin** - Currency pickups
- **Corpse** - Death remains for spawning
- **Magnet** - Item attraction

```gdscript
class_name Loot
extends Node2D

@export var Item: Node2D
```

## Environment

### InfiniteTilingSet

Camera-following infinite tile system

```gdscript
class_name InfiniteTilingSet
extends Node2D
```

#### Features

- Follows player with smoothing
- Slerp-based interpolation
- Distance threshold for updates

## Utilities

### DamageNumbers

Floating damage number display

```gdscript
class_name DamageNumbers
extends Resource

func display_number(value: float, position: Vector2, receiver: Node, 
                   isCritical: bool = false, isOverflow: bool = false)
```

#### Features

- Multiple damage types: normal, critical, overflow, no-damage
- Tween-based animation (float up + scale down)
- Label settings customization
- Pause-aware display

### TerminateAtDistance

Distance-based entity termination

```gdscript
class_name TerminateAtDistance
extends Node

@export var target: Node
@export var distance: Quantity
```

#### Features

- Distance tracking via Quantity
- Auto-cleanup when threshold reached
- Good for projectile cleanup
