extends GutTest
## ChildSettings : logique de la classe et cohérence des fichiers data/child_*.tres.
## On vérifie des invariants, pas les valeurs : elles sont réglées par l'humain.

const VARIANT_A: String = "res://data/child_variant_a.tres"
const VARIANT_B: String = "res://data/child_variant_b.tres"


func test_release_posture_follows_table() -> void:
	var s := ChildSettings.new()
	s.release_posture_by_charges = [15, 35, 60]
	assert_eq(s.release_posture(0), 0)
	assert_eq(s.release_posture(1), 15)
	assert_eq(s.release_posture(2), 35)
	assert_eq(s.release_posture(3), 60)
	assert_eq(s.release_posture(5), 60, "Au-delà de la table : dernière valeur.")


func test_release_posture_with_empty_table_is_zero() -> void:
	assert_eq(ChildSettings.new().release_posture(2), 0)


func test_both_variants_load_and_are_coherent() -> void:
	for path: String in [VARIANT_A, VARIANT_B]:
		var s := load(path) as ChildSettings
		assert_not_null(s, "Ressource illisible : %s" % path)
		if s == null:
			continue
		assert_gt(s.max_health, 0, path)
		assert_gt(s.max_oil, 0, path)
		assert_gt(s.max_light, 0, path)
		assert_gt(s.perfect_parry_window_frames, 0, path)
		assert_between(s.guard_break_recover_oil, 0, s.max_oil, path)
		assert_eq(
			s.release_posture_by_charges.size(), s.max_light, "Une valeur par charge : %s" % path
		)


func test_release_table_is_more_than_proportional() -> void:
	# Pilier de la fiche : tenir doit rapporter plus que relâcher souvent.
	var s := load(VARIANT_B) as ChildSettings
	for n: int in range(2, s.max_light + 1):
		assert_gt(s.release_posture(n), s.release_posture(1) * n, "%d charges" % n)


func test_variant_a_has_no_release_and_variant_b_does() -> void:
	assert_false((load(VARIANT_A) as ChildSettings).release_enabled)
	assert_true((load(VARIANT_B) as ChildSettings).release_enabled)
