extends GutTest
## Vérifie que les entrées du prototype (P1.0) sont déclarées dans project.godot.

const ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"aim_up",
	&"aim_down",
	&"jump",
	&"dodge",
	&"lantern",
	&"release",
	&"debug_toggle",
	&"variant_toggle",
]
## Actions de jeu qui doivent aussi être jouables à la manette.
const GAMEPAD_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"aim_up",
	&"aim_down",
	&"jump",
	&"dodge",
	&"lantern",
	&"release",
]


func test_all_actions_exist_with_a_key() -> void:
	for action: StringName in ACTIONS:
		assert_true(InputMap.has_action(action), "Action manquante : %s" % action)
		assert_true(_has_event_of(action, "InputEventKey"), "Pas de touche pour %s" % action)


func test_game_actions_have_gamepad_binding() -> void:
	for action: StringName in GAMEPAD_ACTIONS:
		var has_pad: bool = (
			_has_event_of(action, "InputEventJoypadButton")
			or _has_event_of(action, "InputEventJoypadMotion")
		)
		assert_true(has_pad, "Pas de commande manette pour %s" % action)


func test_keys_use_physical_positions() -> void:
	# Touches physiques : Z/Q/S/D en AZERTY, W/A/S/D en QWERTY.
	for action: StringName in ACTIONS:
		for event: InputEvent in InputMap.action_get_events(action):
			var key := event as InputEventKey
			if key != null:
				assert_ne(key.physical_keycode, KEY_NONE, "Touche non physique : %s" % action)


func _has_event_of(action: StringName, type_name: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event.get_class() == type_name:
			return true
	return false
