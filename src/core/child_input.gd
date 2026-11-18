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


## Encode les commandes de la manette en un entier (pour l'enregistrement).
## `advancing` n'est pas encodé : il est recalculé par ArenaFight.
func to_bits() -> int:
	var bits: int = 0
	bits |= 1 if lantern else 0
	bits |= 2 if release else 0
	bits |= 4 if dodge else 0
	bits |= 8 if jump else 0
	bits |= int(direction) << 4
	bits |= (move + 1) << 6
	return bits


static func from_bits(bits: int) -> ChildInput:
	var i := ChildInput.new()
	i.lantern = bits & 1 != 0
	i.release = bits & 2 != 0
	i.dodge = bits & 4 != 0
	i.jump = bits & 8 != 0
	i.direction = ((bits >> 4) & 3) as CombatTypes.Direction
	i.move = ((bits >> 6) & 3) - 1
	return i


## Copie indépendante (l'enregistrement garde des instantanés immuables).
func copy() -> ChildInput:
	var i := ChildInput.make(lantern, direction, release, dodge, advancing)
	i.move = move
	i.jump = jump
	return i
