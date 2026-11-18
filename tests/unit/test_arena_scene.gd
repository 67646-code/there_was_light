extends GutTest
## Scène de l'arène : chargement et bascule des variantes du test comparatif (P1.7).

const ARENA: String = "res://src/scenes/arena.tscn"

var arena: Node


func before_each() -> void:
	arena = (load(ARENA) as PackedScene).instantiate()
	add_child_autofree(arena)


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
