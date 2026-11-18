class_name ArenaView
extends Node2D
## Dessine l'arène en rectangles : sol, enfant, lanterne, chien, santé et lumière.
## L'origine du nœud est le centre de l'arène, au niveau du sol.

const FLOOR_COLOR := Color(0.18, 0.2, 0.24)
const CHILD_COLOR := Color(0.85, 0.85, 0.9)
const CHILD_HURT_COLOR := Color(0.85, 0.85, 0.9, 0.35)
const CHILD_STUNNED_COLOR := Color(0.5, 0.5, 0.6)
const LANTERN_LOW := Color(0.45, 0.4, 0.2)
const LANTERN_WINDOW := Color(1.0, 0.95, 0.5)
const LANTERN_GUARD := Color(0.85, 0.7, 0.25)
const LANTERN_WHIFF := Color(0.4, 0.25, 0.25)
const DOG_IDLE := Color(0.4, 0.4, 0.45)
const DOG_TELL := Color(1.0, 0.55, 0.1)
const DOG_ACTIVE := Color(0.95, 0.15, 0.15)
const DOG_BROKEN := Color(0.55, 0.75, 1.0)
const DOG_PACIFIED := Color(1.0, 0.95, 0.7)
const DOG_CUE := Color(1.0, 1.0, 1.0)
const LIGHT_COLOR := Color(1.0, 0.95, 0.6)
const HEALTH_COLOR := Color(0.9, 0.3, 0.35)
const LANTERN_SIZE := Vector2(18, 18)
const RANGE_COLOR := Color(0.4, 0.9, 0.5, 0.18)
const FAR_COLOR := Color(0.95, 0.35, 0.35, 0.35)

var fight: ArenaFight
## Affiche la zone de portée et la limite « loin » autour du chien.
var show_debug: bool = false


func _draw() -> void:
	if fight == null:
		return
	var arena := fight.motion.settings
	draw_rect(Rect2(-arena.half_width, 0, arena.half_width * 2, 300), FLOOR_COLOR)
	if show_debug:
		_draw_ranges(arena)
	_draw_dog(arena)
	_draw_child(arena)
	_draw_pips()


func _draw_ranges(arena: ArenaSettings) -> void:
	# Zone verte : l'enfant y est à portée (coups du chien, relâche, apaisement).
	var dog_x := fight.motion.dog_x
	draw_rect(Rect2(dog_x - arena.hit_range, -260, arena.hit_range * 2, 260), RANGE_COLOR)
	for side: float in [-1.0, 1.0]:
		var far_x := dog_x + side * arena.far_distance
		draw_line(Vector2(far_x, -260), Vector2(far_x, 0), FAR_COLOR, 2.0)


func _draw_child(arena: ArenaSettings) -> void:
	var child := fight.duel.child
	var motion := fight.motion
	var size := arena.child_size
	var pos := Vector2(motion.child_x, -motion.child_height)
	var color := CHILD_COLOR
	if child.state == ChildCombat.State.STUNNED:
		color = CHILD_STUNNED_COLOR
	elif child.is_invulnerable() and child.frame % 6 < 3:
		color = CHILD_HURT_COLOR
	draw_rect(Rect2(pos - Vector2(size.x / 2, size.y), size), color)
	var offset := Vector2(motion.facing() * (size.x / 2 + 14), -size.y * 0.6)
	if child.is_lantern_raised():
		match child_direction():
			CombatTypes.Direction.UP:
				offset = Vector2(motion.facing() * size.x * 0.3, -size.y - 18)
			CombatTypes.Direction.DOWN:
				offset = Vector2(motion.facing() * (size.x / 2 + 14), -12)
	draw_rect(Rect2(pos + offset - LANTERN_SIZE / 2, LANTERN_SIZE), _lantern_color())


func _draw_dog(arena: ArenaSettings) -> void:
	var dog := fight.duel.dog
	var size := arena.dog_size
	var color := DOG_IDLE
	match dog.state:
		DogBoss.State.WINDUP:
			# Le chien rougit à mesure que l'impact approche.
			var progress := (
				1.0 - float(dog.frames_to_impact()) / float(maxi(dog.current_windup(), 1))
			)
			color = DOG_IDLE.lerp(DOG_TELL, clampf(progress, 0.0, 1.0))
		DogBoss.State.ACTIVE:
			color = DOG_ACTIVE
		DogBoss.State.BROKEN:
			color = DOG_BROKEN
		DogBoss.State.PACIFIED:
			color = DOG_PACIFIED
	if fight.parry_cue_active():
		color = DOG_CUE
	var rect := Rect2(Vector2(fight.motion.dog_x - size.x / 2, -size.y), size)
	draw_rect(rect, color)
	# Les attaques à parer vers le haut sont signalées par une bande au-dessus.
	if dog.state == DogBoss.State.WINDUP and dog.attack.parry_direction == CombatTypes.Direction.UP:
		draw_rect(Rect2(rect.position - Vector2(0, 14), Vector2(size.x, 8)), DOG_TELL)


func _draw_pips() -> void:
	var child := fight.duel.child
	var origin := Vector2(-fight.motion.settings.half_width, -460)
	for i: int in child.health:
		draw_rect(Rect2(origin + Vector2(i * 28, 0), Vector2(20, 20)), HEALTH_COLOR)
	for i: int in child.light:
		draw_rect(Rect2(origin + Vector2(i * 28, 30), Vector2(20, 20)), LIGHT_COLOR)


func child_direction() -> CombatTypes.Direction:
	return fight.duel.child.lantern_direction()


func _lantern_color() -> Color:
	match fight.duel.child.state:
		ChildCombat.State.PARRY_WINDOW:
			return LANTERN_WINDOW
		ChildCombat.State.GUARD:
			return LANTERN_GUARD
		ChildCombat.State.WHIFF_RECOVERY:
			return LANTERN_WHIFF
	return LANTERN_LOW
