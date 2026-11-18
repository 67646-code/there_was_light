extends GutTest
## BossData : accès par phase et cohérence de data/boss_dog.tres.

const DOG: String = "res://data/boss_dog.tres"


func test_phase_accessors() -> void:
	var b := BossData.new()
	var a1 := AttackData.new()
	var a2 := AttackData.new()
	b.phase_1_attacks = [a1]
	b.phase_2_attacks = [a1, a2]
	b.phase_2_windup_percent = 80
	assert_eq(b.attacks_for_phase(1).size(), 1)
	assert_eq(b.attacks_for_phase(2).size(), 2)
	assert_eq(b.windup_percent_for_phase(1), 100)
	assert_eq(b.windup_percent_for_phase(2), 80)


func test_dog_is_coherent() -> void:
	var b := load(DOG) as BossData
	assert_not_null(b)
	if b == null:
		return
	assert_gt(b.max_posture, 0)
	assert_gt(b.break_stun_frames, 0)
	assert_gt(b.posture_regen_delay_frames, 0)
	for phase: int in range(1, b.phase_count() + 1):
		var attacks := b.attacks_for_phase(phase)
		assert_false(attacks.is_empty(), "Phase %d sans attaque" % phase)
		var has_close := false
		for a: AttackData in attacks:
			assert_not_null(a)
			if a != null and not a.ranged:
				has_close = true
		assert_true(has_close, "Phase %d sans attaque au contact" % phase)


func test_one_press_cannot_cover_two_impacts() -> void:
	# Deux impacts consécutifs doivent être plus espacés que la fenêtre de parade : sinon un
	# seul appui pourrait viser deux coups et la rafale perdrait son rythme.
	var b := load(DOG) as BossData
	var child := load("res://data/child_variant_b.tres") as ChildSettings
	for phase: int in range(1, b.phase_count() + 1):
		var percent := b.windup_percent_for_phase(phase)
		for a: AttackData in b.attacks_for_phase(phase):
			for i: int in a.hit_count:
				var gap: int = a.windup_for_hit(i, percent) + (a.active_frames if i > 0 else 0)
				assert_gt(
					gap, child.perfect_parry_window_frames, "%s coup %d phase %d" % [a.id, i, phase]
				)
