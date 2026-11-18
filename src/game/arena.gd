extends Node2D
## Arène du prototype : lit la manette, fait avancer le combat d'une image par image physique
## et laisse la vue l'afficher. Après la fin du combat, « saut » relance une partie.

@export var child_settings: ChildSettings
@export var boss_data: BossData
@export var arena_settings: ArenaSettings
@export var feedback_settings: FeedbackSettings
@export var rng_seed: int = 1

## Affichage de debug au lancement (F1 / Select pour basculer).
@export var debug_on_start: bool = true

var fight: ArenaFight
var combat_log: CombatLog

@onready var _view: ArenaView = %ArenaView
@onready var _message: Label = %Message
@onready var _debug: DebugOverlay = %DebugOverlay
@onready var _effects: ImpactEffects = %ImpactEffects


func _ready() -> void:
	_set_debug(debug_on_start)
	_restart()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_toggle"):
		_set_debug(not _debug.visible)


func _physics_process(_delta: float) -> void:
	var input := read_controller()
	if fight.duel.is_over:
		if input.jump:
			_restart()
		return
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


func _restart() -> void:
	fight = ArenaFight.new(child_settings, boss_data, arena_settings, rng_seed, feedback_settings)
	_effects.watch(fight)
	fight.duel.ended.connect(_on_fight_ended)
	combat_log = CombatLog.new(fight.duel)
	_view.fight = fight
	_debug.fight = fight
	_debug.combat_log = combat_log
	_message.text = ""
	_view.queue_redraw()


func _set_debug(on: bool) -> void:
	_debug.visible = on
	_view.show_debug = on
	_view.queue_redraw()


func _on_fight_ended(child_won: bool) -> void:
	var outcome: String = "Le chien est apaisé." if child_won else "L'enfant est tombé."
	_message.text = outcome + "\nSaut pour recommencer."
	_debug.queue_redraw()
