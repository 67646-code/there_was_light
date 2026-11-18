extends SceneTree
## Rejoue un enregistrement sans fenêtre et vérifie qu'il retombe sur le même état final.
## Usage : godot --headless --path . -s tools/replay.gd -- <fichier.json>
## Code de sortie : 0 si identique, 1 si écart, 2 si fichier illisible.


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		print("Usage : godot --headless --path . -s tools/replay.gd -- <fichier.json>")
		quit(2)
		return
	var recording := FightRecording.load_file(args[0])
	if recording == null:
		print("Enregistrement illisible : %s" % args[0])
		quit(2)
		return
	var fight := recording.replay()
	var summary := fight.summary()
	print("Images rejouées : %d" % recording.frame_count())
	print("État final : %s" % JSON.stringify(summary, "  ", false))
	var differences := recording.diff_with(summary)
	if differences.is_empty():
		print("IDENTIQUE à l'enregistrement.")
		quit(0)
	else:
		print("ÉCART (enregistré, rejoué) : %s" % JSON.stringify(differences))
		quit(1)
