extends Control
## Presentation only: flat shared floor, encounter lighting and ambient particles.
const ARENA = preload("res://assets/nexus-sanctum.png")
var elapsed := 0.0
var motion_enabled := true
var encounter_kind := 0

func floor_line() -> float:
	# The new painting's railing is at 27% height; all six feet remain below it.
	return size.y * 0.27

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	if motion_enabled: elapsed += delta
	queue_redraw()

func _draw() -> void:
	var light: Color = [Color("54d9f2"), Color("66e0c0"), Color("a890ff")][clampi(encounter_kind, 0, 2)]
	draw_texture_rect(ARENA, Rect2(Vector2.ZERO, size), false, Color(0.70, 0.78, 0.91))
	# A gentle vignette under the cards preserves contrast without hiding the floor.
	for i in range(16):
		var opacity := pow(float(i) / 16, 2) * 0.31
		draw_rect(Rect2(0, size.y * (0.52 + i * 0.03), size.x, size.y * 0.035 + 1), Color(0.015, 0.035, 0.065, opacity))
	var center := Vector2(size.x * 0.5, size.y * 0.58)
	# Flush energy rings share the floor perspective; they never become raised platforms.
	for ring in range(3):
		var points := PackedVector2Array()
		var radius := (100.0 + ring * 35) * size.x / 1500.0
		for sample in range(65):
			var angle := TAU * sample / 64.0
			points.append(center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.27))
		draw_polyline(points, Color(light, 0.035 + (sin(elapsed * 0.7 + ring) + 1) * 0.016), 1.0, true)
	for i in range(22):
		var x := fposmod(i * 137.9 + sin(elapsed * 0.18 + i) * 16, maxf(1, size.x))
		var y := fposmod(i * 51.3 - elapsed * (2 + i % 3), maxf(1, size.y))
		var alpha := 0.06 + (sin(elapsed * 0.8 + i) + 1.0) * 0.035
		draw_circle(Vector2(x, y), 0.8 + i % 2, Color(light, alpha), true, -1, true)
	# Corner traces emphasize the stage boundary without competing with damage receipts.
	for side in [0, 1]:
		var x := 18.0 if side == 0 else size.x - 18.0
		var direction := 1.0 if side == 0 else -1.0
		draw_polyline(PackedVector2Array([Vector2(x, size.y - 48), Vector2(x, size.y - 16), Vector2(x + direction * 72, size.y - 16)]), Color(light, 0.28), 1.4, true)
