extends ChildCombatTestBase
## ChildCombat : relâche, esquive, santé.

# --- Relâche --------------------------------------------------------------------


func test_release_three_charges_after_ten_frames() -> void:
	for i: int in 3:
		_perfect_parry_now()
		_to(child.frame + 1)
	watch_signals(child)
	_to(99)
	_to(100, ChildInput.make(false, FRONT, true))
	assert_signal_emitted_with_parameters(child, "release_started", [3])
	_to(109)
	assert_eq(child.state, S.RELEASE_WINDUP)
	assert_signal_not_emitted(child, "released")
	_to(110)
	assert_signal_emitted_with_parameters(child, "released", [60])
	assert_eq(child.light, 0)
	assert_eq(child.state, S.NEUTRAL)


func test_release_one_charge_gives_fifteen() -> void:
	_perfect_parry_now()
	watch_signals(child)
	_to(child.frame + 1, ChildInput.make(false, FRONT, true))
	_to(child.frame + 10)
	assert_signal_emitted_with_parameters(child, "released", [15])


func test_release_without_light_does_nothing() -> void:
	_to(10, ChildInput.make(false, FRONT, true))
	assert_eq(child.state, S.NEUTRAL)


func test_variant_a_cannot_release() -> void:
	child.settings.release_enabled = false
	_perfect_parry_now()
	_to(child.frame + 1, ChildInput.make(false, FRONT, true))
	assert_eq(child.state, S.NEUTRAL)
	assert_eq(child.light, 1)


func test_hit_during_release_windup_cancels_and_keeps_charges() -> void:
	_perfect_parry_now()
	_perfect_parry_now()
	watch_signals(child)
	_to(child.frame + 1)
	_to(child.frame + 1, ChildInput.make(false, FRONT, true))
	_to(child.frame + 5)
	assert_eq(child.receive_hit(bite), R.HURT, "Exposé pendant l'anticipation.")
	_to(child.frame + 10)
	assert_signal_not_emitted(child, "released")
	assert_eq(child.light, 2)
	assert_eq(child.state, S.NEUTRAL)


# --- Esquive --------------------------------------------------------------------


func test_dodge_gives_twelve_frames_of_invulnerability() -> void:
	_to(49)
	_to(50, ChildInput.make(false, FRONT, false, true))
	_to(61)
	assert_eq(child.receive_hit(bite), R.AVOIDED)
	_to(62)
	assert_eq(child.receive_hit(bite), R.HURT)


func test_dodge_cooldown_is_thirty_frames() -> void:
	var dodge := ChildInput.make(false, FRONT, false, true)
	watch_signals(child)
	_to(49)
	_to(50, dodge)
	_to(78)
	_to(79, dodge)
	assert_signal_emit_count(child, "dodged", 1)
	_to(80)
	_to(81, dodge)
	assert_signal_emit_count(child, "dodged", 2)


func test_dodge_drops_guard() -> void:
	_to(9)
	_to(30, _held())
	_to(31, ChildInput.make(true, FRONT, false, true))
	assert_eq(child.state, S.NEUTRAL)


# --- Santé ----------------------------------------------------------------------


func test_hurt_removes_one_health_then_45_frames_invulnerable() -> void:
	_to(10)
	assert_eq(child.receive_hit(bite), R.HURT)
	assert_eq(child.health, 4)
	_to(55)
	assert_eq(child.receive_hit(bite), R.AVOIDED)
	_to(56)
	assert_eq(child.receive_hit(bite), R.HURT)
	assert_eq(child.health, 3)


func test_five_hits_kill() -> void:
	watch_signals(child)
	for i: int in 5:
		_to(child.frame + 46)
		child.receive_hit(bite)
	assert_eq(child.health, 0)
	assert_eq(child.state, S.DEAD)
	assert_signal_emitted(child, "died")
	_to(child.frame + 100, _held())
	assert_eq(child.state, S.DEAD)
