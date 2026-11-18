extends GutTest
## Retour d'impact dans ArenaFight : gel (hitstop), recul, événements pour la couche jeu.

const CHILD: String = "res://data/child_variant_b.tres"
const BOSS: String = "res://data/boss_dog.tres"
const ARENA: String = "res://data/arena.tres"
const FEEDBACK: String = "res://data/feedback.tres"

var fight: ArenaFight
var feedback: FeedbackSettings


func before_each() -> void:
	feedback = load(FEEDBACK) as FeedbackSettings
	fight = _fight_with(load(BOSS) as BossData, feedback)


func _until(predicate: Callable, limit: int = 60 * 30) -> void:
	for i: int in limit:
		if predicate.call():
			return
		fight.tick(ChildInput.new())


func test_feedback_file_is_complete() -> void:
	for kind: StringName in [
		&"perfect_parry",
		&"guard",
		&"whiff",
		&"hurt",
		&"guard_break",
		&"release",
		&"posture_break",
		&"soothe",
	]:
		assert_not_null(feedback.get(kind), "Retour manquant : %s" % kind)


func test_hurt_freezes_fight_then_resumes() -> void:
	var health := fight.duel.child.health
	_until(func() -> bool: return fight.duel.child.health < health)
	var frozen_at := fight.duel.frame
	var hitstop := feedback.hurt.hitstop_frames
	assert_eq(fight.hitstop_remaining, hitstop)
	for i: int in hitstop:
		fight.tick(ChildInput.new())
	assert_eq(fight.duel.frame, frozen_at, "Le combat ne progresse pas pendant le gel.")
	fight.tick(ChildInput.new())
	assert_eq(fight.duel.frame, frozen_at + 1)


func test_hurt_knocks_child_away_from_dog() -> void:
	var health := fight.duel.child.health
	_until(func() -> bool: return fight.duel.child.health < health)
	var distance := fight.motion.distance()
	for i: int in 30:
		fight.tick(ChildInput.new())
	assert_gt(fight.motion.distance(), distance)


func test_impact_signal_carries_feedback() -> void:
	watch_signals(fight)
	var health := fight.duel.child.health
	_until(func() -> bool: return fight.duel.child.health < health)
	assert_signal_emitted_with_parameters(fight, "impact", [&"hurt", feedback.hurt])


func test_perfect_parry_recoils_dog() -> void:
	# Coller le chien, puis parer au bon moment.
	_until(_about_to_bite_in_range)
	watch_signals(fight)
	for i: int in 4:
		fight.tick(ChildInput.make(true))
	assert_signal_emitted_with_parameters(
		fight, "impact", [&"perfect_parry", feedback.perfect_parry]
	)


func test_tone_has_expected_length() -> void:
	var wav := ImpactEffects.make_tone(440.0, 100)
	assert_eq(wav.data.size(), ImpactEffects.MIX_RATE / 10 * 2)


func _about_to_bite_in_range() -> bool:
	var dog := fight.duel.dog
	return (
		dog.state == DogBoss.State.WINDUP
		and fight.motion.distance() <= fight.motion.settings.hit_range
		and not dog.attack.ranged
		and dog.frames_to_impact() == 3
	)


func test_parry_cue_flashes_before_impact() -> void:
	# Morsure de 24 images : flash de 6 images, de 20 à 15 images avant l'impact.
	fight = _fight_with(_boss_with(load("res://data/attacks/dog_bite.tres") as AttackData))
	var cue_at: Array[int] = []
	while fight.duel.dog.state == DogBoss.State.WINDUP:
		if fight.parry_cue_active():
			cue_at.append(fight.duel.dog.frames_to_impact())
		fight.tick(ChildInput.new())
	assert_eq(cue_at, [20, 19, 18, 17, 16, 15])


func test_parry_cue_never_longer_than_windup() -> void:
	var a := AttackData.new()
	a.windup_frames = 10
	a.active_frames = 6
	a.recovery_frames = 30
	fight = _fight_with(_boss_with(a))
	assert_true(fight.parry_cue_active(), "Anticipation courte : flash dès le début.")


func test_parry_cue_can_be_disabled() -> void:
	fight.feedback = _cue_feedback(false)
	for i: int in 120:
		assert_false(fight.parry_cue_active())
		fight.tick(ChildInput.new())


func test_reacting_to_cue_lands_a_perfect_parry() -> void:
	# Appui 12 images (200 ms de réaction) après le début du flash → parade parfaite.
	fight.feedback = _cue_feedback(true)
	_until(_cue_starts_in_range)
	for i: int in 11:
		fight.tick(ChildInput.new())
	watch_signals(fight.duel.child)
	for i: int in 12:
		fight.tick(ChildInput.make(true, fight.duel.dog.attack.parry_direction))
	assert_signal_emitted(fight.duel.child, "perfect_parried")


func _fight_with(boss: BossData, fx: FeedbackSettings = _cue_feedback(true)) -> ArenaFight:
	return ArenaFight.new(load(CHILD) as ChildSettings, boss, load(ARENA) as ArenaSettings, 3, fx)


## Le chien avec une seule attaque en phase 1.
func _boss_with(attack: AttackData) -> BossData:
	var boss := (load(BOSS) as BossData).duplicate() as BossData
	boss.phase_1_attacks = [attack]
	return boss


func _cue_feedback(enabled: bool) -> FeedbackSettings:
	var f := (load(FEEDBACK) as FeedbackSettings).duplicate() as FeedbackSettings
	f.parry_cue_enabled = enabled
	return f


func _cue_starts_in_range() -> bool:
	var dog := fight.duel.dog
	return (
		fight.parry_cue_active()
		and dog.hit_index == 0
		and (
			dog.frames_to_impact()
			== mini(fight.feedback.parry_cue_lead_frames, dog.current_windup())
		)
		and fight.motion.distance() <= fight.motion.settings.hit_range
	)
