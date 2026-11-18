class_name ArenaSettings
extends Resource
## Géométrie et déplacements de l'arène du prototype. Valeurs dans data/arena.tres.
## Distances en pixels, vitesses en pixels par seconde, durées en images.

@export_group("Arène")
@export var half_width: float = 0.0
@export var child_start_x: float = 0.0
@export var dog_start_x: float = 0.0
@export var child_size: Vector2 = Vector2.ZERO
@export var dog_size: Vector2 = Vector2.ZERO

@export_group("Enfant")
@export var child_speed: float = 0.0
@export var jump_velocity: float = 0.0
@export var gravity: float = 0.0
@export var dodge_speed: float = 0.0
@export var dodge_move_frames: int = 0
## Au-dessus de cette hauteur, les attaques « devant » passent sous l'enfant.
@export var jump_clear_height: float = 0.0

@export_group("Chien")
@export var dog_walk_speed: float = 0.0
## Le chien s'approche jusqu'à cette distance avant de mordre.
@export var dog_approach_distance: float = 0.0
## Vitesse à laquelle la lanterne tendue repousse le chien.
@export var push_speed: float = 0.0

@export_group("Distances")
## Distance minimale entre les centres : on ne traverse pas le chien.
@export var min_separation: float = 0.0
## Portée des coups du chien et de la lanterne (entre centres).
@export var hit_range: float = 0.0
## Au-delà, le chien choisit une attaque à distance.
@export var far_distance: float = 0.0
