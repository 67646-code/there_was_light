extends GutTest
## ArenaFight : combat et déplacements ensemble, avec les données réelles.

var fight: ArenaFight


func before_each() -> void:
	fight = ArenaFight.new(
		load("res://data/child_variant_b.tres") as ChildSettings,
		load("res://data/boss_dog.tres") as BossData,
		load("res://data/arena.tres") as ArenaSettings,
		3
	)


func _pad(move: int = 0, lantern: bool = false, dodge: bool = false) -> ChildInput:
	var i := ChildInput.make(lantern, CombatTypes.Direction.FRONT, false, dodge)
	i.move = move
	return i


func test_dodge_press_moves_child() -> void:
	var x0 := fight.motion.child_x
	fight.tick(_pad(-1, false, true))
	for i: int in 11:
		fight.tick(_pad())
	assert_lt(fight.motion.child_x, x0 - 100.0)


func test_raised_lantern_slows_child() -> void:
	fight.tick(_pad(1))
	var walk_step := fight.motion.child_x - fight.motion.settings.child_start_x
	var x0 := fight.motion.child_x
	fight.tick(_pad(1, true))
	assert_almost_eq(
		fight.motion.child_x - x0, walk_step * fight.child_settings.advance_speed_factor, 0.01
	)


func test_controller_input_is_not_mutated() -> void:
	var input := _pad(1, true)
	fight.tick(input)
	fight.tick(input)
	assert_false(input.advancing, "ArenaFight travaille sur une copie.")


func test_dog_comes_to_bite_an_idle_child() -> void:
	for i: int in 60 * 30:
		fight.tick(_pad())
	assert_lt(fight.duel.child.health, fight.duel.child.settings.max_health)


func test_child_far_away_draws_a_leap() -> void:
	# Fuir vers le bord : le chien finit par choisir un bond.
	var leapt := false
	for i: int in 60 * 20:
		fight.tick(_pad(-1))
		if fight.duel.dog.attack.ranged:
			leapt = true
			break
	assert_true(leapt)


func test_pushing_moves_dog_back() -> void:
	# Coller le chien, lanterne tendue, en avançant.
	for i: int in 120:
		fight.tick(_pad(1))
	fight.tick(_pad(1))
	var dog_before := fight.motion.dog_x
	for i: int in 30:
		fight.tick(_pad(1, true))
	if fight.duel.dog.state == DogBoss.State.BROKEN:
		return
	assert_gt(fight.motion.dog_x, dog_before)
