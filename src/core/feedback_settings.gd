class_name FeedbackSettings
extends Resource
## Retours d'impact par événement. Valeurs dans data/feedback.tres.

@export var perfect_parry: ImpactFeedback
@export var guard: ImpactFeedback
@export var whiff: ImpactFeedback
@export var hurt: ImpactFeedback
@export var guard_break: ImpactFeedback
@export var release: ImpactFeedback
@export var posture_break: ImpactFeedback
@export var soothe: ImpactFeedback

@export_group("Signal de parade")
## Flash du chien avant l'impact, pour donner le moment d'appuyer.
@export var parry_cue_enabled: bool = false
## Le flash s'allume tant d'images avant l'impact (limité à la durée de l'anticipation)…
@export var parry_cue_lead_frames: int = 0
## …et dure tant d'images. Réglé pour qu'un appui en réaction tombe dans la fenêtre.
@export var parry_cue_frames: int = 0
