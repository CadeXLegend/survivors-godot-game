# Damage System Architecture - Diagrams

## Overview

```mermaid
graph TB
    Q["Quantity<br/>Resource"] --> D["Damageable<br/>Node"]
    M["Damager<br/>Node"] --> D
```

## Quantity

```mermaid
classDiagram
    class Quantity {
        +float minimum
        +float maximum
        +float current
        +add(value)
        +remove(value)
    }
```

## Damageable

```mermaid
classDiagram
    class Damageable {
        +Node target
        +Quantity health
        +try_get_damagers_2d(nodes)
    }
```

## Damager

```mermaid
classDiagram
    class Damager {
        +Quantity damage
        +deal_damage(amount, stat, target)
    }
```

## Flow

```mermaid
flowchart TD
    Damager -->|"deal_damage"| Pre
    Pre["pre_damage_step.emit"]
    Pre -->|"remove"| R["stat.current -= amount"]
    R --> Check{useDamageNumbers?}
    Check -->|Yes| Display["Show damage number"]
    Check -->|No| Skip
    Display --> Post["post_damage_step.emit"]
    Skip --> Post
    
    R --> Q["Quantity"]
    Q --> AtMin{At minimum?}
    AtMin -->|Yes| NL["none_left.emit"]
    AtMin -->|No| L["lost.emit"]
```

## Quantity Events

```mermaid
flowchart LR
    Q["Quantity"] -->|"signal"| G["gained"]
    Q -->|"signal"| L["lost"]
    Q -->|"signal"| N["none_left"]
    Q -->|"signal"| F["full"]
```

## Damage Mechanics

### DamageOnBodyEntered2D

```mermaid
flowchart TD
    P["_physics_process delta"] --> B["get_overlapping_bodies"]
    B --> F["try_get_damageables nodes"]
    F --> C{Any found?}
    C -->|No| R["return"]
    C -->|Yes| L["For each damageable"]
    L --> D["deal_damage<br/>damager.damage.current<br/>damageable.health<br/>damageable.target"]
    D --> Q["queue_free"]
```

### LinearForwardMovement2D

```mermaid
flowchart TD
    P["_physics_process delta"] --> C{"withCleanup and<br/>bodies > 0"}
    C -->|Yes| D["Apply damage<br/>queue_free"]
    C -->|No| M["Move position<br/>direction * speed * delta"]
    M --> Dist["Update distance traveled"]
```

### SurvivorLikeProximityDamager

```mermaid
flowchart TD
    P["_physics_process delta"] --> B["hitbox<br/>get_overlapping_bodies"]
    B --> F["Filter for<br/>Mobs group"]
    F --> C{Size > 0?}
    C -->|No| R["return"]
    C -->|Yes| F2["try_get_damagers_2d nodes"]
    F2 --> L["For each damager"]
    L --> D["deal_damage<br/>damager.damage.current<br/>damageable.health<br/>recipientNode"]
```

