extends GutTest
## ChildInput : encodage compact pour l'enregistrement, et copie.


func test_bits_roundtrip_for_every_combination() -> void:
	for bits: int in 16:
		for direction: int in 3:
			for move: int in [-1, 0, 1]:
				var i := ChildInput.make(
					bits & 1 != 0, direction as CombatTypes.Direction, bits & 2 != 0, bits & 4 != 0
				)
				i.jump = bits & 8 != 0
				i.move = move
				var back := ChildInput.from_bits(i.to_bits())
				assert_eq(back.to_bits(), i.to_bits())
				assert_eq(back.lantern, i.lantern)
				assert_eq(back.release, i.release)
				assert_eq(back.dodge, i.dodge)
				assert_eq(back.jump, i.jump)
				assert_eq(back.direction, i.direction)
				assert_eq(back.move, i.move)


func test_neutral_input_is_compact() -> void:
	# Aucun bouton, direction devant, pas de déplacement.
	assert_eq(ChildInput.new().to_bits(), 64)


func test_copy_is_independent() -> void:
	var i := ChildInput.make(true)
	i.move = 1
	var c := i.copy()
	c.lantern = false
	assert_true(i.lantern)
	assert_eq(c.move, 1)
