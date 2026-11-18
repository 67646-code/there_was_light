class_name FightRecording
extends RefCounted
## Enregistrement d'une partie : réglages, graine et commandes image par image.
## Le combat étant déterministe, rejouer les commandes reproduit exactement la partie.
## Format JSON lisible, pour qu'un humain ou un agent puisse l'ouvrir et le rejouer.

const FORMAT_VERSION: int = 1

var child_path: String = ""
var boss_path: String = ""
var arena_path: String = ""
var feedback_path: String = ""
var rng_seed: int = 0
## Une entrée par image (ChildInput.to_bits), gel compris.
var inputs: PackedInt32Array = PackedInt32Array()
## Résumé de l'état final au moment de l'enregistrement (ArenaFight.summary()).
var final_summary: Dictionary = {}


static func start(
	child: ChildSettings,
	boss: BossData,
	arena: ArenaSettings,
	feedback: FeedbackSettings,
	seed_value: int,
) -> FightRecording:
	var r := FightRecording.new()
	r.child_path = child.resource_path
	r.boss_path = boss.resource_path
	r.arena_path = arena.resource_path
	r.feedback_path = feedback.resource_path if feedback != null else ""
	r.rng_seed = seed_value
	return r


func record(input: ChildInput) -> void:
	inputs.append(input.to_bits())


func frame_count() -> int:
	return inputs.size()


## Crée un combat neuf avec les réglages enregistrés.
func create_fight() -> ArenaFight:
	var feedback: FeedbackSettings = null
	if feedback_path != "":
		feedback = load(feedback_path) as FeedbackSettings
	return ArenaFight.new(
		load(child_path) as ChildSettings,
		load(boss_path) as BossData,
		load(arena_path) as ArenaSettings,
		rng_seed,
		feedback
	)


## Rejoue toute la partie sans affichage et renvoie le combat dans son état final.
func replay() -> ArenaFight:
	var fight := create_fight()
	for bits: int in inputs:
		fight.tick(ChildInput.from_bits(bits))
	return fight


## Différences entre le résumé enregistré et celui d'une relecture (vide = identique).
func diff_with(summary: Dictionary) -> Dictionary:
	var differences := {}
	for key: String in final_summary:
		if not _same(final_summary[key], summary.get(key)):
			differences[key] = [final_summary[key], summary.get(key)]
	return differences


## JSON relit les entiers en flottants : on compare les nombres par valeur.
static func _same(a: Variant, b: Variant) -> bool:
	var numeric := [TYPE_INT, TYPE_FLOAT]
	if typeof(a) in numeric and typeof(b) in numeric:
		return is_equal_approx(float(a), float(b))
	return str(a) == str(b)


func to_dict() -> Dictionary:
	return {
		"version": FORMAT_VERSION,
		"child": child_path,
		"boss": boss_path,
		"arena": arena_path,
		"feedback": feedback_path,
		"seed": rng_seed,
		"inputs": Array(inputs),
		"final": final_summary,
	}


static func from_dict(data: Dictionary) -> FightRecording:
	var r := FightRecording.new()
	r.child_path = str(data.get("child", ""))
	r.boss_path = str(data.get("boss", ""))
	r.arena_path = str(data.get("arena", ""))
	r.feedback_path = str(data.get("feedback", ""))
	r.rng_seed = int(data.get("seed", 0))
	r.inputs = PackedInt32Array(data.get("inputs", []) as Array)
	r.final_summary = data.get("final", {}) as Dictionary
	return r


func save(path: String) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(to_dict()))
	return OK


static func load_file(path: String) -> FightRecording:
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	if not json.data is Dictionary:
		return null
	return from_dict(json.data as Dictionary)
