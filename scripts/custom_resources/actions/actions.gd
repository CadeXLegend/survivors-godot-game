class_name Actions
extends Resource

enum Direction {UP, DOWN, LEFT, RIGHT, FORWARD, BACK, TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT}
@export var directions: Dictionary[Direction, InputActionBinding]

enum Movement { WALK, RUN, CROUCH, SWIM, SLIDE, JUMP, DASH, GRAPPLE, CLIMB, WALLCLIMB, GLIDE }
@export var movements: Dictionary[Movement, InputActionBinding]

enum Interaction { USE, PICKUP, INSPECT, TALK, OPEN, CLOSE, PUSH, PULL, THROW }
@export var interactions: Dictionary[Interaction, InputActionBinding]

enum Attack { SLASH, STAB, BLOCK, PARRY, THRUST, LUNGE, COUNTER, PUNCH, KICK, SWEEP }
@export var attacks: Dictionary[Attack, InputActionBinding] 

enum Inventory { EQUIP, DROP, CONSUME, SORT }
@export var inventory: Dictionary[Inventory, InputActionBinding]

enum MetaActions { INVENTORY, HELP, PAUSE, SAVE, LOAD, QUIT }
@export var metaActions: Dictionary[MetaActions, InputActionBinding]
