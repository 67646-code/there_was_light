class_name Duel
extends RefCounted
## Combat enfant contre chien, image par image. Relie les deux logiques : impacts du chien
## sur l'enfant, posture infligée par les parades et la relâche, poussée, apaisement.
## La couche jeu fournit les commandes et la géométrie (à portée, loin).

signal ended(child_won: bool)
## Lanterne levée sur le chien en brèche, mais l'enfant est hors de portée.
signal soothe_missed

var child: ChildCombat
var dog: DogBoss
var frame: int = 0
var is_over: bool = false

var _in_range: bool = false


func _init(child_settings: ChildSettings, boss_data: BossData, rng_seed: int) -> void:
	child = ChildCombat.new(child_settings)
	dog = DogBoss.new(boss_data, rng_seed)
	child.released.connect(_on_child_released)
	child.died.connect(_on_child_died)
	dog.pacified.connect(_on_dog_pacified)


## Avance d'une image. `in_range` : l'enfant est à portée des coups du chien (et de sa
## lanterne) ; `child_is_far` : assez loin pour que le chien choisisse une attaque à distance.
func tick(input: ChildInput, in_range: bool, child_is_far: bool) -> void:
	if is_over:
		return
	frame += 1
	_in_range = in_range
	# Le chien avance d'abord : un impact qui commence à cette image est résolu après les
	# commandes de l'enfant de la même image. La poussée lue est celle de l'image précédente.
	dog.tick(child_is_far, child.is_pushing() and in_range)
	child.tick(input)
	_resolve_hit()
	_try_soothe()


## L'enfant était-il à portée à cette image ?
func last_in_range() -> bool:
	return _in_range


func _resolve_hit() -> void:
	var attack: AttackData = dog.pending_hit()
	if attack == null or not _in_range or is_over:
		return
	dog.mark_hit_resolved()
	if child.receive_hit(attack) == ChildCombat.HitResult.PERFECT:
		dog.take_posture(child.settings.perfect_parry_posture)


func _try_soothe() -> void:
	# Lever la lanterne (nouvel appui) sur le chien en brèche l'apaise.
	if is_over or dog.state != DogBoss.State.BROKEN:
		return
	if child.state != ChildCombat.State.PARRY_WINDOW or child.state_elapsed() != 0:
		return
	if not _in_range:
		soothe_missed.emit()
	elif dog.soothe():
		child.consume_lantern_press()


func _on_child_released(posture_amount: int) -> void:
	if _in_range:
		dog.take_posture(posture_amount)


func _on_child_died() -> void:
	_end(false)


func _on_dog_pacified() -> void:
	_end(true)


func _end(child_won: bool) -> void:
	if is_over:
		return
	is_over = true
	ended.emit(child_won)
