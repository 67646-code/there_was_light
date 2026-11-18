extends Node2D
## Arène du prototype : lit la manette, fait avancer le combat d'une image par image physique
## et laisse la vue l'afficher. Après la fin du combat, « saut » relance une partie.

@export var child_settings: ChildSettings
@export var boss_data: BossData
@export var arena_settings: ArenaSettings
@export var rng_seed: int = 1

var fight: ArenaFight

@onready var _view: ArenaView = %ArenaView
@onready var _message: Label = %Message


func _ready() -> void:
	_restart()


func _physics_process(_delta: float) -> void:
	var input := read_controller()
	if fight.duel.is_over:
		if input.jump:
			_restart()
		return
	fight.tick(input)
	_view.queue_redraw()


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
	fight = ArenaFight.new(child_settings, boss_data, arena_settings, rng_seed)
	fight.duel.ended.connect(_on_fight_ended)
	_view.fight = fight
	_message.text = ""
	_view.queue_redraw()


func _on_fight_ended(child_won: bool) -> void:
	var outcome: String = "Le chien est apaisé." if child_won else "L'enfant est tombé."
	_message.text = outcome + "\nSaut pour recommencer."
