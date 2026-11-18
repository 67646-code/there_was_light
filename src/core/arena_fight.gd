class_name ArenaFight
extends RefCounted
## Combat complet du prototype : le duel (logique de combat) et les déplacements dans l'arène.
## Une image = une commande ChildInput : c'est l'unité à enregistrer et à rejouer.

var duel: Duel
var motion: ArenaMotion
var child_settings: ChildSettings

var _move: int = 0


func _init(child: ChildSettings, boss: BossData, arena: ArenaSettings, rng_seed: int) -> void:
	child_settings = child
	motion = ArenaMotion.new(arena)
	duel = Duel.new(child, boss, rng_seed)
	duel.child.dodged.connect(_on_child_dodged)
	duel.dog.impact_started.connect(_on_dog_impact_started)


func tick(controller: ChildInput) -> void:
	if duel.is_over:
		return
	var input: ChildInput = controller.copy()
	_move = input.move
	input.advancing = duel.child.is_lantern_raised() and motion.moves_toward_dog(input.move)
	var in_range: bool = motion.can_hit(duel.dog.attack)
	duel.tick(input, in_range, motion.is_far())
	motion.tick_child(input, _child_speed_factor())
	var dog := duel.dog
	var approaching: bool = (
		dog.state == DogBoss.State.RECOVERY
		or (dog.state == DogBoss.State.WINDUP and not dog.attack.ranged)
	)
	var pushed: bool = duel.child.is_pushing() and motion.distance() <= motion.settings.hit_range
	motion.tick_dog(approaching and not _dog_frozen(), pushed and not _dog_frozen())


func _child_speed_factor() -> float:
	match duel.child.state:
		ChildCombat.State.STUNNED, ChildCombat.State.DEAD, ChildCombat.State.RELEASE_WINDUP:
			return 0.0
		ChildCombat.State.PARRY_WINDOW, ChildCombat.State.GUARD:
			return child_settings.advance_speed_factor
	return 1.0


func _dog_frozen() -> bool:
	return duel.dog.state == DogBoss.State.BROKEN or duel.dog.state == DogBoss.State.PACIFIED


func _on_child_dodged() -> void:
	motion.start_dodge(_move)


func _on_dog_impact_started(attack: AttackData, _hit_index: int) -> void:
	if attack.ranged:
		# Atterrit à mi-impact, pour que le coup porte pendant les images actives.
		motion.start_leap(attack.active_frames / 2)
