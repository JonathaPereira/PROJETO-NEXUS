extends Control
## One anchored, readable receipt per affected fighter. These are visual values only.
var lines: Array = []
var target_name := ""
var shield_capacity := 0
var shield_remaining := -1
var accent := Color("ffb49d")
var lifetime := 1.65
var elapsed := 0.0
var rows: Array = []
var font: Font
var critical := false
var protected := false
var content_height := 0.0

func configure(value: Array, name_value: String, capacity: int, remaining: int) -> void:
	lines = value.duplicate(true)
	target_name = name_value
	shield_capacity = capacity
	shield_remaining = remaining
	critical = lines.any(func(line): return str(line[0]) == "CRÍTICO!")
	protected = lines.any(func(line): return str(line[0]) == "VIDA PROTEGIDA")
	if critical: accent = Color("ffd27d")
	elif protected or lines.any(func(line): return str(line[0]).contains("ESCUDO")): accent = Color("80dcff")
	elif lines.any(func(line): return str(line[0]).begins_with("+")): accent = Color("8df0c4")
	rows.clear()
	# Headers and large values have different type sizes; effect labels remain exact.
	for line in lines:
		var value_text := str(line[0])
		if value_text == "CRÍTICO!": continue
		var major: bool = int(line[2]) >= 18
		var row_size := 27 if major and (value_text.ends_with("VIDA") or value_text.ends_with("ESCUDO")) else 16 if major else 11
		if value_text == "VIDA PROTEGIDA": row_size = 15
		rows.append({"text": value_text, "color": Color(str(line[1])), "size": row_size, "height": row_size + 4})
	content_height = 29.0
	for row in rows: content_height += row.height
	if shield_remaining >= 0: content_height += 8
	size = Vector2(188, maxf(64, content_height + 7))
	custom_minimum_size = size

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = 80
	var readable := FontVariation.new()
	readable.base_font = load("res://assets/space-grotesk.ttf")
	readable.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700.0}
	font = readable
	pivot_offset = size * Vector2(0.5, 0.35)

func _process(delta: float) -> void:
	elapsed += delta
	# Settle into place quickly, hold still for reading, fade without drifting over meters.
	var enter := clampf(elapsed / 0.11, 0, 1)
	var leave := clampf((lifetime - elapsed) / 0.28, 0, 1)
	modulate.a = minf(enter, leave)
	scale = Vector2.ONE * lerpf(0.95, 1.0, sin(enter * PI * 0.5))
	queue_redraw()
	if elapsed >= lifetime: queue_free()

func _draw() -> void:
	if not font: return
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("071321ed")
	panel.border_color = Color(accent, 0.46)
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(7)
	panel.shadow_color = Color(0, 0, 0, 0.25)
	panel.shadow_size = 6
	draw_style_box(panel, Rect2(Vector2.ZERO, size))
	draw_rect(Rect2(0, 8, 3, size.y - 16), accent)
	draw_rect(Rect2(9, 7, size.x - 18, 18), Color(accent, 0.08))
	var header: String = target_name.to_upper() if not target_name.is_empty() else "COMBATE"
	if critical: header += " / CRÍTICO"
	elif protected: header += " / ABSORVIDO"
	var header_size := 11
	var header_width := size.x - (40 if critical else 22)
	while header_size > 8 and font.get_string_size(header, HORIZONTAL_ALIGNMENT_LEFT, -1, header_size).x > header_width: header_size -= 1
	draw_string(font, Vector2(11, 20), header, HORIZONTAL_ALIGNMENT_LEFT, header_width, header_size, accent)
	if critical:
		var star := PackedVector2Array([Vector2(168, 9), Vector2(171, 14), Vector2(176, 16), Vector2(171, 18), Vector2(168, 23), Vector2(166, 18), Vector2(161, 16), Vector2(166, 14)])
		draw_colored_polygon(star, accent)
	var y := 28.0
	for row in rows:
		var point_size: int = int(row.size)
		while point_size > 10 and font.get_string_size(row.text, HORIZONTAL_ALIGNMENT_LEFT, -1, point_size).x > size.x - 22: point_size -= 1
		draw_string_outline(font, Vector2(11, y + row.size), row.text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 22, point_size, 1, Color("06101a"))
		draw_string(font, Vector2(11, y + row.size), row.text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 22, point_size, row.color)
		y += row.height
	if shield_remaining >= 0:
		var ratio := clampf(float(shield_remaining) / maxf(1, shield_capacity), 0, 1)
		draw_style_box(_track(Color("16364b")), Rect2(11, size.y - 9, size.x - 22, 3))
		if ratio > 0: draw_style_box(_track(Color("80dcff")), Rect2(11, size.y - 9, (size.x - 22) * ratio, 3))

func _track(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(2)
	return style
