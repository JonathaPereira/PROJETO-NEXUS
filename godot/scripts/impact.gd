extends Control
## Six deliberately different effect languages, shared by combat and the gallery.
var origin := Vector2.ZERO
var destination := Vector2.ZERO
var tint := Color.WHITE
var affinity := "igneo"
var kind := "damage"
var signature := ""
var elapsed := 0.0
var duration := 0.8
var ultimate := false
var phase := "impact"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
	if elapsed >= duration: queue_free()

func _draw() -> void:
	var p := clampf(elapsed / duration, 0, 1)
	var fade := sin(p * PI)
	var color := Color(tint, fade)
	var scale_factor := 1.45 if ultimate else 1.0
	var at := destination
	if phase == "charge":
		var radius := (38 - p * 15) * scale_factor
		_polygon(at, radius, 6 if affinity == "tecnico" else 3 if affinity == "arcano" else 8, color, p * 2)
		draw_arc(at, radius + 10, p * TAU, p * TAU + PI * 1.5, 32, color, 2, true)
		for i in range(9):
			var point := at + Vector2.from_angle(i * TAU / 9 + p) * (75 * (1 - p) + 10)
			draw_circle(point, 2.5, Color(tint, fade))
		return
	if phase == "travel":
		var point := origin.lerp(at, p)
		if signature in ["volley", "daggers", "thorns"]:
			for i in range(3):
				var tip := point + Vector2(0, (i - 1) * 18)
				draw_line(tip - (at - origin).normalized() * 30, tip, color, 3, true)
				_polygon(tip, 6, 3, color, (at - origin).angle())
		elif signature in ["drones", "prism", "runes", "orbit"]:
			for i in range(3):
				var orbit := point + Vector2.from_angle(p * TAU + i * TAU / 3) * 23
				_polygon(orbit, 9, 4 if signature == "drones" else 3, color, p * 3)
		elif signature == "threads":
			for i in range(4): draw_line(origin + Vector2(0, i * 8 - 12), point + Vector2(0, sin(p * TAU + i) * 24), color, 2, true)
		elif affinity in ["igneo", "sombrio"]:
			draw_line(origin, point, Color(tint, fade * 0.25), 15 * scale_factor, true)
			draw_arc(point, 24 * scale_factor, -PI * 0.8 + p * 3, PI * 0.4 + p * 3, 24, color, 4, true)
		elif affinity == "tecnico":
			draw_line(origin, point, Color(tint, fade * 0.35), 14 * scale_factor, true)
			draw_line(origin, point, Color("d9f7ff", fade), 3, true)
		else:
			point.y -= sin(p * PI) * (45 if affinity == "arcano" else 15)
			draw_circle(point, 12 * scale_factor, Color(tint, fade * 0.3))
			draw_circle(point, 5 * scale_factor, Color(tint.lightened(0.5), fade))
			_polygon(point, 18 * scale_factor, 5 if affinity == "natural" else 4, color, p * 4)
		return
	if kind in ["shieldHit", "shieldBreak"]:
		var shield_color := Color("83d8ff", fade)
		for i in range(6):
			var angle := TAU * i / 6.0 - PI / 2
			var center := at + Vector2.from_angle(angle) * p * (45 if kind == "shieldBreak" else 5)
			draw_line(center + Vector2.from_angle(angle) * 46, center + Vector2.from_angle(angle + TAU / 6) * 46, shield_color, 4, true)
		_particles(at, p, Color("9be8ff"), 16, scale_factor)
		if kind == "shieldHit": return
	if kind in ["shield", "shieldAll", "guard"]:
		for radius in [40.0, 52.0]: _polygon(at, radius * scale_factor, 6, color, p * 0.2)
		for i in range(4):
			var from := at + Vector2(-35 + i * 24, 50)
			draw_line(from, from - Vector2(0, 100), Color(tint, fade * 0.25), 2, true)
		return
	match affinity:
		"igneo":
			for i in range(3):
				var radius := (36 + p * 75 + i * 13) * scale_factor
				draw_arc(at, radius, -PI * 0.9 + p * 1.3 + i * 0.3, PI * 0.3 + p * 1.3, 40, Color(tint.lerp(Color("ffe9a4"), i * 0.25), fade), 7 - i * 2, true)
			_particles(at, p, Color("ffb353"), 18, scale_factor)
		"natural":
			for i in range(4):
				var path := PackedVector2Array()
				for step in range(25):
					var t := minf(1, p * 2) * step / 24.0
					path.append(origin.lerp(at, t) + Vector2(sin(t * PI * 4 + i) * 15, 25 + sin(t * PI * 3 + i) * 10))
				draw_polyline(path, Color(tint, fade * 0.8), 2, true)
			for i in range(9):
				var angle := TAU * i / 9.0 + p
				var leaf := at + Vector2.from_angle(angle) * (20 + p * 70) * scale_factor
				draw_set_transform(leaf, angle, Vector2(1, 0.45))
				draw_circle(Vector2.ZERO, 7, color)
				draw_set_transform(Vector2.ZERO)
			draw_arc(at + Vector2(0, 35), 60 * scale_factor, 0, TAU, 50, color, 2, true)
		"tecnico":
			var direction := (at - origin).normalized()
			var perpendicular := Vector2(-direction.y, direction.x)
			for offset in [-7.0, 0.0, 7.0]:
				draw_line(origin + perpendicular * offset, origin.lerp(at, minf(1, p * 4)) + perpendicular * offset, color, 3 if offset != 0 else 8 * fade, true)
			_polygon(at, (28 + p * 40) * scale_factor, 6, color, p * 0.4)
			_particles(at, p, tint.lightened(0.5), 10, scale_factor)
		"arcano":
			for i in range(3):
				var t := minf(1, p * 2)
				var point := origin.lerp(at, t) + Vector2(0, sin(t * PI) * (i - 1) * 100)
				draw_circle(point, 7 * scale_factor, Color(tint.lightened(0.6), fade))
				draw_arc(point, 14 * scale_factor, p * TAU + i, p * TAU + i + PI * 1.5, 24, color, 2, true)
			for radius in [35.0, 65.0]:
				draw_arc(at, radius * scale_factor * (0.5 + p), p * 2, p * 2 + TAU, 50, color, 2, true)
			_polygon(at, 50 * scale_factor, 3, color, -p)
		"sombrio":
			for i in range(7):
				var point := origin.lerp(at, (i + 1) / 7.0)
				draw_circle(point + Vector2(sin(i + p * 5) * 16, -10), 12 + i * 3, Color(tint.darkened(0.5), fade * 0.2))
			draw_arc(at, (55 + p * 50) * scale_factor, PI * 0.5 + p * 2, PI * 1.8 + p * 2, 48, color, 7, true)
			draw_arc(at, (40 + p * 50) * scale_factor, -PI * 0.5 - p * 2, PI * 0.7 - p * 2, 48, Color("e1b8ff", fade), 2, true)
			_particles(at, p, tint, 12, scale_factor)
		"lumi":
			var height := 190.0 * minf(1, p * 4)
			draw_line(at - Vector2(0, height), at + Vector2(0, 38), Color(tint, fade * 0.24), 40 * scale_factor, true)
			draw_line(at - Vector2(0, height), at + Vector2(0, 38), Color("fff2ca", fade), 5 * scale_factor, true)
			for i in range(12):
				var direction := Vector2.from_angle(TAU * i / 12 + p * 0.2)
				draw_line(at + direction * 22, at + direction * (35 + p * 70) * scale_factor, color, 2, true)
			draw_arc(at, 44 * scale_factor, 0, TAU, 48, color, 2, true)
			_particles(at, p, Color("fff3ce"), 12, scale_factor)

func _particles(at: Vector2, p: float, color: Color, count: int, scale_factor: float) -> void:
	for i in range(count):
		var direction := Vector2.from_angle(i * 2.39996)
		var point := at + direction * (20 + p * (35 + i % 5 * 12)) * scale_factor + Vector2(0, p * p * 25)
		draw_circle(point, (1 - p) * (2 + i % 3), Color(color, sin(p * PI)))

func _polygon(center: Vector2, radius: float, sides: int, color: Color, rotation_value: float) -> void:
	var points := PackedVector2Array()
	for i in range(sides + 1): points.append(center + Vector2.from_angle(TAU * i / sides + rotation_value - PI / 2) * radius)
	draw_polyline(points, color, 2, true)
