class_name CombatLog
extends RefCounted
## Journal des derniers événements d'un duel, pour l'affichage de debug.
## Chaque ligne est préfixée par le numéro d'image.

const REASONS: Dictionary = {
	&"guard_broken": "garde brisée",
	&"WHIFF_RECOVERY": "récupération (parade dans le vide)",
	&"RELEASE_WINDUP": "relâche en cours",
	&"STUNNED": "sonné",
	&"PARRY_WINDOW": "fenêtre déjà ouverte",
	&"DEAD": "à terre",
}

var max_entries: int = 8
var entries: Array[String] = []

var _duel: Duel


func _init(duel: Duel, capacity: int = 8) -> void:
	_duel = duel
	max_entries = capacity
	# Méthodes liées et non fonctions anonymes : une fonction anonyme garderait une référence
	# au journal, qui garde le duel, qui garde l'enfant… cycle jamais libéré.
	var child := duel.child
	var dog := duel.dog
	child.perfect_parried.connect(add.bind("Parade parfaite (+1 lumière)"))
	child.guarded.connect(add.bind("Garde (-huile)"))
	child.whiffed.connect(add.bind("Parade dans le vide"))
	child.guard_broken.connect(add.bind("Garde brisée : sonné"))
	child.release_started.connect(_add_formatted.bind("Relâche de %d charge(s)…"))
	child.released.connect(_on_released)
	child.dodged.connect(add.bind("Esquive"))
	child.hurt.connect(_add_formatted.bind("Touché (santé %d)"))
	child.lantern_press_ignored.connect(_on_press_ignored)
	dog.posture_broken.connect(_add_formatted.bind("BRÈCHE phase %d : R1 près du chien"))
	dog.recovered_from_break.connect(_on_dog_recovered)
	dog.phase_changed.connect(_add_formatted.bind("Apaisé → phase %d"))
	dog.pacified.connect(add.bind("Chien apaisé : victoire"))
	duel.soothe_missed.connect(add.bind("Apaisement hors de portée"))


func add(text: String) -> void:
	entries.append("[%d] %s" % [_duel.frame, text])
	while entries.size() > max_entries:
		entries.pop_front()


func _on_dog_recovered() -> void:
	add("Brèche ratée : le chien se relève (posture %d)" % _duel.dog.posture.value())


func _add_formatted(value: int, template: String) -> void:
	add(template % value)


func _on_released(posture: int) -> void:
	if _duel.last_in_range():
		add("Relâche : +%d posture" % posture)
	else:
		add("Relâche hors de portée (%d perdus)" % posture)


func _on_press_ignored(reason: StringName) -> void:
	add("R1 ignoré : %s" % REASONS.get(reason, String(reason)))
