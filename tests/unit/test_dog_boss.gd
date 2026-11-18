extends GutTest
## DogBoss : rythme des attaques en images, phases, brèche, apaisement, déterminisme.

const S := DogBoss.State

var bite: AttackData
var burst: AttackData
var leap: AttackData


func before_each() -> void:
	bite = _attack(&"bite", 24, 1, 0, 6, 30, false)
	burst = _attack(&"burst", 20, 3, 14, 6, 40, false)
	leap = _attack(&"leap", 30, 1, 0, 8, 36, true)


func _attack(
	id: StringName, windup: int, hits: int, interval: int, active: int, recovery: int, far: bool
) -> AttackData:
	var a := AttackData.new()
	a.id = id
	a.windup_frames = windup
	a.hit_count = hits
	a.interval_windup_frames = interval
	a.active_frames = active
	a.recovery_frames = recovery
	a.ranged = far
	a.health_damage = 1
	return a


func _boss(phase_1: Array[AttackData], phase_2: Array[AttackData]) -> BossData:
	var b := BossData.new()
	b.max_posture = 100
	b.posture_regen_per_second = 10
	b.posture_regen_delay_frames = 120
	b.break_stun_frames = 120
	b.phase_1_attacks = phase_1
	b.phase_2_attacks = phase_2
	b.phase_2_windup_percent = 80
	return b


## Avance jusqu'à l'image `target` et renvoie les images où un impact a commencé.
func _run(dog: DogBoss, target: int, far: bool = false) -> Array[int]:
	var impacts: Array[int] = []
	while dog.frame < target:
		dog.tick(far, false)
		if dog.state == S.ACTIVE and dog.pending_hit() != null:
			impacts.append(dog.frame)
			dog.mark_hit_resolved()
	return impacts


func test_bite_impacts_at_24_then_every_60_frames() -> void:
	var dog := DogBoss.new(_boss([bite], [bite]), 1)
	assert_eq(dog.frames_to_impact(), 24)
	# 24 d'anticipation + 6 d'impact + 30 de récupération = 60 par morsure.
	assert_eq(_run(dog, 150), [24, 84, 144])


func test_hit_is_pending_only_during_active_frames_until_resolved() -> void:
	var dog := DogBoss.new(_boss([bite], [bite]), 1)
	while dog.frame < 23:
		dog.tick(false, false)
	assert_null(dog.pending_hit())
	dog.tick(false, false)
	assert_eq(dog.pending_hit(), bite)
	dog.mark_hit_resolved()
	dog.tick(false, false)
	assert_null(dog.pending_hit())


func test_burst_rhythm() -> void:
	var dog := DogBoss.new(_boss([burst], [burst]), 1)
	# 20 ; +6+14 = 40 ; +6+14 = 60 ; puis 6 + 40 de récupération → nouvelle rafale à 106.
	assert_eq(_run(dog, 130), [20, 40, 60, 126])


func test_phase_two_shortens_windups_by_twenty_percent() -> void:
	var dog := DogBoss.new(_boss([bite], [bite]), 1)
	_run(dog, 10)
	dog.take_posture(100)
	assert_true(dog.soothe())
	assert_eq(dog.phase, 2)
	assert_eq(dog.frames_to_impact(), 19)
	assert_eq(_run(dog, 40), [29])


func test_ranged_attack_chosen_when_child_is_far() -> void:
	for seed_value: int in 10:
		var dog := DogBoss.new(_boss([bite, leap], [bite, leap]), seed_value, true)
		assert_eq(dog.attack, leap)
		dog = DogBoss.new(_boss([bite, leap], [bite, leap]), seed_value, false)
		assert_eq(dog.attack, bite)


func test_same_seed_same_sequence() -> void:
	var a := DogBoss.new(_boss([bite, burst], [bite, burst]), 42)
	var b := DogBoss.new(_boss([bite, burst], [bite, burst]), 42)
	assert_eq(_run(a, 2000), _run(b, 2000))


func test_break_stuns_then_recovers_in_same_phase() -> void:
	var dog := DogBoss.new(_boss([bite], [bite]), 1)
	watch_signals(dog)
	_run(dog, 10)
	dog.take_posture(100)
	assert_eq(dog.state, S.BROKEN)
	assert_signal_emitted_with_parameters(dog, "posture_broken", [1])
	assert_eq(dog.break_frames_remaining(), 120)
	assert_eq(_run(dog, 129), [], "Aucune attaque pendant la brèche.")
	assert_eq(dog.break_frames_remaining(), 1)
	assert_eq(dog.state, S.BROKEN)
	_run(dog, 130)
	assert_eq(dog.state, S.WINDUP)
	assert_eq(dog.phase, 1)
	assert_eq(dog.posture.value(), 0)


func test_soothe_ends_phase_one_then_fight() -> void:
	var dog := DogBoss.new(_boss([bite], [bite]), 1)
	watch_signals(dog)
	assert_false(dog.soothe(), "Pas de brèche : rien à apaiser.")
	dog.take_posture(100)
	dog.soothe()
	assert_signal_emitted_with_parameters(dog, "phase_changed", [2])
	dog.take_posture(100)
	dog.soothe()
	assert_eq(dog.state, S.PACIFIED)
	assert_signal_emitted(dog, "pacified")
	assert_eq(_run(dog, 500), [])


func test_posture_ignored_while_broken() -> void:
	var dog := DogBoss.new(_boss([bite], [bite]), 1)
	dog.take_posture(100)
	dog.take_posture(50)
	_run(dog, 120)
	assert_eq(dog.posture.value(), 0)
