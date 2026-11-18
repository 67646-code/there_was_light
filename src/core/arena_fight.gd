class_name ArenaFight
extends RefCounted
## Combat complet du prototype : le duel (logique de combat), les déplacements dans l'arène et
## le retour d'impact qui change le déroulement (gel, recul). Une image = une commande
## ChildInput, même pendant un gel : c'est l'unité à enregistrer et à rejouer.

## Un événement de combat demande un retour (tremblement, son) à la couche jeu.
signal impact(kind: StringName, fx: ImpactFeedback)

var duel: Duel
var motion: ArenaMotion
var child_settings: ChildSettings
var feedback: FeedbackSettings
## Images de gel restantes : le combat ne progresse pas.
var hitstop_remaining: int = 0

var _move: int = 0


func _init(
	child: ChildSettings,
	boss: BossData,
	arena: ArenaSettings,
	rng_seed: int,
	feedback_settings: FeedbackSettings = null,
) -> void:
	child_settings = child
	feedback = feedback_settings if feedback_settings != null else FeedbackSettings.new()
	motion = ArenaMotion.new(arena)
	duel = Duel.new(child, boss, rng_seed)
	var c := duel.child
	c.dodged.connect(_on_child_dodged)
	c.perfect_parried.connect(_emit_impact.bind(&"perfect_parry"))
	c.guarded.connect(_emit_impact.bind(&"guard"))
	c.whiffed.connect(_emit_impact.bind(&"whiff"))
	c.hurt.connect(_on_child_hurt)
	c.guard_broken.connect(_emit_impact.bind(&"guard_break"))
	c.released.connect(_on_child_released)
	duel.dog.impact_started.connect(_on_dog_impact_started)
	duel.dog.posture_broken.connect(_on_dog_posture_broken)
	duel.dog.phase_changed.connect(_on_dog_phase_changed)
	duel.dog.pacified.connect(_emit_impact.bind(&"soothe"))


func tick(controller: ChildInput) -> void:
	if duel.is_over:
		return
	if hitstop_remaining > 0:
		hitstop_remaining -= 1
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


## Le chien doit-il flasher (signal de parade) à cette image ?
func parry_cue_active() -> bool:
	var dog := duel.dog
	if not feedback.parry_cue_enabled or dog.state != DogBoss.State.WINDUP:
		return false
	var lead: int = mini(feedback.parry_cue_lead_frames, dog.current_windup())
	var remaining: int = dog.frames_to_impact()
	return remaining <= lead and remaining > lead - feedback.parry_cue_frames


## État résumé, pour vérifier qu'une relecture retombe exactement au même endroit.
func summary() -> Dictionary:
	var child := duel.child
	var dog := duel.dog
	return {
		"duel_frame": duel.frame,
		"over": duel.is_over,
		"child_state": ChildCombat.State.keys()[child.state],
		"child_health": child.health,
		"child_oil": child.oil(),
		"child_light": child.light,
		"dog_state": DogBoss.State.keys()[dog.state],
		"dog_phase": dog.phase,
		"dog_posture": dog.posture.value(),
		"child_x": snappedf(motion.child_x, 0.01),
		"dog_x": snappedf(motion.dog_x, 0.01),
	}


func fx_for(kind: StringName) -> ImpactFeedback:
	var fx := feedback.get(kind) as ImpactFeedback
	return fx if fx != null else ImpactFeedback.new()


func _child_speed_factor() -> float:
	match duel.child.state:
		ChildCombat.State.STUNNED, ChildCombat.State.DEAD, ChildCombat.State.RELEASE_WINDUP:
			return 0.0
		ChildCombat.State.PARRY_WINDOW, ChildCombat.State.GUARD:
			return child_settings.advance_speed_factor
	return 1.0


func _dog_frozen() -> bool:
	return duel.dog.state == DogBoss.State.BROKEN or duel.dog.state == DogBoss.State.PACIFIED


## Applique le gel et le recul d'un événement, puis prévient la couche jeu.
func _emit_impact(kind: StringName) -> void:
	var fx := fx_for(kind)
	hitstop_remaining = maxi(hitstop_remaining, fx.hitstop_frames)
	motion.knock_child(fx.child_knockback, fx.knockback_frames)
	if not _dog_frozen():
		motion.knock_dog(fx.dog_knockback, fx.knockback_frames)
	impact.emit(kind, fx)


func _on_child_hurt(_health: int) -> void:
	_emit_impact(&"hurt")


func _on_child_released(_posture: int) -> void:
	if duel.last_in_range():
		_emit_impact(&"release")


func _on_dog_posture_broken(_phase: int) -> void:
	_emit_impact(&"posture_break")


func _on_dog_phase_changed(_phase: int) -> void:
	_emit_impact(&"soothe")


func _on_child_dodged() -> void:
	motion.start_dodge(_move)


func _on_dog_impact_started(attack: AttackData, _hit_index: int) -> void:
	if attack.ranged:
		# Atterrit à mi-impact, pour que le coup porte pendant les images actives.
		motion.start_leap(attack.active_frames / 2)
