class_name BossData
extends Resource
## Réglages d'un boss : posture, brèche, attaques par phase. Valeurs dans data/boss_*.tres.

@export var id: StringName = &""

@export_group("Posture")
@export var max_posture: int = 0
@export var posture_regen_per_second: int = 0
## Images sans pression avant que la posture commence à redescendre.
@export var posture_regen_delay_frames: int = 0
## Durée de la brèche (monstre sonné, apaisable).
@export var break_stun_frames: int = 0

@export_group("Phases")
@export var phase_1_attacks: Array[AttackData] = []
@export var phase_2_attacks: Array[AttackData] = []
## Anticipations de la phase 2, en pourcentage de leur valeur de base.
@export_range(1, 200) var phase_2_windup_percent: int = 100


func phase_count() -> int:
	return 2


## Attaques disponibles dans la phase `phase` (1 ou 2).
func attacks_for_phase(phase: int) -> Array[AttackData]:
	return phase_1_attacks if phase == 1 else phase_2_attacks


## Pourcentage d'anticipation appliqué dans la phase `phase`.
func windup_percent_for_phase(phase: int) -> int:
	return 100 if phase == 1 else phase_2_windup_percent
