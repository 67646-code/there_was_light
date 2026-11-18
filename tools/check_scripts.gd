extends SceneTree
## Charge chaque script, scène et ressource du projet pour détecter les erreurs.
## Usage : godot --headless --path . --script res://tools/check_scripts.gd

const ROOTS: Array[String] = ["res://src", "res://data", "res://tests"]
const EXTENSIONS: Array[String] = ["gd", "tscn", "tres"]

var _failures: Array[String] = []
var _checked: int = 0


func _init() -> void:
	for root: String in ROOTS:
		_scan(root)
	for failure: String in _failures:
		printerr("ÉCHEC : ", failure)
	print("check_scripts : %d fichiers vérifiés, %d en échec." % [_checked, _failures.size()])
	quit(1 if _failures.size() > 0 else 0)


func _scan(dir_path: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		_scan(dir_path.path_join(sub))
	for file: String in dir.get_files():
		if file.get_extension() in EXTENSIONS:
			_check(dir_path.path_join(file))


func _check(path: String) -> void:
	_checked += 1
	var res: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if res == null:
		_failures.append(path + " (chargement impossible)")
		return
	var script: GDScript = res as GDScript
	if script != null and not (script.can_instantiate() or script.is_abstract()):
		_failures.append(path + " (erreur de compilation)")
