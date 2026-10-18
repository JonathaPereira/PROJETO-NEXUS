extends Control
## Meter with an optional exact value inside the bar.
var caption := "":
	set(next):
		caption = next
		queue_redraw()
var max_value := 100.0
var value := 100.0:
	set(next):
		value = next
		queue_redraw()
var fill := Color("83c594")
var shield_value := 0.0
var trail := -1.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if trail < 0: trail = value
	trail = move_toward(trail, value, max_value * delta * 1.8)
	queue_redraw()

func _draw() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("080e18")
	box.set_corner_radius_all(3)
	draw_style_box(box, Rect2(Vector2.ZERO, size))
	var ratio := clampf(value / maxf(1, max_value), 0, 1)
	if trail > value:
		box.bg_color = Color("e9c58a")
		draw_style_box(box, Rect2(Vector2.ZERO, Vector2(size.x * clampf(trail / maxf(1, max_value), 0, 1), size.y)))
	box.bg_color = fill
	if ratio > 0: draw_style_box(box, Rect2(Vector2.ZERO, Vector2(size.x * ratio, size.y)))
	if shield_value > 0:
		draw_line(Vector2(0, 1), Vector2(size.x * clampf(shield_value / maxf(1, max_value), 0, 1), 1), Color("8edbf5"), 2)

	if not caption.is_empty():
		var font := get_theme_default_font()
		var font_size := 12
		var at := Vector2(5, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5)
		draw_string(font, at + Vector2(1, 1), caption, HORIZONTAL_ALIGNMENT_LEFT, size.x - 8, font_size, Color("030913"))
		draw_string(font, at, caption, HORIZONTAL_ALIGNMENT_LEFT, size.x - 8, font_size, Color("f7fbff"))
