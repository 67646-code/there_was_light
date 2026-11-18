class_name DebugOverlay
extends Control
## Affichage de debug (F1 / Select) : jauges, états, fenêtre de parade et journal du combat.

const FONT_SIZE: int = 22
const LINE: float = 28.0
const BAR_SIZE := Vector2(260, 16)
const PANEL := Color(0, 0, 0, 0.55)
const TEXT := Color(0.92, 0.92, 0.95)
const DIM := Color(0.6, 0.6, 0.65)
const OIL := Color(0.85, 0.65, 0.2)
const POSTURE := Color(0.55, 0.75, 1.0)
const WINDOW := Color(1.0, 0.95, 0.5)
const OK_COLOR := Color(0.4, 0.9, 0.5)
const KO_COLOR := Color(0.95, 0.35, 0.35)

var fight: ArenaFight
var combat_log: CombatLog


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	if fight == null:
		return
	var font := ThemeDB.fallback_font
	var child := fight.duel.child
	var dog := fight.duel.dog
	var motion := fight.motion
	var origin := Vector2(size.x - 560, 20)
	# Hauteur ajustée au contenu : 7 lignes, 3 interlignes et demi, puis le journal.
	var entries: int = combat_log.entries.size() if combat_log != null else 0
	var height: float = LINE * (8.5 + 1.5 + entries) + 8.0
	draw_rect(Rect2(origin - Vector2(16, 0), Vector2(556, height)), PANEL)
	var y := origin.y + LINE
	var x := origin.x

	_text(font, x, y, "ENFANT  %s" % ChildCombat.State.keys()[child.state], TEXT)
	y += LINE
	_bar(x, y, "Huile", child.oil(), child.settings.max_oil, OIL)
	y += LINE
	var window := child.parry_window_remaining()
	_bar(x, y, "Fenêtre", window, child.settings.perfect_parry_window_frames, WINDOW)
	y += LINE
	var light := "Lumière %d/%d   Santé %d" % [child.light, child.settings.max_light, child.health]
	_text(font, x, y, light, TEXT)
	y += LINE * 1.5

	_text(font, x, y, "CHIEN  %s   phase %d" % [DogBoss.State.keys()[dog.state], dog.phase], TEXT)
	y += LINE
	_bar(x, y, "Posture", dog.posture.value(), dog.posture.max_value, POSTURE)
	y += LINE
	var detail := "Attaque %s (coup %d)" % [dog.attack.id, dog.hit_index + 1]
	if dog.state == DogBoss.State.WINDUP:
		detail += " — impact dans %d" % dog.frames_to_impact()
	elif dog.state == DogBoss.State.BROKEN:
		detail = "Brèche : %d images pour apaiser" % dog.break_frames_remaining()
	_text(font, x, y, detail, TEXT)
	y += LINE * 1.5

	var in_range := fight.duel.last_in_range()
	var range_text := (
		"Distance %d — %s"
		% [roundi(motion.distance()), "À PORTÉE" if in_range else "hors de portée"]
	)
	_text(font, x, y, range_text, OK_COLOR if in_range else KO_COLOR)
	y += LINE * 1.5

	if combat_log != null:
		for entry: String in combat_log.entries:
			_text(font, x, y, entry, DIM)
			y += LINE


func _text(font: Font, x: float, y: float, text: String, color: Color) -> void:
	draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, color)


func _bar(x: float, y: float, label: String, value: int, max_value: int, color: Color) -> void:
	_text(ThemeDB.fallback_font, x, y, "%s %d/%d" % [label, value, max_value], TEXT)
	var pos := Vector2(x + 230, y - BAR_SIZE.y + 2)
	draw_rect(Rect2(pos, BAR_SIZE), Color(1, 1, 1, 0.15))
	var ratio := clampf(float(value) / float(maxi(max_value, 1)), 0.0, 1.0)
	draw_rect(Rect2(pos, Vector2(BAR_SIZE.x * ratio, BAR_SIZE.y)), color)
