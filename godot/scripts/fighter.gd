extends Button
signal targeted(unit_id: String)
const Meter = preload("res://scripts/meter.gd")
const Glyph = preload("res://scripts/glyph.gd")
const ATLAS = preload("res://assets/clean-atlas.png")
const CHARACTER_SHADER = preload("res://shaders/character.gdshader")
const SPECIAL = {0: "veyra", 4: "sylva", 8: "axion", 12: "astra", 16: "vesper", 20: "auren"}
const STATUS_NAMES = {"burn": "Queimadura", "bleed": "Sangramento", "regen": "Regeneração", "weaken": "Ataque −20%", "expose": "Defesa −25%", "empower": "Ataque +20%", "fortify": "Dano recebido −20%", "cover": "Proteção: desvia 35%", "mirror": "Reflete 20% do dano à vida", "riposte": "Contra-ataca: 40% ATQ", "taunt": "Provocação", "emberguard": "Retalia com queimadura", "focus": "Próximo golpe +25%", "seed": "Semente: próximo atacante cura 10%"}
static var texture_cache: Dictionary = {}
static var region_cache: Dictionary = {}
static var pose_regions: Dictionary = {}
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
var display_data: Dictionary = {}
var depth := 1.0
var pose_index := -1
var visual_root: Node2D
var artwork: TextureRect
var resting_art: Texture2D
var material_fx: ShaderMaterial
var title: Label
var health: Control
var energy: Control
var shield: Control
var shield_label: Label
var stats: Label
var status_label: Label
var indicator: Label
var affinity_label: Label
var relationship: Label
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
	resting_art = portrait(int(hero.index), true)
	artwork.texture = resting_art
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.position = Vector2(-94, -200)
	artwork.size = Vector2(188, 200)
	artwork.flip_h = id.begins_with("1-")
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material_fx = ShaderMaterial.new()
	material_fx.shader = CHARACTER_SHADER
	artwork.material = material_fx
	visual_root.add_child(artwork)
	indicator = _label("EM AÇÃO", 11, Color("f8dc9d"))
	indicator.size = Vector2(186, 18)
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(indicator)
	affinity_label = _label("", 12, color)
	affinity_label.size = Vector2(186, 20)
	affinity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	affinity_label.text = {"igneo": "ÍGNEO", "natural": "NATURAL", "tecnico": "TÉCNICO", "arcano": "ARCANO", "sombrio": "SOMBRIO", "lumi": "LUMI"}[hero.classId]
	add_child(affinity_label)
	relationship = _label("", 12, Color("ffd7a2"))
	relationship.size = Vector2(186, 20)
	relationship.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(relationship)
	plate = Panel.new()
	plate.position = Vector2(5, 264)
	plate.size = Vector2(176, 128)
	plate.clip_contents = true
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.z_index = 20
	var box := StyleBoxFlat.new()
	box.bg_color = Color("091321f5")
	box.border_color = color.darkened(0.5)
	box.set_border_width_all(1)
	box.set_corner_radius_all(7)
	plate.add_theme_stylebox_override("panel", box)
	add_child(plate)
	# Keep the turn/target marker in the card header, clear of feet and bars.
	remove_child(indicator)
	plate.add_child(indicator)
	indicator.position = Vector2(125, 4)
	indicator.size = Vector2(14, 18)
	title = _label(hero.name, 15, Color("f0f4ff"))
	title.position = Vector2(9, 1)
	title.size = Vector2(136, 23)
	plate.add_child(title)
	var glyph = Glyph.new()
	glyph.symbol = hero.classId
	glyph.tint = color
	glyph.position = Vector2(146, 5)
	glyph.size = Vector2(20, 20)
	plate.add_child(glyph)
	var class_caption := _label(affinity_label.text, 10, color)
	class_caption.position = Vector2(9, 23)
	class_caption.size = Vector2(158, 16)
	plate.add_child(class_caption)
	health = Meter.new()
	health.position = Vector2(9, 42)
	health.size = Vector2(158, 8)
	plate.add_child(health)
	energy = Meter.new()
	energy.fill = Color("9586dc")
	energy.position = Vector2(9, 53)
	energy.size = Vector2(158, 4)
	plate.add_child(energy)
	stats = _label("", 11, Color("cedaee"))
	stats.position = Vector2(9, 59)
	stats.size = Vector2(158, 16)
	plate.add_child(stats)
	shield_label = _label("", 11, Color("83d8ff"))
	shield_label.position = Vector2(9, 76)
	shield_label.size = Vector2(158, 16)
	plate.add_child(shield_label)
	shield = Meter.new()
	shield.fill = Color("62d0ff")
	shield.position = Vector2(9, 93)
	shield.size = Vector2(158, 4)
	plate.add_child(shield)
	status_label = _label("", 10, Color("f2c59c"))
	status_label.position = Vector2(9, 101)
	status_label.size = Vector2(158, 26)
	status_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	status_label.max_lines_visible = 2
	plate.add_child(status_label)
	pressed.connect(func(): targeted.emit(unit_id))
	base_tooltip = "%s · %s\nPV %d · ATQ %d · DEF %d · VEL %d" % [hero.name, hero.role, hero.hp, hero.attack, hero.defense, hero.speed]
	tooltip_text = base_tooltip
	set_depth(1.0)

