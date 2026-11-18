extends GutTest
## PostureGauge : montée, brèche, régénération retardée, poussée.

var gauge: PostureGauge


func before_each() -> void:
	var b := BossData.new()
	b.max_posture = 100
	b.posture_regen_per_second = 10
	b.posture_regen_delay_frames = 120
	gauge = PostureGauge.new(b)


func _ticks(n: int, pushed: bool = false) -> void:
	for i: int in n:
		gauge.tick(pushed)


func test_add_raises_posture() -> void:
	assert_false(gauge.add(8))
	assert_eq(gauge.value(), 8)


func test_reaching_max_breaks_and_clamps() -> void:
	watch_signals(gauge)
	gauge.add(60)
	assert_true(gauge.add(60))
	assert_true(gauge.is_broken)
	assert_eq(gauge.value(), 100)
	assert_signal_emit_count(gauge, "broke", 1)
	assert_false(gauge.add(10), "Déjà brisée.")


func test_no_regen_during_two_seconds_then_ten_per_second() -> void:
	gauge.add(50)
	_ticks(120)
	assert_eq(gauge.value(), 50)
	_ticks(60)
	assert_eq(gauge.value(), 40)


func test_new_pressure_restarts_delay() -> void:
	gauge.add(50)
	_ticks(100)
	gauge.add(8)
	_ticks(120)
	assert_eq(gauge.value(), 58)


func test_pushing_blocks_regen() -> void:
	gauge.add(50)
	_ticks(300, true)
	assert_eq(gauge.value(), 50)
	_ticks(120)
	assert_eq(gauge.value(), 50, "La poussée relance le délai.")


func test_regen_stops_at_zero() -> void:
	gauge.add(5)
	_ticks(600)
	assert_eq(gauge.value(), 0)


func test_reset() -> void:
	gauge.add(100)
	gauge.reset()
	assert_false(gauge.is_broken)
	assert_eq(gauge.value(), 0)


func test_reset_to_value_restarts_regen_delay() -> void:
	gauge.add(100)
	gauge.reset(50)
	assert_false(gauge.is_broken)
	assert_eq(gauge.value(), 50)
	_ticks(120)
	assert_eq(gauge.value(), 50)


func test_reset_value_never_breaks_again() -> void:
	gauge.reset(500)
	assert_false(gauge.is_broken)
	assert_lt(gauge.value(), 100)
