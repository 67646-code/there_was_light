extends GutTest
## Scène de l'arène : chargement et bascule des variantes du test comparatif (P1.7).

const ARENA: String = "res://src/scenes/arena.tscn"

var arena: Node


func before_each() -> void:
	arena = (load(ARENA) as PackedScene).instantiate()
	arena.set(&"recordings_dir", "user://test_recordings_scene")
	add_child_autofree(arena)


func after_all() -> void:
	var dir := "user://test_recordings_scene"
	for file: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(file))


func test_starts_on_variant_b_with_release() -> void:
	var fight := arena.get(&"fight") as ArenaFight
	assert_true(fight.child_settings.release_enabled)
	var label := arena.get_node("%VariantLabel") as Label
	assert_string_contains(label.text, "B")


func test_toggle_switches_variant_and_restarts() -> void:
	var before := arena.get(&"fight") as ArenaFight
	arena.call(&"next_variant")
	var after := arena.get(&"fight") as ArenaFight
	assert_ne(after, before, "Nouvelle partie.")
	assert_false(after.child_settings.release_enabled, "Variante A : pas de relâche.")
	assert_string_contains((arena.get_node("%VariantLabel") as Label).text, "A")
	arena.call(&"next_variant")
	assert_true((arena.get(&"fight") as ArenaFight).child_settings.release_enabled)


func test_played_frames_are_saved_and_replay_identically() -> void:
	for i: int in 200:
		arena.call(&"_physics_process", 1.0 / 60.0)
	var path := str(arena.call(&"save_recording"))
	assert_ne(path, "", "Une partie commencée doit être enregistrée.")
	var recording := FightRecording.load_file(path)
	assert_eq(recording.frame_count(), 200)
	assert_eq(recording.child_path, "res://data/child_variant_b.tres")
	assert_eq(recording.diff_with(recording.replay().summary()), {})


func test_nothing_saved_before_first_frame() -> void:
	assert_eq(str(arena.call(&"save_recording")), "")
