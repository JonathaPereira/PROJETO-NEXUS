extends Control
const ARENA = preload("res://assets/arena.png")
var elapsed := 0.0
var motion_enabled := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	if motion_enabled: elapsed += delta
	queue_redraw()

func _draw() -> void:
	var source_size := Vector2(ARENA.get_size())
	var height := minf(source_size.y, size.y * source_size.x / maxf(1, size.x))
	var top := clampf(source_size.y * 0.31, 0, source_size.y - height)
	draw_texture_rect_region(ARENA, Rect2(Vector2.ZERO, size), Rect2(0, top, source_size.x, height), Color(0.8, 0.83, 0.92))
	# A stable dark floor keeps nameplates readable against the painted scene.
	for i in range(16):
		var opacity := pow(float(i) / 16, 2) * 0.65
		draw_rect(Rect2(0, size.y * (0.55 + i * 0.028), size.x, size.y * 0.03 + 1), Color(0.02, 0.04, 0.08, opacity))
	for i in range(20):
		var x := fposmod(i * 137.9 + sin(elapsed * 0.22 + i) * 18, maxf(1, size.x))
		var y := fposmod(i * 51.3 - elapsed * (3 + i % 4), maxf(1, size.y))
		draw_circle(Vector2(x, y), 1 + i % 2, Color(1, 0.75, 0.4, 0.1 + sin(elapsed + i) * 0.07))
