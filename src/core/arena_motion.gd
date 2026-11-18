class_name ArenaMotion
extends RefCounted
## Déplacements dans l'arène plate, image par image : marche, saut, esquive, approche et bond
## du chien, poussée de la lanterne. Hauteur comptée vers le haut depuis le sol (0).

const FRAME_RATE: float = 60.0

var settings: ArenaSettings
var child_x: float = 0.0
var child_height: float = 0.0
var dog_x: float = 0.0

var _child_vertical_speed: float = 0.0
var _dodge_frames_left: int = 0
var _dodge_dir: float = 0.0
var _leap_frames_left: int = 0
var _leap_step: float = 0.0
var _prev_jump: bool = false


func _init(arena: ArenaSettings) -> void:
	settings = arena
	child_x = arena.child_start_x
	dog_x = arena.dog_start_x


## 1 si le chien est à droite de l'enfant, -1 sinon. L'enfant fait toujours face au chien.
func facing() -> float:
	return 1.0 if dog_x >= child_x else -1.0


func distance() -> float:
	return absf(dog_x - child_x)


func is_far() -> bool:
	return distance() > settings.far_distance


func is_airborne() -> bool:
	return child_height > 0.0


## L'attaque peut-elle toucher l'enfant ? Un saut assez haut passe au-dessus des attaques
## « devant ».
func can_hit(attack: AttackData) -> bool:
	if distance() > settings.hit_range:
		return false
	if attack != null and attack.parry_direction == CombatTypes.Direction.FRONT:
		return child_height <= settings.jump_clear_height
	return true


## L'enfant avance-t-il vers le chien avec cette commande ?
func moves_toward_dog(move: int) -> bool:
	return move != 0 and signf(move) == facing()


func start_dodge(move: int) -> void:
	_dodge_dir = signf(move) if move != 0 else -facing()
	_dodge_frames_left = settings.dodge_move_frames


## Le bond du chien : il rejoint l'enfant pendant `frames` images.
func start_leap(frames: int) -> void:
	var target: float = child_x - facing() * settings.min_separation
	_leap_frames_left = maxi(frames, 1)
	_leap_step = (target - dog_x) / _leap_frames_left


## Déplace l'enfant. `speed_factor` : 1 normal, réduit lanterne tendue, 0 immobilisé.
func tick_child(input: ChildInput, speed_factor: float) -> void:
	var can_move: bool = speed_factor > 0.0
	if _dodge_frames_left > 0:
		_dodge_frames_left -= 1
		child_x += _dodge_dir * settings.dodge_speed / FRAME_RATE
	elif can_move:
		child_x += input.move * settings.child_speed * speed_factor / FRAME_RATE
	if can_move and input.jump and not _prev_jump and not is_airborne():
		_child_vertical_speed = settings.jump_velocity
	_prev_jump = input.jump
	_child_vertical_speed -= settings.gravity / FRAME_RATE
	child_height += _child_vertical_speed / FRAME_RATE
	if child_height <= 0.0:
		child_height = 0.0
		_child_vertical_speed = 0.0
	_clamp()


## Déplace le chien. `approaching` : il marche vers l'enfant ; `pushed` : la lanterne le repousse.
func tick_dog(approaching: bool, pushed: bool) -> void:
	if _leap_frames_left > 0:
		_leap_frames_left -= 1
		dog_x += _leap_step
	elif pushed:
		dog_x += facing() * settings.push_speed / FRAME_RATE
	elif approaching and distance() > settings.dog_approach_distance:
		var step: float = minf(
			settings.dog_walk_speed / FRAME_RATE, distance() - settings.dog_approach_distance
		)
		dog_x -= facing() * step
	_clamp()


func _clamp() -> void:
	var limit: float = settings.half_width
	dog_x = clampf(dog_x, -limit, limit)
	child_x = clampf(child_x, -limit, limit)
	# On ne traverse pas le chien au sol ; en l'air, on passe par-dessus.
	if not is_airborne() and distance() < settings.min_separation:
		var side: float = -facing()
		child_x = dog_x + side * settings.min_separation
		if absf(child_x) > limit:
			child_x = clampf(child_x, -limit, limit)
			dog_x = child_x - side * settings.min_separation
