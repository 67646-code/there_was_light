class_name PostureGauge
extends RefCounted
## Posture d'un monstre : monte avec la posture infligée, redescend après un délai sans
## pression, cède (brèche) au maximum. Stockée en sous-unités (× 60) pour un débit entier.

signal broke

const SUB_UNITS: int = 60

var max_value: int = 0
var regen_per_second: int = 0
var regen_delay_frames: int = 0
var is_broken: bool = false

var _value_sub: int = 0
var _frames_without_pressure: int = 0


func _init(boss: BossData) -> void:
	max_value = boss.max_posture
	regen_per_second = boss.posture_regen_per_second
	regen_delay_frames = boss.posture_regen_delay_frames


func value() -> int:
	return _value_sub / SUB_UNITS


## Inflige de la posture. Retourne vrai si la jauge vient de céder.
func add(amount: int) -> bool:
	if is_broken or amount <= 0:
		return false
	_frames_without_pressure = 0
	_value_sub = mini(_value_sub + amount * SUB_UNITS, max_value * SUB_UNITS)
	if _value_sub >= max_value * SUB_UNITS:
		is_broken = true
		broke.emit()
		return true
	return false


## Avance d'une image. `pushed` : la lanterne avance sur le monstre (pression continue).
func tick(pushed: bool) -> void:
	if is_broken:
		return
	if pushed:
		_frames_without_pressure = 0
		return
	_frames_without_pressure += 1
	if _frames_without_pressure > regen_delay_frames:
		_value_sub = maxi(_value_sub - regen_per_second, 0)


func reset() -> void:
	is_broken = false
	_value_sub = 0
	_frames_without_pressure = 0
