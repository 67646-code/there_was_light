class_name ChildCombat
extends RefCounted
## Logique de combat de l'enfant, image par image : huile, lumière, parade, garde, relâche, santé.
## Ordre dans une image : tick(entrées) puis, éventuellement, receive_hit(attaque).
## L'huile est stockée en « sous-unités » (× 60) pour que les débits par seconde restent entiers.

signal perfect_parried
signal guarded
signal guard_broken
signal whiffed
signal release_started(charges: int)
signal released(posture: int)
signal dodged
signal hurt(health: int)
signal died

enum State { NEUTRAL, PARRY_WINDOW, GUARD, WHIFF_RECOVERY, RELEASE_WINDUP, STUNNED, DEAD }
enum HitResult { PERFECT, GUARD, HURT, AVOIDED }

const SUB_UNITS: int = 60

var settings: ChildSettings
## Numéro de l'image courante (1 au premier tick).
var frame: int = 0
var state: State = State.NEUTRAL
var health: int = 0
var light: int = 0
## Garde brisée : impossible de parer tant que l'huile n'est pas remontée.
var guard_is_broken: bool = false

var _oil_sub: int = 0
var _state_start: int = 0
var _direction: CombatTypes.Direction = CombatTypes.Direction.FRONT
var _lantern_held: bool = false
var _pushing: bool = false
var _pending_release_charges: int = 0
var _hurt_invulnerable_until: int = -1
var _dodge_invulnerable_until: int = -1
var _dodge_ready_at: int = 0
var _prev: ChildInput = ChildInput.new()


func _init(child_settings: ChildSettings) -> void:
	settings = child_settings
	health = settings.max_health
	_oil_sub = settings.max_oil * SUB_UNITS


## Avance d'une image avec les commandes tenues pendant cette image.
func tick(input: ChildInput) -> void:
	frame += 1
	if state == State.DEAD:
		return
	_lantern_held = input.lantern
	_direction = input.direction
	_advance_state()
	_handle_presses(input)
	_update_oil(input)
	_prev = input


## Résout un impact sur l'enfant pendant l'image courante.
func receive_hit(attack: AttackData) -> HitResult:
	if state == State.DEAD or is_invulnerable():
		return HitResult.AVOIDED
	if is_lantern_raised():
		if state == State.PARRY_WINDOW and _direction == attack.parry_direction:
			_perfect_parry()
			return HitResult.PERFECT
		_guard_hit()
		return HitResult.GUARD
	_take_damage(attack.health_damage)
	return HitResult.HURT


## L'appui en cours a servi à autre chose qu'une parade (apaiser) : pas de parade dans le vide.
func consume_lantern_press() -> void:
	if state == State.PARRY_WINDOW:
		_enter(State.GUARD if _lantern_held else State.NEUTRAL)


func lantern_direction() -> CombatTypes.Direction:
	return _direction


func oil() -> int:
	return _oil_sub / SUB_UNITS


func is_lantern_raised() -> bool:
	return state == State.PARRY_WINDOW or state == State.GUARD


func is_invulnerable() -> bool:
	return frame <= _hurt_invulnerable_until or frame <= _dodge_invulnerable_until


## Lanterne tendue en avançant : bloque la régénération de posture du monstre.
func is_pushing() -> bool:
	return _pushing


## Images écoulées dans l'état courant (0 à l'image d'entrée).
func state_elapsed() -> int:
	return frame - _state_start


## Images restantes de la fenêtre de parade parfaite (0 hors fenêtre).
func parry_window_remaining() -> int:
	if state != State.PARRY_WINDOW:
		return 0
	return settings.perfect_parry_window_frames - state_elapsed()


func _advance_state() -> void:
	var elapsed: int = state_elapsed()
	match state:
		State.PARRY_WINDOW:
			if elapsed >= settings.perfect_parry_window_frames:
				if _lantern_held:
					_enter(State.GUARD)
				else:
					_whiff()
		State.WHIFF_RECOVERY:
			if elapsed >= settings.whiff_recovery_frames:
				_enter(State.NEUTRAL)
		State.RELEASE_WINDUP:
			if elapsed >= settings.release_windup_frames:
				_finish_release()
		State.STUNNED:
			if elapsed >= settings.guard_break_stun_frames:
				_enter(State.NEUTRAL)
		State.GUARD:
			if not _lantern_held:
				_enter(State.NEUTRAL)


func _handle_presses(input: ChildInput) -> void:
	if input.dodge and not _prev.dodge:
		_try_dodge()
	if input.release and not _prev.release:
		_try_release()
	if input.lantern and not _prev.lantern and state == State.NEUTRAL and not guard_is_broken:
		_enter(State.PARRY_WINDOW)


func _update_oil(input: ChildInput) -> void:
	_pushing = is_lantern_raised() and input.advancing
	if _pushing:
		_spend_oil_sub(settings.advance_oil_cost_per_second)
	elif not is_lantern_raised():
		var max_sub: int = settings.max_oil * SUB_UNITS
		_oil_sub = mini(_oil_sub + settings.oil_regen_per_second, max_sub)
	if guard_is_broken and _oil_sub >= settings.guard_break_recover_oil * SUB_UNITS:
		guard_is_broken = false


func _can_act() -> bool:
	return state == State.NEUTRAL or is_lantern_raised()


func _try_dodge() -> void:
	if not _can_act() or frame < _dodge_ready_at:
		return
	_enter(State.NEUTRAL)
	_dodge_invulnerable_until = frame + settings.dodge_invulnerability_frames - 1
	_dodge_ready_at = frame + settings.dodge_cooldown_frames
	dodged.emit()


func _try_release() -> void:
	if not settings.release_enabled or light <= 0 or not _can_act():
		return
	_pending_release_charges = light
	_enter(State.RELEASE_WINDUP)
	release_started.emit(light)


func _finish_release() -> void:
	var posture: int = settings.release_posture(_pending_release_charges)
	light -= _pending_release_charges
	_pending_release_charges = 0
	_enter(State.GUARD if _lantern_held else State.NEUTRAL)
	released.emit(posture)


func _perfect_parry() -> void:
	light = mini(light + settings.perfect_parry_light, settings.max_light)
	_enter(State.GUARD if _lantern_held else State.NEUTRAL)
	perfect_parried.emit()


func _guard_hit() -> void:
	guarded.emit()
	_spend_oil_sub(settings.guard_oil_cost * SUB_UNITS)


func _whiff() -> void:
	_enter(State.WHIFF_RECOVERY)
	whiffed.emit()
	_spend_oil_sub(settings.whiff_oil_cost * SUB_UNITS)


## Retire de l'huile ; à zéro, la garde se brise et l'enfant est sonné.
func _spend_oil_sub(amount: int) -> void:
	_oil_sub = maxi(_oil_sub - amount, 0)
	if _oil_sub == 0 and not guard_is_broken:
		guard_is_broken = true
		_pushing = false
		_pending_release_charges = 0
		_enter(State.STUNNED)
		guard_broken.emit()


func _take_damage(amount: int) -> void:
	health = maxi(health - amount, 0)
	_hurt_invulnerable_until = frame + settings.hurt_invulnerability_frames
	if state == State.RELEASE_WINDUP:
		# Relâche interrompue : les charges sont conservées.
		_pending_release_charges = 0
		_enter(State.NEUTRAL)
	hurt.emit(health)
	if health == 0:
		_enter(State.DEAD)
		died.emit()


func _enter(new_state: State) -> void:
	state = new_state
	_state_start = frame
