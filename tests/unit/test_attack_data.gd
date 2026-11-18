extends GutTest
## AttackData : anticipation par coup, mise à l'échelle et durée totale.


func _burst() -> AttackData:
	var a := AttackData.new()
	a.windup_frames = 20
	a.hit_count = 3
	a.interval_windup_frames = 14
	a.active_frames = 6
	a.recovery_frames = 40
	return a


func test_first_hit_uses_windup_then_interval() -> void:
	var a := _burst()
	assert_eq(a.windup_for_hit(0), 20)
	assert_eq(a.windup_for_hit(1), 14)
	assert_eq(a.windup_for_hit(2), 14)


func test_windup_scaling_rounds_to_nearest() -> void:
	# Phase 2 à 80 % : 24 → 19,2 → 19 ; 14 → 11,2 → 11 ; 36 → 28,8 → 29.
	assert_eq(AttackData.scale_frames(24, 80), 19)
	assert_eq(AttackData.scale_frames(14, 80), 11)
	assert_eq(AttackData.scale_frames(36, 80), 29)
	assert_eq(AttackData.scale_frames(30, 80), 24)
	assert_eq(AttackData.scale_frames(24, 100), 24)


func test_total_frames_of_burst() -> void:
	# 20 + 6 + 14 + 6 + 14 + 6 + 40 = 106
	assert_eq(_burst().total_frames(), 106)
	# 16 + 6 + 11 + 6 + 11 + 6 + 40 = 96
	assert_eq(_burst().total_frames(80), 96)


func test_dog_attack_files_are_coherent() -> void:
	for path: String in DirAccess.get_files_at("res://data/attacks"):
		if not path.ends_with(".tres"):
			continue
		var a := load("res://data/attacks/" + path) as AttackData
		assert_not_null(a, path)
		if a == null:
			continue
		assert_ne(a.id, &"", path)
		assert_gt(a.windup_frames, 0, path)
		assert_gt(a.hit_count, 0, path)
		assert_gt(a.active_frames, 0, path)
		assert_gt(a.health_damage, 0, path)
		if a.hit_count > 1:
			assert_gt(a.interval_windup_frames, 0, path)
