class_name ChildSettings
extends Resource
## Réglages de l'enfant et de sa lanterne. Valeurs dans data/child_*.tres.
## Durées en images à 60 i/s ; débits « par seconde » en unités entières.
## Les valeurs par défaut sont neutres : la ressource .tres est la seule source des réglages.

@export_group("Santé")
@export var max_health: int = 0
## Invulnérabilité après un coup non paré.
@export var hurt_invulnerability_frames: int = 0

@export_group("Huile")
@export var max_oil: int = 0
## Regagnée quand la lanterne n'est pas tendue.
@export var oil_regen_per_second: int = 0
@export var guard_oil_cost: int = 0
@export var whiff_oil_cost: int = 0
@export var advance_oil_cost_per_second: int = 0
## Durée pendant laquelle l'enfant est sonné quand l'huile tombe à zéro.
@export var guard_break_stun_frames: int = 0
## Huile à retrouver avant de pouvoir parer de nouveau après une garde brisée.
@export var guard_break_recover_oil: int = 0

@export_group("Parade")
## Images, appui compris, pendant lesquelles un impact donne une parade parfaite.
@export var perfect_parry_window_frames: int = 0
@export var perfect_parry_posture: int = 0
@export var perfect_parry_light: int = 0
## Récupération vulnérable après une parade dans le vide.
@export var whiff_recovery_frames: int = 0

@export_group("Lumière et relâche")
@export var max_light: int = 0
## Variante A du test comparatif : pas de relâche.
@export var release_enabled: bool = false
## Posture infligée selon le nombre de charges relâchées (indice 0 = 1 charge).
@export var release_posture_by_charges: Array[int] = []
## Anticipation de la relâche, pendant laquelle l'enfant est exposé.
@export var release_windup_frames: int = 0

@export_group("Déplacement")
## Facteur de vitesse en avançant lanterne tendue (utilisé par la couche jeu).
@export_range(0.0, 1.0) var advance_speed_factor: float = 0.0
@export var dodge_invulnerability_frames: int = 0
@export var dodge_cooldown_frames: int = 0


## Posture infligée par une relâche de `charges` charges ; 0 si rien à relâcher.
func release_posture(charges: int) -> int:
	if charges <= 0 or release_posture_by_charges.is_empty():
		return 0
	var index: int = mini(charges, release_posture_by_charges.size()) - 1
	return release_posture_by_charges[index]
