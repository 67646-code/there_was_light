class_name ImpactFeedback
extends Resource
## Retour d'impact d'un événement de combat : gel, recul, tremblement, son provisoire.

## Gel du combat (hitstop), en images.
@export var hitstop_frames: int = 0
## Recul de l'enfant, en pixels, loin du chien.
@export var child_knockback: float = 0.0
## Recul du chien, en pixels, loin de l'enfant.
@export var dog_knockback: float = 0.0
## Durée du recul, en images.
@export var knockback_frames: int = 0
## Amplitude du tremblement d'écran, en pixels.
@export var shake_strength: float = 0.0
@export var shake_frames: int = 0
## Son provisoire : fréquence (Hz) et durée (ms). 0 = pas de son.
@export var tone_hz: float = 0.0
@export var tone_ms: int = 0
