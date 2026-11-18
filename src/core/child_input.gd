class_name ChildInput
extends RefCounted
## État des commandes de l'enfant pour une image. On décrit des boutons tenus, pas des appuis :
## la logique détecte elle-même les appuis, ce qui rend l'enregistrement et la relecture simples.

var lantern: bool = false
var release: bool = false
var dodge: bool = false
var direction: CombatTypes.Direction = CombatTypes.Direction.FRONT
## Déplacement horizontal : -1, 0 ou 1.
var move: int = 0
var jump: bool = false
## L'enfant avance lanterne tendue vers le monstre (calculé par ArenaFight, pas par la manette).
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


## Copie indépendante (l'enregistrement garde des instantanés immuables).
func copy() -> ChildInput:
	var i := ChildInput.make(lantern, direction, release, dodge, advancing)
	i.move = move
	i.jump = jump
	return i
