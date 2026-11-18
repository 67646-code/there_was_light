class_name ChildCombatTestBase
extends GutTest
## Base commune des tests de ChildCombat : réglages de la fiche v0 et helpers.
## Réglages construits ici (valeurs de la fiche v0) pour que le réglage de data/ ne casse
## pas les tests. Convention : l'image N est le N-ième tick ; un impact à l'image N est
## résolu juste après le tick N.

const FRONT := CombatTypes.Direction.FRONT
const UP := CombatTypes.Direction.UP
const S := ChildCombat.State
const R := ChildCombat.HitResult

var child: ChildCombat
var bite: AttackData


func before_each() -> void:
	child = ChildCombat.new(_settings())
	bite = AttackData.new()
	bite.parry_direction = FRONT
	bite.health_damage = 1


func _settings() -> ChildSettings:
	var s := ChildSettings.new()
	s.max_health = 5
	s.hurt_invulnerability_frames = 45
	s.max_oil = 100
	s.oil_regen_per_second = 8
	s.guard_oil_cost = 15
	s.whiff_oil_cost = 5
	s.advance_oil_cost_per_second = 15
	s.guard_break_stun_frames = 60
	s.guard_break_recover_oil = 20
	s.perfect_parry_window_frames = 8
	s.perfect_parry_posture = 8
	s.perfect_parry_light = 1
	s.whiff_recovery_frames = 20
	s.max_light = 3
	s.release_enabled = true
	s.release_posture_by_charges = [15, 35, 60]
	s.release_windup_frames = 10
	s.dodge_invulnerability_frames = 12
	s.dodge_cooldown_frames = 30
	return s


## Avance jusqu'à l'image `target` incluse, avec les mêmes commandes tenues.
func _to(target: int, input: ChildInput = ChildInput.make()) -> void:
	while child.frame < target:
		child.tick(input)


func _held(direction: CombatTypes.Direction = FRONT) -> ChildInput:
	return ChildInput.make(true, direction)


## Parade parfaite au tick suivant : appui puis impact sur la même image.
func _perfect_parry_now() -> void:
	_to(child.frame + 1)
	_to(child.frame + 1, _held())
	assert_eq(child.receive_hit(bite), R.PERFECT)
