class_name AttackData
extends Resource
## Une attaque de monstre : anticipation, impact, récupération. Valeurs dans data/attacks/.
## Une rafale enchaîne `hit_count` coups ; les coups suivants ont `interval_windup_frames`.

@export var id: StringName = &""
## Anticipation avant le premier impact.
@export var windup_frames: int = 0
@export var hit_count: int = 1
## Anticipation des coups suivants d'une rafale.
@export var interval_windup_frames: int = 0
## Durée de chaque impact.
@export var active_frames: int = 0
@export var recovery_frames: int = 0
## Direction de lanterne qui pare cette attaque ; une autre direction donne une garde.
@export var parry_direction: CombatTypes.Direction = CombatTypes.Direction.FRONT
## Attaque à distance : choisie quand l'enfant est loin.
@export var ranged: bool = false
@export var health_damage: int = 0


## Anticipation du coup `hit_index` (0 = premier), mise à l'échelle par `windup_percent`.
## Arrondi à l'entier le plus proche, moitiés vers le haut.
func windup_for_hit(hit_index: int, windup_percent: int = 100) -> int:
	var base: int = windup_frames if hit_index == 0 else interval_windup_frames
	return scale_frames(base, windup_percent)


## Durée totale de l'attaque en images.
func total_frames(windup_percent: int = 100) -> int:
	var total: int = recovery_frames
	for i: int in hit_count:
		total += windup_for_hit(i, windup_percent) + active_frames
	return total


static func scale_frames(frames: int, percent: int) -> int:
	return (frames * percent + 50) / 100
