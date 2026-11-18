class_name ChildInput
extends RefCounted
## État des commandes de l'enfant pour une image. On décrit des boutons tenus, pas des appuis :
## la logique détecte elle-même les appuis, ce qui rend l'enregistrement et la relecture simples.

var lantern: bool = false
var release: bool = false
var dodge: bool = false
var direction: CombatTypes.Direction = CombatTypes.Direction.FRONT
## L'enfant se déplace vers le monstre (fourni par la couche jeu).
var advancing: bool = false


static func make(
	lantern_held: bool = false,
	direction_held: CombatTypes.Direction = CombatTypes.Direction.FRONT,
	release_held: bool = false,
	dodge_held: bool = false,
	advancing_now: bool = false,
) -> ChildInput:
	var i := ChildInput.new()
	i.lantern = lantern_held
	i.direction = direction_held
	i.release = release_held
	i.dodge = dodge_held
	i.advancing = advancing_now
	return i
