extends GutTest
## Vérifie que l'infrastructure de test fonctionne et que la scène principale se charge.

const MAIN_SCENE: String = "res://src/scenes/main.tscn"


func test_main_scene_loads() -> void:
	var packed: PackedScene = load(MAIN_SCENE) as PackedScene
	assert_not_null(packed, "La scène principale doit se charger.")
	var main: Node = packed.instantiate()
	add_child_autofree(main)
	assert_true(main.is_inside_tree())


func test_physics_runs_at_60_ticks() -> void:
	# Toute la logique de combat est exprimée en images à 60 i/s.
	assert_eq(Engine.physics_ticks_per_second, 60)