func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("06101b"))
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func set_depth(value: float) -> void:
	depth = value
	visual_root.scale = Vector2.ONE * depth
	var top := 257 - 200 * depth
	affinity_label.position = Vector2(0, top - 23)
	relationship.position = Vector2(0, top - 44)

func set_relationship(multiplier: float, relevant: bool) -> void:
	relationship.visible = relevant and not dead and multiplier != 1.0
	relationship.text = "VULNERÁVEL +25%" if multiplier > 1 else "RESISTENTE −15%"
	relationship.add_theme_color_override("font_color", Color("ffb998") if multiplier > 1 else Color("a6d9fa"))

func foot_position() -> Vector2:
	return position + visual_root.position

func hit_position() -> Vector2:
	return foot_position() - Vector2(0, 108 * depth)

func set_pose(frame: int) -> void:
	pose_index = frame
	if frame < 0:
		artwork.texture = resting_art
		artwork.position = Vector2(-94, -200)
		artwork.size = Vector2(188, 200)
		material_fx.set_shader_parameter("exclusion_count", 0)
		return
	if pose_regions.is_empty() and FileAccess.file_exists("res://data/pose-regions.json"):
		pose_regions = JSON.parse_string(FileAccess.get_file_as_string("res://data/pose-regions.json"))
	if not pose_regions.has(hero_id): return
	var key := hero_id + "-poses"
	if not texture_cache.has(key): texture_cache[key] = load("res://assets/poses/%s.png" % hero_id)
	var texture := AtlasTexture.new()
	texture.atlas = texture_cache[key]
	texture.filter_clip = true
	var data: Dictionary = pose_regions[hero_id].frames[frame]
	var rect: Array = data.rect
	texture.region = Rect2(rect[0], rect[1], rect[2], rect[3])
	artwork.texture = texture
	var factor: float = pose_regions[hero_id].scale
	artwork.size = Vector2(rect[2], rect[3]) * factor
	var foot_x: float = float(rect[2]) - data.foot[0] if artwork.flip_h else float(data.foot[0])
	artwork.position = -Vector2(foot_x, data.foot[1]) * factor
	var excluded: Array[Vector4] = []
	for region in data.exclude: excluded.append(Vector4(region[0], region[1], region[2], region[3]))
	while excluded.size() < 8: excluded.append(Vector4.ZERO)
	material_fx.set_shader_parameter("excluded_regions", PackedVector4Array(excluded.slice(0, 8)))
	material_fx.set_shader_parameter("exclusion_count", mini(8, data.exclude.size()))

func _has_point(point: Vector2) -> bool:
	return Rect2(Vector2(93 - 90 * depth, 257 - 200 * depth), Vector2(180 * depth, 200 * depth)).has_point(point) or plate.get_rect().has_point(point)

func _process(delta: float) -> void:
	if not is_instance_valid(visual_root): return
	elapsed += delta
	if not posing:
		visual_root.scale = Vector2(1, 1 + sin(elapsed * 1.8 + hero_id.length()) * 0.006) * depth if motion_enabled and not dead else Vector2.ONE * depth
		material_fx.set_shader_parameter("bend", sin(elapsed * 1.4) * 1.8 if motion_enabled and not dead else 0.0)
	queue_redraw()

