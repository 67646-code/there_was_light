extends GutTest
## Retour d'impact dans ArenaFight : gel (hitstop), recul, événements pour la couche jeu.

var fight: ArenaFight
var feedback: FeedbackSettings


func before_each() -> void:
	feedback = load("res://data/feedback.tres") as FeedbackSettings
	fight = ArenaFight.new(
		load("res://data/child_variant_b.tres") as ChildSettings,
		load("res://data/boss_dog.tres") as BossData,
		load("res://data/arena.tres") as ArenaSettings,
		3,
		feedback
	)


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
