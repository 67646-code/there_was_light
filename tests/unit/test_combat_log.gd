extends GutTest
## CombatLog : les événements du duel deviennent des lignes lisibles, en nombre limité.

var duel: Duel
var combat_log: CombatLog


func before_each() -> void:
	duel = Duel.new(
		load("res://data/child_variant_b.tres") as ChildSettings,
		load("res://data/boss_dog.tres") as BossData,
		5
	)
	combat_log = CombatLog.new(duel, 3)


func _tick(input: ChildInput = ChildInput.make(), in_range: bool = true) -> void:
	duel.tick(input, in_range, false)


func test_entries_are_prefixed_by_frame() -> void:
	_tick()
	combat_log.add("Test")
	assert_eq(combat_log.entries, ["[1] Test"])


func test_keeps_only_last_entries() -> void:
	for i: int in 5:
		combat_log.add(str(i))
	assert_eq(combat_log.entries.size(), 3)
	assert_string_ends_with(combat_log.entries[2], "4")


func test_break_and_soothe_are_logged() -> void:
	duel.dog.take_posture(duel.dog.data.max_posture)
	_tick()
	_tick(ChildInput.make(true))
	assert_string_contains(combat_log.entries[0], "BRÈCHE phase 1")
	assert_string_contains(combat_log.entries[1], "Apaisé → phase 2")


func test_soothe_out_of_range_is_logged() -> void:
	duel.dog.take_posture(duel.dog.data.max_posture)
	_tick(ChildInput.make(), false)
	_tick(ChildInput.make(true), false)
	assert_string_contains(combat_log.entries[-1], "hors de portée")


func test_ignored_press_is_logged_with_reason() -> void:
	# Appui dans le vide, puis nouvel appui pendant la récupération.
	_tick(ChildInput.make(true), false)
	for i: int in duel.child.settings.perfect_parry_window_frames + 1:
		_tick(ChildInput.make(), false)
	_tick(ChildInput.make(true), false)
	assert_string_contains(combat_log.entries[-1], "R1 ignoré : récupération")
