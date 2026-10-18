extends Button
## Temporary illustrated fighter; presentation can be replaced independently of rules.
signal targeted(unit_id: String)
const ATLAS = preload("res://assets/heroes.png")
var unit_id := ""
var tint := Color.WHITE
var active := false
var chosen := false
var available := false
var artwork: TextureRect
var title: Label
var health: ProgressBar
var energy: ProgressBar
var stats: Label

func _ready() -> void:
	# Inheriting the parent theme can temporarily raise minimum sizes on entry.
	# Apply the intended bar geometry after theme/layout notifications settle.
	await get_tree().process_frame
	health.size = Vector2(156, 11)
	energy.size = Vector2(156, 5)

static func portrait(index: int, full_body: bool = false) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = ATLAS
	var cell := Vector2((index % 4) * 256, (index / 4) * 256)
	texture.region = Rect2(cell + Vector2(10, 8), Vector2(236, 240)) if full_body else Rect2(cell + Vector2(42, 4), Vector2(172, 160))
	return texture

func setup(hero: Dictionary, id: String, color: Color) -> void:
	unit_id = id
	tint = color
	name = id
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	size = Vector2(174, 300)
	pivot_offset = size / 2.0
	artwork = TextureRect.new()
	artwork.texture = portrait(int(hero.index), true)
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.position = Vector2(-8, 24)
	artwork.size = Vector2(190, 234)
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(artwork)
	title = _label(hero.name, Vector2(0, 0), 19)
	title.add_theme_color_override("font_color", tint)
	health = _bar(Vector2(9, 258), Color("8cba7a"))
	energy = _bar(Vector2(9, 273), Color("6cbae0"))
	energy.max_value = 100
	energy.size.y = 5
	stats = _label("", Vector2(0, 282), 12)
	stats.add_theme_constant_override("outline_size", 2)
	pressed.connect(func(): targeted.emit(unit_id))
	tooltip_text = "%s · %s\nPV %d · ATQ %d · DEF %d · VEL %d" % [hero.name, hero.role, hero.hp, hero.attack, hero.defense, hero.speed]

func _label(text_value: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = at
	label.size.x = 174
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color("0b0c12"))
	label.add_theme_constant_override("outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _bar(at: Vector2, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = at
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("15171d")
	background.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)
	add_child(bar)
	bar.size = Vector2(156, 11)
	return bar

func refresh(data: Dictionary, is_active: bool, is_chosen: bool, can_target: bool) -> void:
	active = is_active
	chosen = is_chosen
	available = can_target
	health.max_value = data.maxHp
	health.value = data.hp
	energy.value = data.energy
	stats.text = "%d/%d PV · %d EN" % [data.hp, data.maxHp, data.energy]
	if data.shield > 0: stats.text += " · +%d" % data.shield
	var effects: Array = []
	for status in data.statuses:
		effects.append({"burn": "queimadura", "regen": "regeneração", "weaken": "fraqueza", "expose": "exposição"}[status.type])
	if not effects.is_empty(): stats.text += "\n" + ", ".join(effects)
	artwork.modulate = Color.WHITE if data.hp > 0 else Color(0.35, 0.35, 0.4, 0.45)
	title.text = ("▼ " if active else "") + title.text.trim_prefix("▼ ")
	queue_redraw()

func _draw() -> void:
	if tint == Color.WHITE: return
	var center := Vector2(87, 249)
	draw_ellipse_ring(center, Vector2(76, 13), tint.darkened(0.4), 1.0)
	if active or chosen:
		draw_ellipse_ring(center, Vector2(81, 17), tint if active else Color("ecd0a0"), 3.0)
	if available:
		draw_circle(Vector2(152, 13), 5, Color("ecd0a0"))

func draw_ellipse_ring(center: Vector2, radius: Vector2, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for i in range(49):
		var angle := TAU * i / 48.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(points, color, width, true)
