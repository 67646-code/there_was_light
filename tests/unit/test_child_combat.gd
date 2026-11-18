extends ChildCombatTestBase
## ChildCombat : parade parfaite, garde, parade dans le vide, huile.

# --- Parade parfaite ----------------------------------------------------------


func test_bite_at_24_parried_at_20_is_perfect() -> void:
	_to(19)
	_to(24, _held())
	assert_eq(child.receive_hit(bite), R.PERFECT)
	assert_eq(child.light, 1)
	assert_eq(child.oil(), 100, "La parade parfaite ne coûte pas d'huile.")
	assert_eq(child.health, 5)


func test_window_is_eight_frames_including_press() -> void:
	_to(19)
	_to(27, _held())
	assert_eq(child.parry_window_remaining(), 1)
	assert_eq(child.receive_hit(bite), R.PERFECT, "Image 27 = 8e image de la fenêtre.")


func test_impact_one_frame_after_window_is_guard() -> void:
	_to(19)
	_to(28, _held())
	assert_eq(child.state, S.GUARD)
	assert_eq(child.receive_hit(bite), R.GUARD)
	assert_eq(child.light, 0)


func test_tap_released_before_impact_still_perfect() -> void:
	_to(19)
	_to(20, _held())
	_to(23)
	assert_eq(child.receive_hit(bite), R.PERFECT)


func test_wrong_direction_is_guard() -> void:
	_to(19)
	_to(22, _held(UP))
	assert_eq(child.receive_hit(bite), R.GUARD)
	assert_eq(child.oil(), 85)


func test_light_is_capped() -> void:
	for i: int in 5:
		_perfect_parry_now()
		_to(child.frame + 1)
	assert_eq(child.light, 3)


# --- Garde et parade dans le vide ----------------------------------------------


func test_held_early_then_bite_is_guard() -> void:
	_to(9)
	_to(24, _held())
	assert_eq(child.receive_hit(bite), R.GUARD)
	assert_eq(child.oil(), 85)
	assert_eq(child.health, 5)


func test_holding_past_window_has_no_penalty() -> void:
	_to(9)
	_to(60, _held())
	assert_eq(child.state, S.GUARD)
	assert_eq(child.oil(), 100)


func test_tap_without_attack_is_whiff() -> void:
	_to(19)
	_to(20, _held())
	_to(27)
	assert_eq(child.state, S.PARRY_WINDOW)
	_to(28)
	assert_eq(child.state, S.WHIFF_RECOVERY)
	assert_eq(child.oil(), 95)
	assert_eq(child.receive_hit(bite), R.HURT, "Vulnérable pendant la récupération.")


func test_whiff_recovery_lasts_twenty_frames() -> void:
	_to(19)
	_to(20, _held())
	_to(47)
	assert_eq(child.state, S.WHIFF_RECOVERY)
	_to(48)
	assert_eq(child.state, S.NEUTRAL)


func test_consumed_press_does_not_whiff() -> void:
	_to(19)
	_to(20, _held())
	child.consume_lantern_press()
	_to(40)
	assert_eq(child.state, S.NEUTRAL)
	assert_eq(child.oil(), 100)


func test_cannot_parry_during_whiff_recovery() -> void:
	watch_signals(child)
	_to(19)
	_to(20, _held())
	_to(30)
	_to(31, _held())
	assert_eq(child.state, S.WHIFF_RECOVERY)
	assert_signal_emitted_with_parameters(child, "lantern_press_ignored", [&"WHIFF_RECOVERY"])


func test_releasing_guard_returns_to_neutral() -> void:
	_to(9)
	_to(30, _held())
	_to(31)
	assert_eq(child.state, S.NEUTRAL)


# --- Huile ----------------------------------------------------------------------


func test_oil_regenerates_eight_per_second_when_lowered() -> void:
	_to(9)
	_to(30, _held())
	child.receive_hit(bite)
	_to(90, _held())
	assert_eq(child.oil(), 85, "Pas de régénération lanterne tendue.")
	_to(150)
	assert_eq(child.oil(), 93)


func test_advancing_with_lantern_drains_fifteen_per_second() -> void:
	_to(9)
	_to(10, _held())
	_to(70, ChildInput.make(true, FRONT, false, false, true))
	assert_true(child.is_pushing())
	assert_eq(child.oil(), 85)


func test_guard_break_stuns_then_blocks_parry_until_twenty_oil() -> void:
	watch_signals(child)
	_to(9)
	_to(18, _held())
	assert_eq(child.state, S.GUARD)
	for i: int in 7:
		child.receive_hit(bite)
	assert_signal_emitted(child, "guard_broken")
	assert_eq(child.state, S.STUNNED)
	assert_eq(child.oil(), 0)
	assert_eq(child.receive_hit(bite), R.HURT, "Sonné : plus de garde.")
	# Brisée à l'image 18 : sonné jusqu'à 77. 20 d'huile à 8/s = 150 images → image 168.
	_to(77)
	assert_eq(child.state, S.STUNNED)
	_to(78)
	assert_eq(child.state, S.NEUTRAL)
	_to(165)
	_to(166, _held())
	assert_eq(child.state, S.NEUTRAL, "Huile 19 : parade impossible.")
	assert_eq(child.oil(), 19)
	_to(168)
	assert_false(child.guard_is_broken)
	_to(169, _held())
	assert_eq(child.state, S.PARRY_WINDOW)
