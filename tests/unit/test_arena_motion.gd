extends GutTest
## ArenaMotion : marche, saut, esquive, séparation, approche, bond et poussée.

var motion: ArenaMotion


func before_each() -> void:
	var a := ArenaSettings.new()
	a.half_width = 900.0
	a.child_start_x = -300.0
	a.dog_start_x = 300.0
	a.child_speed = 360.0
	a.jump_velocity = 950.0
	a.gravity = 3000.0
	a.dodge_speed = 1000.0
	a.dodge_move_frames = 12
	a.jump_clear_height = 70.0
	a.dog_walk_speed = 180.0
	a.dog_approach_distance = 120.0
	a.push_speed = 180.0
	a.min_separation = 95.0
	a.hit_range = 150.0
	a.far_distance = 500.0
	motion = ArenaMotion.new(a)


func _child(frames: int, input: ChildInput, factor: float = 1.0) -> void:
	for i: int in frames:
		motion.tick_child(input, factor)


func _move(dir: int, jump: bool = false) -> ChildInput:
	var i := ChildInput.new()
	i.move = dir
	i.jump = jump
	return i


func test_walks_child_speed_per_second() -> void:
	_child(60, _move(1))
	assert_almost_eq(motion.child_x, 60.0, 0.01)


func test_lantern_factor_slows_walk() -> void:
	_child(60, _move(1), 0.5)
	assert_almost_eq(motion.child_x, -120.0, 0.01)


func test_immobilized_child_does_not_move() -> void:
	_child(60, _move(1), 0.0)
	assert_eq(motion.child_x, -300.0)


func test_jump_rises_then_lands() -> void:
	_child(1, _move(0, true))
	assert_true(motion.is_airborne())
	_child(10, _move(0, true))
	assert_gt(motion.child_height, 70.0)
	_child(60, _move(0, true))
	assert_eq(motion.child_height, 0.0)
	_child(1, _move(0, true))
	assert_false(motion.is_airborne(), "Tenir saut ne relance pas : il faut un nouvel appui.")


func test_child_stays_in_arena() -> void:
	_child(600, _move(-1))
	assert_eq(motion.child_x, -900.0)


func test_cannot_walk_through_dog_on_ground() -> void:
	_child(300, _move(1))
	assert_almost_eq(motion.distance(), 95.0, 0.01)
	assert_lt(motion.child_x, motion.dog_x)


func test_far_and_range() -> void:
	assert_true(motion.is_far())
	assert_false(motion.can_hit(null))
	motion.child_x = 200.0
	assert_false(motion.is_far())
	assert_true(motion.can_hit(null))


func test_jump_clears_front_attacks_but_not_up_attacks() -> void:
	var front := AttackData.new()
	var up := AttackData.new()
	up.parry_direction = CombatTypes.Direction.UP
	motion.child_x = 200.0
	_child(10, _move(0, true))
	assert_false(motion.can_hit(front))
	assert_true(motion.can_hit(up))


func test_dodge_moves_away_from_dog_by_default() -> void:
	motion.start_dodge(0)
	_child(12, _move(0))
	assert_almost_eq(motion.child_x, -500.0, 0.01)


func test_dodge_follows_move_direction() -> void:
	motion.start_dodge(1)
	_child(12, _move(0))
	assert_almost_eq(motion.child_x, -100.0, 0.01)


func test_dog_approaches_until_approach_distance() -> void:
	for i: int in 600:
		motion.tick_dog(true, false)
	assert_almost_eq(motion.distance(), 120.0, 0.01)


func test_push_moves_dog_away() -> void:
	motion.tick_dog(false, true)
	assert_almost_eq(motion.dog_x, 303.0, 0.01)


func test_leap_lands_next_to_child() -> void:
	motion.start_leap(4)
	for i: int in 4:
		motion.tick_dog(false, false)
	assert_almost_eq(motion.distance(), 95.0, 0.01)


func test_knockbacks_push_apart_over_frames() -> void:
	motion.knock_child(80.0, 8)
	motion.knock_dog(40.0, 4)
	for i: int in 8:
		motion.tick_child(_move(0), 1.0)
		motion.tick_dog(false, false)
	assert_almost_eq(motion.child_x, -380.0, 0.01)
	assert_almost_eq(motion.dog_x, 340.0, 0.01)
