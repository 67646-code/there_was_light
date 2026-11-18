extends Node2D
## Arène du prototype : lit la manette, fait avancer le combat d'une image par image physique
## et laisse la vue l'afficher. Après la fin du combat, « saut » relance une partie.
## F2 bascule entre les variantes du test comparatif et relance une partie.
## Chaque partie est enregistrée dans user://recordings/ (fin de partie, relance, fermeture).
## Relecture à l'écran : godot --path . -- --replay=<fichier.json>

## Réglages de l'enfant pour chaque variante du test comparatif (A, B…).
@export var variants: Array[ChildSettings] = []
@export var variant_labels: Array[String] = []
@export var variant_index: int = 0
@export var boss_data: BossData
@export var arena_settings: ArenaSettings
@export var feedback_settings: FeedbackSettings
@export var rng_seed: int = 1

## Affichage de debug au lancement (F1 / Select pour basculer).
@export var debug_on_start: bool = true
## Enregistre les parties jouées dans `recordings_dir`.
@export var record_fights: bool = true
@export var recordings_dir: String = "user://recordings"

var fight: ArenaFight
var combat_log: CombatLog
## Partie en cours d'enregistrement (null en relecture ou si désactivé).
var recording: FightRecording
## Enregistrement rejoué à l'écran (null en jeu normal).
var replaying: FightRecording

var _replay_cursor: int = 0

@onready var _view: ArenaView = %ArenaView
@onready var _message: Label = %Message
@onready var _debug: DebugOverlay = %DebugOverlay
@onready var _effects: ImpactEffects = %ImpactEffects
@onready var _variant_label: Label = %VariantLabel


func _ready() -> void:
	_set_debug(debug_on_start)
	var replay_path := _replay_path_from_command_line()
	if replay_path != "":
		replaying = FightRecording.load_file(replay_path)
		if replaying == null:
			push_error("Enregistrement illisible : %s" % replay_path)
	_restart()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_recording()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_toggle"):
		_set_debug(not _debug.visible)
	elif event.is_action_pressed(&"variant_toggle"):
		next_variant()


## Passe à la variante suivante et relance une partie.
func next_variant() -> void:
	variant_index = (variant_index + 1) % variants.size()
	_restart()


func current_variant() -> ChildSettings:
	return variants[variant_index]


func _physics_process(_delta: float) -> void:
	if replaying != null:
		_replay_step()
		return
	var input := read_controller()
	if fight.duel.is_over:
		if input.jump:
			_restart()
		return
	if recording != null:
		recording.record(input)
	fight.tick(input)
	_view.queue_redraw()
	_debug.queue_redraw()


## Instantané de la manette pour cette image.
static func read_controller() -> ChildInput:
	var input := ChildInput.new()
	input.move = int(signf(Input.get_axis(&"move_left", &"move_right")))
	input.jump = Input.is_action_pressed(&"jump")
	input.dodge = Input.is_action_pressed(&"dodge")
	input.lantern = Input.is_action_pressed(&"lantern")
	input.release = Input.is_action_pressed(&"release")
	if Input.is_action_pressed(&"aim_up"):
		input.direction = CombatTypes.Direction.UP
	elif Input.is_action_pressed(&"aim_down"):
		input.direction = CombatTypes.Direction.DOWN
	return input


## Sauvegarde la partie en cours (si elle a commencé) et renvoie le chemin, sinon "".
func save_recording() -> String:
	if recording == null or recording.frame_count() == 0:
		return ""
	recording.final_summary = fight.summary()
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	var path := "%s/fight_%s_%s.json" % [recordings_dir, stamp, _variant_letter()]
	var error := recording.save(path)
	if error != OK:
		push_error("Enregistrement impossible (%s) : %s" % [error_string(error), path])
		return ""
	print("Partie enregistrée : %s" % ProjectSettings.globalize_path(path))
	recording = null
	return path


func _replay_step() -> void:
	if _replay_cursor >= replaying.frame_count():
		return
	fight.tick(ChildInput.from_bits(replaying.inputs[_replay_cursor]))
	_replay_cursor += 1
	_view.queue_redraw()
	_debug.queue_redraw()
	if _replay_cursor == replaying.frame_count():
		var differences := replaying.diff_with(fight.summary())
		var verdict := "identique" if differences.is_empty() else "ÉCART : %s" % differences
		_message.text = "Fin de la relecture (%s)." % verdict


func _restart() -> void:
	save_recording()
	if replaying != null:
		fight = replaying.create_fight()
		_replay_cursor = 0
	else:
		fight = ArenaFight.new(
			current_variant(), boss_data, arena_settings, rng_seed, feedback_settings
		)
		if record_fights:
			recording = FightRecording.start(
				current_variant(), boss_data, arena_settings, feedback_settings, rng_seed
			)
	_effects.watch(fight)
	fight.duel.ended.connect(_on_fight_ended)
	combat_log = CombatLog.new(fight.duel)
	_view.fight = fight
	_debug.fight = fight
	_debug.combat_log = combat_log
	_message.text = ""
	var label := variant_labels[variant_index] if variant_index < variant_labels.size() else ""
	_variant_label.text = "Variante %s   (F2 pour changer)" % label
	if replaying != null:
		_variant_label.text = "RELECTURE — %s" % replaying.child_path.get_file()
	_view.queue_redraw()


func _set_debug(on: bool) -> void:
	_debug.visible = on
	_view.show_debug = on
	_view.queue_redraw()


func _variant_letter() -> String:
	return current_variant().resource_path.get_file().get_basename().get_slice("_", 2)


static func _replay_path_from_command_line() -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--replay="):
			return arg.trim_prefix("--replay=")
	return ""


func _on_fight_ended(child_won: bool) -> void:
	var outcome: String = "Le chien est apaisé." if child_won else "L'enfant est tombé."
	_message.text = outcome + "\nSaut pour recommencer."
	if replaying != null:
		return
	# Le dernier coup qui termine la partie est enregistré avant la sauvegarde.
	save_recording.call_deferred()
	_debug.queue_redraw()
