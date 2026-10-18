extends Button
const Glyph = preload("res://scripts/glyph.gd")
var kind_label: Label
var name_label: Label
var cost_label: Label
var glyph: Control
var tint := Color.WHITE
var available := true
var reason := ""
var action_id := "basic"

func _ready() -> void:
	toggle_mode = true
	clip_contents = true
	custom_minimum_size = Vector2(0, 96)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 12)
	for side in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(header)
	glyph = Glyph.new()
	glyph.custom_minimum_size = Vector2(22, 22)
	header.add_child(glyph)
	kind_label = _label(12)
	kind_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(kind_label)
	name_label = _label(16)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(name_label)
	cost_label = _label(13)
	column.add_child(cost_label)

func _label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func configure(action: Dictionary, id: String, shortcut: int, color: Color, energy: int, cooldown: int, interactive: bool) -> void:
	action_id = id
	tint = color
	available = energy >= action.cost and cooldown <= 0
	disabled = not interactive
	reason = ""
	if cooldown > 0: reason = "Disponível em %d turno(s) deste herói." % cooldown
	elif energy < action.cost: reason = "Faltam %d de energia." % (int(action.cost) - energy)
	kind_label.text = "%d  %s" % [shortcut, {"basic": "ATAQUE", "skill": "TÉCNICA", "ultimate": "SUPREMO", "guard": "DEFESA"}[id]]
	kind_label.add_theme_color_override("font_color", color)
	name_label.text = action.name
	name_label.add_theme_color_override("font_color", Color("f2f5ff") if available else Color("a8b6cd"))
	cost_label.text = "+24 energia" if id == "basic" else ("+25 energia · barreira" if id == "guard" else "%d energia" % action.cost)
	if cooldown > 0: cost_label.text = "◷ Recarga: %d turno(s)" % cooldown
	elif energy < action.cost: cost_label.text += " · faltam %d" % (int(action.cost) - energy)
	cost_label.add_theme_color_override("font_color", Color("a8cbb8") if available else Color("deaa89"))
	glyph.symbol = id if id in ["basic", "guard", "ultimate"] else "arcano"
	glyph.tint = color
	glyph.queue_redraw()
	tooltip_text = action.description + ("\n" + reason if not reason.is_empty() else "")
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("111c2c")
	normal.border_color = color.darkened(0.65)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(8)
	var selected: StyleBoxFlat = normal.duplicate()
	selected.bg_color = color.darkened(0.83)
	selected.border_color = color
	selected.set_border_width_all(2)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("1b2c43")
	hover.border_color = color.lightened(0.1)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("disabled", normal)
	add_theme_stylebox_override("pressed", selected)
	add_theme_stylebox_override("hover_pressed", selected)
	add_theme_stylebox_override("hover", hover)