func reset_pose() -> void:
	posing = false
	set_pose(-1)
	visual_root.position = Vector2(93, 257)
	visual_root.rotation = 0
	visual_root.scale = Vector2.ONE * depth
	visual_root.modulate = Color.WHITE
	visual_root.z_index = 0
	material_fx.set_shader_parameter("flash", 0.0)
	material_fx.set_shader_parameter("bend", 0.0)

func refresh(data: Dictionary, is_active: bool, is_chosen: bool, can_target: bool) -> void:
	display_data = data.duplicate(true)
	active = is_active
	chosen = is_chosen
	available = can_target
	dead = data.hp <= 0
	if dead: relationship.visible = false
	health.max_value = data.maxHp
	health.value = data.hp
	energy.value = data.energy
	shield.max_value = round(data.maxHp * 0.6)
	shield.value = data.shield
	shield_label.text = "ESCUDO  %d" % data.shield
	shield_label.modulate.a = 1.0 if data.shield > 0 else 0.55
	stats.text = "%d/%d PV · %d EN" % [data.hp, data.maxHp, data.energy]
	var states: Array = []
	var compact: Array = []
	if data.guarding:
		states.append("Defesa: −35% de dano até o próximo turno")
		compact.append("Defesa")
	for status in data.statuses:
		var duration: int = int(status.turns)
		states.append("%s · %s" % [STATUS_NAMES.get(status.type, status.type), "%d turno(s) restante(s)" % duration if duration > 0 else "expira após esta ação"])
		compact.append("%s %s" % [{"burn": "Queima", "bleed": "Sangra", "regen": "Regen", "weaken": "ATQ↓", "expose": "DEF↓", "empower": "ATQ↑", "fortify": "Fortif.", "cover": "Proteg.", "mirror": "Reflexo", "riposte": "Contra", "taunt": "Provoca", "emberguard": "Brasa", "focus": "Foco", "seed": "Semente"}.get(status.type, status.type), "%dT" % duration if duration > 0 else "•"])
	if compact.size() > 4: compact = compact.slice(0, 3) + ["+%d estados" % (compact.size() - 3)]
	var split := ceili(compact.size() / 2.0) if compact.size() > 2 else compact.size()
	status_label.text = "DERROTADO" if dead else (" · ".join(compact.slice(0, split)) + ("\n" + " · ".join(compact.slice(split)) if compact.size() > 2 else ""))
	status_label.tooltip_text = "\n".join(states)
	tooltip_text = base_tooltip + "\nEscudo: %d / %d máximo" % [data.shield, int(shield.max_value)] + ("\n\nESTADOS\n" + "\n".join(states) if not states.is_empty() else "")
	artwork.modulate = Color(0.35, 0.4, 0.5, 0.4) if dead else Color.WHITE
	indicator.text = "◆" if chosen and available else "●"
	indicator.visible = (active or (chosen and available)) and not dead
	var box: StyleBoxFlat = plate.get_theme_stylebox("panel")
	box.border_color = tint if active else (Color("e5c38c") if chosen and available else tint.darkened(0.6))
	box.set_border_width_all(2 if active or (chosen and available) else 1)
	plate.queue_redraw()
	queue_redraw()

func apply_tick(event: Dictionary) -> void:
	var data := display_data.duplicate(true)
	data.hp = event.hpAfter
	data.shield = event.shieldAfter
	data.guarding = false
	if event.has("remaining"):
		var type: String = "regen" if event.type == "heal" else event.type
		for status in data.statuses:
			if status.type == type: status.turns = event.remaining
		data.statuses = data.statuses.filter(func(s): return s.turns > 0 or not s.type in ["burn", "bleed", "regen"])
	refresh(data, true, false, false)

func _draw() -> void:
	if not is_instance_valid(visual_root): return
	var center := Vector2(93, 258)
	var points := PackedVector2Array()
	for i in range(49): points.append(center + Vector2(cos(TAU * i / 48.0) * 65 * depth, sin(TAU * i / 48.0) * 10 * depth))
	draw_colored_polygon(points, Color(0, 0, 0, 0.45))
	if active or chosen or available:
		var ring := tint if active else Color("e5c38c")
		ring.a = 0.9 if active or chosen else 0.25
		draw_polyline(points, ring, 2 if active or chosen else 1, true)
