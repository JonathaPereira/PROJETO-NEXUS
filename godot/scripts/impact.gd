extends Control
## Lightweight procedural effects, intentionally independent of combat calculations.
var origin := Vector2.ZERO
var destination := Vector2.ZERO
var tint := Color.WHITE
var signature := 0
var elapsed := 0.0
var duration := 0.65
var ultimate := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
	if elapsed >= duration: queue_free()

func _draw() -> void:
	var progress := clampf(elapsed / duration, 0, 1)
	var head := origin.lerp(destination, minf(1, progress * 1.8))
	var fade := 1.0 - progress
	var color := Color(tint, fade)
	var radius := (18.0 + 40.0 * progress) * (1.6 if ultimate else 1.0)
	draw_line(origin.lerp(head, 0.7), head, color, 5.0 if ultimate else 3.0, true)
	draw_circle(head, 7, Color(tint, fade * 0.5))
	if progress > 0.45:
		draw_arc(destination, radius, progress * TAU, progress * TAU + PI * 1.4, 32, color, 3, true)
		for i in range(4 + signature % 5):
			var angle := TAU * i / (4.0 + signature % 5) + signature * 0.3
			var direction := Vector2.from_angle(angle)
			draw_line(destination + direction * radius * 0.5, destination + direction * radius, color, 2, true)
