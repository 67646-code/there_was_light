class_name ImpactEffects
extends Node
## Effets d'impact purement visuels et sonores : tremblement de la caméra, sons provisoires
## (bips générés, en attendant de vrais sons). Le gel et le recul sont dans ArenaFight.

const MIX_RATE: int = 22050
const VOICES: int = 6

@export var camera: Camera2D

var _shake_strength: float = 0.0
var _shake_total: int = 0
var _shake_left: int = 0
var _camera_rest := Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0
var _tones: Dictionary = {}


func _ready() -> void:
	_rng.seed = 1
	if camera != null:
		_camera_rest = camera.offset
	for i: int in VOICES:
		var player := AudioStreamPlayer.new()
		player.volume_db = -12.0
		add_child(player)
		_players.append(player)


func watch(fight: ArenaFight) -> void:
	fight.impact.connect(_on_impact)


func _physics_process(_delta: float) -> void:
	if camera == null:
		return
	if _shake_left <= 0:
		camera.offset = _camera_rest
		return
	_shake_left -= 1
	var amount := _shake_strength * float(_shake_left) / float(maxi(_shake_total, 1))
	camera.offset = (
		_camera_rest + Vector2(_rng.randf_range(-amount, amount), _rng.randf_range(-amount, amount))
	)


func _on_impact(_kind: StringName, fx: ImpactFeedback) -> void:
	if fx.shake_frames > 0 and fx.shake_strength >= _shake_strength * _shake_ratio():
		_shake_strength = fx.shake_strength
		_shake_total = fx.shake_frames
		_shake_left = fx.shake_frames
	if fx.tone_hz > 0.0 and fx.tone_ms > 0:
		_play_tone(fx.tone_hz, fx.tone_ms)


## Part du tremblement en cours qui reste : un petit choc n'écrase pas un gros.
func _shake_ratio() -> float:
	return float(_shake_left) / float(maxi(_shake_total, 1))


func _play_tone(hz: float, ms: int) -> void:
	var key := "%d:%d" % [roundi(hz), ms]
	if not _tones.has(key):
		_tones[key] = make_tone(hz, ms)
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _tones[key] as AudioStreamWAV
	player.play()


## Bip sinusoïdal 16 bits mono avec une enveloppe qui décroît.
static func make_tone(hz: float, ms: int) -> AudioStreamWAV:
	var count: int = MIX_RATE * ms / 1000
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i: int in count:
		var envelope := 1.0 - float(i) / float(count)
		var sample := sin(TAU * hz * float(i) / MIX_RATE) * envelope * envelope
		bytes.encode_s16(i * 2, int(sample * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = bytes
	return wav
