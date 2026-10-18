extends Button
signal targeted(unit_id: String)
const Meter = preload("res://scripts/meter.gd")
const Glyph = preload("res://scripts/glyph.gd")
const ATLAS = preload("res://assets/clean-atlas.png")
const CHARACTER_SHADER = preload("res://shaders/character.gdshader")
const SPECIAL = {0: "veyra", 4: "sylva", 8: "axion", 12: "astra", 16: "vesper", 20: "auren"}
static var texture_cache: Dictionary = {}
static var region_cache: Dictionary = {}
var unit_id := ""
var hero_id := ""
var tint := Color.WHITE
var active := false
var chosen := false
var available := false
var motion_enabled := true
var posing := false
var elapsed := 0.0
var dead := false
var base_tooltip := ""
var visual_root: Node2D
var artwork: TextureRect
var material_fx: ShaderMaterial
var title: Label
var health: Control
var energy: Control
var stats: Label
var status_label: Label
var indicator: Label
var plate: Panel

static func portrait(index: int, full_body: bool = false) -> Texture2D:
	var texture := AtlasTexture.new()
	texture.filter_clip = true
	if region_cache.is_empty(): region_cache = JSON.parse_string(FileAccess.get_file_as_string("res://data/art-regions.json"))
	if SPECIAL.has(index):
		var id: String = SPECIAL[index]
		if not texture_cache.has(id): texture_cache[id] = load("res://assets/characters/%s.png" % id)
		texture.atlas = texture_cache[id]
		var region: Array = region_cache[id]["body" if full_body else "portrait"]
		texture.region = Rect2(region[0], region[1], region[2], region[3])
	else:
		texture.atlas = ATLAS
		var bounds: Array = region_cache._legacy[str(index)]
		var region := Rect2(bounds[0], bounds[1], bounds[2], bounds[3])
		texture.region = region if full_body else Rect2(region.position + Vector2(region.size.x * 0.15, 0), Vector2(region.size.x * 0.7, region.size.y * 0.6))
	return texture

func setup(hero: Dictionary, id: String, color: Color) -> void:
	unit_id = id
	hero_id = hero.id
	tint = color
	name = id
	flat = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	size = Vector2(186, 350)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for style in ["normal", "pressed", "hover", "disabled", "hover_pressed"]:
		add_theme_stylebox_override(style, StyleBoxEmpty.new())
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color(0, 0, 0, 0)
	focus.border_color = color
	focus.set_border_width_all(1)
	focus.set_corner_radius_all(8)
	add_theme_stylebox_override("focus", focus)
	visual_root = Node2D.new()
	visual_root.position = Vector2(93, 257)
	add_child(visual_root)
	artwork = TextureRect.new()
	artwork.texture = portrait(int(hero.index), true)
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.position = Vector2(-94, -242)
	artwork.size = Vector2(188, 242)
	artwork.flip_h = id.begins_with("1-")
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material_fx = ShaderMaterial.new()
	material_fx.shader = CHARACTER_SHADER
	artwork.material = material_fx
	visual_root.add_child(artwork)
	indicator = _label("SUA VEZ", 12, color)
	indicator.position = Vector2(0, 0)
	indicator.size.x = 186
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(indicator)
	plate = Panel.new()
	plate.position = Vector2(5, 264)
	plate.size = Vector2(176, 86)
	plate.clip_contents = true
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color("0a1322f5")
	box.border_color = color.darkened(0.5)
	box.set_border_width_all(1)
	box.set_corner_radius_all(7)
	box.content_margin_left = 9
	box.content_margin_right = 9
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	plate.add_theme_stylebox_override("panel", box)
	add_child(plate)
	title = _label(hero.name, 15, Color("f0f4ff"))
	title.position = Vector2(9, 1)
	title.size = Vector2(136, 24)
	plate.add_child(title)
	var glyph = Glyph.new()
	glyph.symbol = hero.classId
	glyph.tint = color
	glyph.custom_minimum_size = Vector2(16, 16)
	glyph.position = Vector2(148, 5)
	glyph.size = Vector2(16, 16)
	plate.add_child(glyph)
	health = Meter.new()
	health.position = Vector2(9, 28)
	health.size = Vector2(158, 8)
	plate.add_child(health)
	energy = Meter.new()
	energy.fill = Color("63bdea")
	energy.position = Vector2(9, 39)
	energy.size = Vector2(158, 4)
	plate.add_child(energy)
	stats = _label("", 12, Color("cedaee"))
	stats.position = Vector2(9, 46)
	stats.size = Vector2(158, 20)
	plate.add_child(stats)
	status_label = _label("", 10, Color("e8bf92"))
	status_label.position = Vector2(9, 68)
	status_label.size = Vector2(158, 16)
	plate.add_child(status_label)
	pressed.connect(func(): targeted.emit(unit_id))
	base_tooltip = "%s · %s\nPV %d · ATQ %d · DEF %d · VEL %d" % [hero.name, hero.role, hero.hp, hero.attack, hero.defense, hero.speed]
	tooltip_text = base_tooltip

