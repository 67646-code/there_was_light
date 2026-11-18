class_name DogBoss
extends RefCounted
## Logique du chien errant : enchaînement d'attaques (anticipation, impact, récupération),
## posture, brèche, apaisement, deux phases. Aléatoire à graine explicite.
## Le premier coup est anticipé dès l'image 0 : une morsure de 24 images frappe à l'image 24.

signal attack_started(attack: AttackData)
signal impact_started(attack: AttackData, hit_index: int)
signal posture_broken(phase: int)
signal phase_changed(phase: int)
signal recovered_from_break
signal pacified

enum State { WINDUP, ACTIVE, RECOVERY, BROKEN, PACIFIED }

var data: BossData
var posture: PostureGauge
var frame: int = 0
var phase: int = 1
var state: State = State.WINDUP
var attack: AttackData
var hit_index: int = 0

var _rng := RandomNumberGenerator.new()
var _state_start: int = 0
var _hit_resolved: bool = false


func _init(boss_data: BossData, rng_seed: int, child_is_far: bool = false) -> void:
	data = boss_data
	posture = PostureGauge.new(data)
	_rng.seed = rng_seed
	_start_attack(child_is_far)


## Avance d'une image. `child_is_far` oriente le choix des attaques ; `pushed` : la lanterne
## avance sur le chien et bloque la régénération de sa posture.
func tick(child_is_far: bool, pushed: bool) -> void:
	frame += 1
	if state != State.BROKEN and state != State.PACIFIED:
		posture.tick(pushed)
	var elapsed: int = frame - _state_start
	match state:
		State.WINDUP:
			if elapsed >= current_windup():
				_hit_resolved = false
				_enter(State.ACTIVE)
				impact_started.emit(attack, hit_index)
		State.ACTIVE:
			if elapsed >= attack.active_frames:
				if hit_index + 1 < attack.hit_count:
					hit_index += 1
					_enter(State.WINDUP)
				else:
					_enter(State.RECOVERY)
		State.RECOVERY:
			if elapsed >= attack.recovery_frames:
				_start_attack(child_is_far)
		State.BROKEN:
			if elapsed >= data.break_stun_frames:
				posture.reset()
				recovered_from_break.emit()
				_start_attack(child_is_far)


## Attaque dont l'impact est en cours et pas encore résolu sur l'enfant, sinon null.
func pending_hit() -> AttackData:
	if state == State.ACTIVE and not _hit_resolved:
		return attack
	return null


func mark_hit_resolved() -> void:
	_hit_resolved = true


## Inflige de la posture ; à la brèche, le chien est sonné et l'attaque en cours s'arrête.
func take_posture(amount: int) -> void:
	if state == State.BROKEN or state == State.PACIFIED:
		return
	if posture.add(amount):
		_enter(State.BROKEN)
		posture_broken.emit(phase)


## L'enfant lève la lanterne sur le chien en brèche : fin de phase ou fin du combat.
func soothe() -> bool:
	if state != State.BROKEN:
		return false
	if phase >= data.phase_count():
		_enter(State.PACIFIED)
		pacified.emit()
		return true
	phase += 1
	posture.reset()
	phase_changed.emit(phase)
	_start_attack(false)
	return true


## Anticipation du coup en cours, phase comprise.
func current_windup() -> int:
	return attack.windup_for_hit(hit_index, data.windup_percent_for_phase(phase))


## Images restantes avant le prochain impact (0 hors anticipation).
func frames_to_impact() -> int:
	if state != State.WINDUP:
		return 0
	return current_windup() - (frame - _state_start)


## Images restantes de la brèche (0 hors brèche).
func break_frames_remaining() -> int:
	if state != State.BROKEN:
		return 0
	return data.break_stun_frames - (frame - _state_start)


func _start_attack(child_is_far: bool) -> void:
	attack = _choose_attack(child_is_far)
	hit_index = 0
	_enter(State.WINDUP)
	attack_started.emit(attack)


func _choose_attack(child_is_far: bool) -> AttackData:
	var all := data.attacks_for_phase(phase)
	var fitting: Array[AttackData] = []
	for a: AttackData in all:
		if a.ranged == child_is_far:
			fitting.append(a)
	if fitting.is_empty():
		fitting = all
	return fitting[_rng.randi_range(0, fitting.size() - 1)]


func _enter(new_state: State) -> void:
	state = new_state
	_state_start = frame
