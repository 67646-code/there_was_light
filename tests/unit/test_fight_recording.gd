extends GutTest
## FightRecording : enregistrer une partie, la sauvegarder, la rejouer à l'identique.

const TEST_DIR: String = "user://test_recordings"


func _record_scripted_fight(frames: int) -> FightRecording:
	var child := load("res://data/child_variant_b.tres") as ChildSettings
	var boss := load("res://data/boss_dog.tres") as BossData
	var arena := load("res://data/arena.tres") as ArenaSettings
	var feedback := load("res://data/feedback.tres") as FeedbackSettings
	var recording := FightRecording.start(child, boss, arena, feedback, 11)
	var fight := recording.create_fight()
	for f: int in frames:
		# Commandes variées et reproductibles : marche, parades, sauts, esquives, relâches.
		var input := ChildInput.new()
		input.move = [1, 1, 0, -1][(f / 37) % 4]
		input.lantern = (f / 5) % 7 == 0
		input.jump = f % 151 < 3
		input.dodge = f % 97 < 2
		input.release = f % 263 < 2
		input.direction = (f / 120) % 3 as CombatTypes.Direction
		recording.record(input)
		fight.tick(input)
	recording.final_summary = fight.summary()
	return recording


func after_all() -> void:
	for file: String in DirAccess.get_files_at(TEST_DIR):
		DirAccess.remove_absolute(TEST_DIR.path_join(file))


func test_replay_reaches_identical_state() -> void:
	var recording := _record_scripted_fight(3000)
	var replayed := recording.replay()
	assert_eq(recording.diff_with(replayed.summary()), {})


func test_dict_roundtrip_keeps_everything() -> void:
	var recording := _record_scripted_fight(500)
	var json := JSON.stringify(recording.to_dict())
	var back := FightRecording.from_dict(JSON.parse_string(json) as Dictionary)
	assert_eq(back.inputs, recording.inputs)
	assert_eq(back.rng_seed, 11)
	assert_eq(back.child_path, "res://data/child_variant_b.tres")
	assert_eq(back.diff_with(back.replay().summary()), {})


func test_save_and_load_file() -> void:
	var recording := _record_scripted_fight(600)
	var path := TEST_DIR.path_join("roundtrip.json")
	assert_eq(recording.save(path), OK)
	var loaded := FightRecording.load_file(path)
	assert_not_null(loaded)
	assert_eq(loaded.frame_count(), 600)
	assert_eq(loaded.diff_with(loaded.replay().summary()), {})


func test_diff_reports_mismatch() -> void:
	var recording := _record_scripted_fight(300)
	var summary := recording.final_summary.duplicate()
	summary["child_health"] = -1
	assert_has(recording.diff_with(summary), "child_health")


func test_unreadable_file_returns_null() -> void:
	var path := TEST_DIR.path_join("broken.json")
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("pas du json")
	file.close()
	assert_null(FightRecording.load_file(path))
