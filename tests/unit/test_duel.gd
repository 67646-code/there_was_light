extends GutTest
## Duel : interactions enfant / chien, et parties complètes avec les données réelles.

const CHILD_A: String = "res://data/child_variant_a.tres"
const CHILD_B: String = "res://data/child_variant_b.tres"
const DOG: String = "res://data/boss_dog.tres"
const FRONT := CombatTypes.Direction.FRONT


func _bite_only() -> BossData:
	var boss := (load(DOG) as BossData).duplicate() as BossData
	var bite := load("res://data/attacks/dog_bite.tres") as AttackData
	boss.phase_1_attacks = [bite]
	boss.phase_2_attacks = [bite]
	return boss


func _duel(boss: BossData = _bite_only(), child_path: String = CHILD_B) -> Duel:
	return Duel.new(load(child_path) as ChildSettings, boss, 7)


func _to(duel: Duel, target: int, input: ChildInput = ChildInput.make(), in_range := true) -> void:
	while duel.frame < target and not duel.is_over:
		duel.tick(input, in_range, false)


func test_perfect_parry_damages_dog_posture() -> void:
	var duel := _duel()
	var bite_at: int = duel.dog.frames_to_impact()
	_to(duel, bite_at - 4)
	_to(duel, bite_at, ChildInput.make(true))
	assert_eq(duel.child.light, 1)
	assert_eq(duel.dog.posture.value(), duel.child.settings.perfect_parry_posture)


func test_unparried_bite_hurts_child() -> void:
	var duel := _duel()
	_to(duel, duel.dog.frames_to_impact())
	assert_eq(duel.child.health, duel.child.settings.max_health - 1)


func test_out_of_range_bite_misses() -> void:
	var duel := _duel()
	_to(duel, 200, ChildInput.make(), false)
	assert_eq(duel.child.health, duel.child.settings.max_health)


func test_idle_child_loses() -> void:
	var duel := _duel()
	watch_signals(duel)
	_to(duel, 60 * 60)
	assert_true(duel.is_over)
	assert_signal_emitted_with_parameters(duel, "ended", [false])


## Joueur parfait scripté : appuie 3 images avant chaque impact, relâche à 3 charges pendant la
## récupération du chien, apaise à chaque brèche. Il doit gagner sans perdre de santé.
func _play_perfectly(duel: Duel) -> void:
	var toggle := false
	while not duel.is_over and duel.frame < 60 * 600:
		var dog := duel.dog
		var input := ChildInput.make()
		match dog.state:
			DogBoss.State.WINDUP:
				input.lantern = dog.frames_to_impact() <= 3
				input.direction = dog.attack.parry_direction
			DogBoss.State.RECOVERY:
				input.release = duel.child.light == duel.child.settings.max_light
			DogBoss.State.BROKEN:
				toggle = not toggle
				input.lantern = toggle
		duel.tick(input, true, false)


func test_perfect_player_soothes_dog_variant_b() -> void:
	var duel := _duel(load(DOG) as BossData)
	watch_signals(duel)
	_play_perfectly(duel)
	assert_signal_emitted_with_parameters(duel, "ended", [true])
	assert_eq(duel.child.health, duel.child.settings.max_health)
	gut.p("Variante B, joueur parfait : %d images" % duel.frame)


func test_perfect_player_soothes_dog_variant_a() -> void:
	var duel := _duel(load(DOG) as BossData, CHILD_A)
	watch_signals(duel)
	_play_perfectly(duel)
	assert_signal_emitted_with_parameters(duel, "ended", [true])
	gut.p("Variante A, joueur parfait : %d images" % duel.frame)


func test_release_breaks_posture_with_full_charges() -> void:
	var duel := _duel()
	_play_perfectly_until_light(duel, 3)
	var before := duel.dog.posture.value()
	_to(duel, duel.frame + 1, ChildInput.make(false, FRONT, true))
	_to(duel, duel.frame + duel.child.settings.release_windup_frames)
	assert_eq(duel.child.light, 0)
	assert_gt(duel.dog.posture.value(), before)


func _play_perfectly_until_light(duel: Duel, target_light: int) -> void:
	while duel.child.light < target_light and duel.frame < 60 * 120:
		var dog := duel.dog
		var lantern := dog.state == DogBoss.State.WINDUP and dog.frames_to_impact() <= 3
		duel.tick(ChildInput.make(lantern), true, false)
	# Attendre la récupération du chien pour relâcher en sécurité.
	while duel.dog.state != DogBoss.State.RECOVERY and duel.frame < 60 * 120:
		duel.tick(ChildInput.make(), true, false)
	_to(duel, duel.frame + 1)


func test_soothing_does_not_whiff() -> void:
	var duel := _duel()
	duel.dog.take_posture(duel.dog.data.max_posture)
	_to(duel, 1)
	_to(duel, 2, ChildInput.make(true))
	assert_eq(duel.dog.phase, 2)
	_to(duel, 40)
	assert_ne(duel.child.state, ChildCombat.State.WHIFF_RECOVERY)


func test_soothing_out_of_range_is_reported() -> void:
	var duel := _duel()
	watch_signals(duel)
	duel.dog.take_posture(duel.dog.data.max_posture)
	_to(duel, 1, ChildInput.make(), false)
	_to(duel, 2, ChildInput.make(true), false)
	assert_signal_emitted(duel, "soothe_missed")
	assert_eq(duel.dog.state, DogBoss.State.BROKEN)


func test_same_seed_and_inputs_same_outcome() -> void:
	var a := _duel(load(DOG) as BossData)
	var b := _duel(load(DOG) as BossData)
	_play_perfectly(a)
	_play_perfectly(b)
	assert_eq(a.frame, b.frame)
	assert_eq(a.dog.posture.value(), b.dog.posture.value())