func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _process(delta: float) -> void:
	if not is_instance_valid(visual_root): return
	elapsed += delta
	if not posing:
		visual_root.scale = Vector2(1, 1 + sin(elapsed * 1.8 + hero_id.length()) * 0.006) if motion_enabled and not dead else Vector2.ONE
		material_fx.set_shader_parameter("bend", sin(elapsed * 1.4) * 1.8 if motion_enabled and not dead else 0.0)
	queue_redraw()

func reset_pose() -> void:
	posing = false
	visual_root.position = Vector2(93, 257)
	visual_root.rotation = 0
	visual_root.scale = Vector2.ONE
	visual_root.modulate = Color.WHITE
	visual_root.z_index = 0
	material_fx.set_shader_parameter("flash", 0.0)
	material_fx.set_shader_parameter("bend", 0.0)

func refresh(data: Dictionary, is_active: bool, is_chosen: bool, can_target: bool) -> void:
	active = is_active
	chosen = is_chosen
	available = can_target
	dead = data.hp <= 0
	health.max_value = data.maxHp
	health.value = data.hp
	health.shield_value = data.shield
	energy.value = data.energy
	stats.text = "%d/%d PV  ·  %d EN" % [data.hp, data.maxHp, data.energy]
	var states: Array = []
	if data.shield > 0: states.append("BARREIRA %d" % data.shield)
	if data.guarding: states.append("DEFESA")
	for status in data.statuses:
		states.append("%s %dT" % [{"burn": "QUEIMA", "regen": "REGEN", "weaken": "FRACO", "expose": "EXPOSTO"}[status.type], maxi(1, status.turns)])
	status_label.text = "DERROTADO" if dead else ((states[0] + (" +%d" % (states.size() - 1) if states.size() > 1 else "")) if not states.is_empty() else "")
	status_label.tooltip_text = "\n".join(states)
	tooltip_text = base_tooltip + ("\n\nESTADOS\n" + "\n".join(states) if not states.is_empty() else "")
	status_label.visible = not states.is_empty() or dead
	artwork.modulate = Color(0.35, 0.4, 0.5, 0.4) if dead else Color.WHITE
	indicator.text = "ALVO" if chosen and available else "EM AÇÃO"
	indicator.visible = (active or (chosen and available)) and not dead
	var box: StyleBoxFlat = plate.get_theme_stylebox("panel")
	box.border_color = tint if active else (Color("e5c38c") if chosen and available else tint.darkened(0.6))
	box.set_border_width_all(2 if active or (chosen and available) else 1)
	plate.queue_redraw()
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(visual_root): return
	var center := Vector2(93, 258)
	var points := PackedVector2Array()
	for i in range(49): points.append(center + Vector2(cos(TAU * i / 48.0) * 73, sin(TAU * i / 48.0) * 11))
	draw_colored_polygon(points, Color(0, 0, 0, 0.45))
	if active or chosen or available:
		var ring := tint if active else Color("e5c38c")
		ring.a = 0.9 if active or chosen else 0.25
		draw_polyline(points, ring, 2 if active or chosen else 1, true)
