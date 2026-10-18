extends RefCounted
const Impact = preload("res://scripts/impact.gd")
const Fighter = preload("res://scripts/fighter.gd")
const Ultimate = preload("res://scripts/ultimate_fx.gd")
const AbilityArt = preload("res://scripts/ability_art.gd")
const PROFILES = {"igneo": "flame_dash", "natural": "verdant_bloom", "tecnico": "ion_cannon", "arcano": "astral_rift", "sombrio": "shadow_step", "lumi": "dawn_lance"}
var generation := 0
var tweens: Array[Tween] = []
var last_profile := ""
var impact_count := 0
var last_numbers: Array[String] = []
var transients: Array[Node] = []

func cancel() -> void:
	generation += 1
	for tween in tweens: tween.kill()
	tweens.clear()
	for node in transients:
		if is_instance_valid(node): node.queue_free()
	transients.clear()

func _tween(owner: Node) -> Tween:
	var tween := owner.create_tween()
	tweens.append(tween)
	return tween

func _effect(effects: Control, origin: Vector2, destination: Vector2, hero: Dictionary, kind: String, phase: String, ultimate: bool, duration: float) -> void:
	var effect = Impact.new()
	effect.origin = origin
	effect.destination = destination
	effect.tint = Color(hero.get("color", "ffffff"))
	effect.affinity = hero.classId
	effect.signature = hero.get("animation", "")
	effect.kind = kind
	effect.phase = phase
	effect.ultimate = ultimate
	effect.duration = duration
	effects.add_child(effect)
	transients.append(effect)

func play(owner: Node, effects: Control, fighters: Dictionary, hero: Dictionary, action: Dictionary, result: Dictionary, reduced: bool, on_impact: Callable) -> bool:
	cancel()
	last_numbers.clear()
	var version := generation
	last_profile = hero.animation
	var actor = fighters[result.actor]
	if reduced:
		await owner.get_tree().process_frame
		if version != generation: return false
		on_impact.call()
		impact_count += 1
		return true
	var art_hero: Dictionary = hero.duplicate()
	art_hero.color = actor.tint.to_html()
	actor.posing = true
	actor.visual_root.z_index = 30
	actor.set_pose(1)
	var home: Vector2 = actor.visual_root.position
	var direction := -1.0 if actor.artwork.flip_h else 1.0
	var ultimate: bool = result.actionId == "ultimate"
	var charge_time := (0.72 if ultimate else (0.34 if result.actionId == "skill" else 0.24)) + (0.12 if hero.animation in ["crater", "roots"] else 0.0)
	var support: bool = action.kind.begins_with("heal") or action.kind.begins_with("shield") or action.kind == "guard" or action.kind.begins_with("support")
	var ultimate_scene: Control
	if ultimate:
		ultimate_scene = Ultimate.new()
		ultimate_scene.z_index = -20 # Above bodies, below the fixed vitality cards.
		ultimate_scene.origin = actor.foot_position()
		ultimate_scene.affinity = hero.classId
		ultimate_scene.signature = hero.animation
		ultimate_scene.tint = actor.tint
		ultimate_scene.title = action.name
		ultimate_scene.icon = AbilityArt.icon(int(hero.index), "ultimate")
		ultimate_scene.support = support
		ultimate_scene.action_kind = action.kind
		for event in result.events:
			if event.type in (["heal", "shield", "support"] if support else ["damage"]) and not event.get("passive", false) and not event.get("reaction", false) and not event.get("intercepted", false):
				var at: Vector2 = fighters[event.target].foot_position()
				if not at in ultimate_scene.destinations: ultimate_scene.destinations.append(at)
		effects.add_child(ultimate_scene)
		transients.append(ultimate_scene)
	var melee: bool = not support and hero.animation in ["sweep", "crater", "roots", "prism", "crescent", "daggers"]
	var origin: Vector2 = actor.hit_position()
	_effect(effects, origin, origin, art_hero, action.kind, "charge", ultimate, charge_time + 0.05)
	var anticipate := _tween(owner).set_parallel(true)
	anticipate.tween_property(actor.visual_root, "rotation", -0.06 * direction, charge_time)
	anticipate.tween_method(func(v): actor.material_fx.set_shader_parameter("bend", v), 0.0, -5.0 * direction, charge_time)
	anticipate.tween_property(actor.visual_root, "position", home + Vector2(-9 * direction, -7 if hero.classId in ["arcano", "lumi"] else 3), charge_time)
	await owner.get_tree().create_timer(charge_time).timeout
	if version != generation or not is_instance_valid(actor): return false
	if is_instance_valid(ultimate_scene): ultimate_scene.release()
	var targets: Array = result.events.filter(func(e): return e.type in ["damage", "heal", "shield", "guard", "support"] and not e.get("passive", false) and not e.get("reaction", false) and not e.get("intercepted", false))
	var primary = fighters[targets[0].target] if not targets.is_empty() else actor
	var travel: Vector2 = primary.foot_position() - (actor.position + home)
	actor.set_pose(3 if ultimate else 2)
	var strike := _tween(owner).set_parallel(true)
	var contact := travel - Vector2(120 * direction, 0)
	if melee:
		if hero.animation in ["crater", "roots"]:
			strike.tween_method(func(p):
				actor.visual_root.position = home + contact * p - Vector2(0, sin(p * PI) * 68), 0.0, 1.0, 0.30)
			strike.tween_property(actor.visual_root, "rotation", 0.17 * direction, 0.30)
		else:
			strike.tween_property(actor.visual_root, "position", home + contact, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			strike.tween_property(actor.visual_root, "rotation", (0.14 if hero.animation == "sweep" else 0.09) * direction, 0.24)
			if hero.animation in ["crescent", "daggers"]: strike.tween_property(actor.visual_root, "modulate:a", 0.28, 0.12)
	elif hero.animation in ["volley", "thorns"]:
		strike.tween_property(actor.visual_root, "rotation", 0.11 * direction, 0.18)
		strike.tween_property(actor.visual_root, "scale", Vector2(0.96, 1.04) * actor.depth, 0.18)
	elif hero.animation == "rail":
		strike.tween_property(actor.visual_root, "position", home + Vector2(-24 * direction, 0), 0.10)
		strike.tween_property(actor.visual_root, "rotation", -0.09 * direction, 0.10)
	elif hero.animation in ["orbit", "runes", "drones", "threads"]:
		strike.tween_property(actor.visual_root, "position", home - Vector2(0, 28 if hero.animation == "orbit" else 13), 0.24)
		strike.tween_property(actor.visual_root, "rotation", -0.035 * direction, 0.24)
	elif hero.animation in ["hex", "prism", "bloom", "roots", "crater"]:
		strike.tween_property(actor.visual_root, "scale", Vector2(1.05, 0.96) * actor.depth, 0.20)
		strike.tween_property(actor.visual_root, "position", home + Vector2(0, 5), 0.20)

	else:
		strike.tween_property(actor.visual_root, "rotation", -0.04 * direction, 0.20)
		strike.tween_property(actor.visual_root, "scale", Vector2(1.03, 0.98) * actor.depth, 0.20)
	for event in targets:
		_effect(effects, origin, fighters[event.target].hit_position(), art_hero, event.type, "travel", ultimate, 0.30 if hero.animation in ["crater", "roots"] else 0.24)
	await owner.get_tree().create_timer(0.30 if hero.animation in ["crater", "roots"] else 0.24).timeout
	if version != generation or not is_instance_valid(actor): return false
	on_impact.call()
	impact_count += 1
	if is_instance_valid(ultimate_scene): ultimate_scene.impact()
	actor.visual_root.modulate.a = 1.0
	var critical := false
	var popups := {}
	for event in _visual_events(result.events):
		if not event.has("amount"): continue
		var target = fighters[event.target]
		var impact_kind: String = event.type
		if event.get("absorbed", 0) > 0: impact_kind = "shieldBreak" if event.shieldAfter == 0 else "shieldHit"
		_effect(effects, actor.hit_position(), target.hit_position(), art_hero, impact_kind, "impact", ultimate, 0.70)
		target.material_fx.set_shader_parameter("flash_color", Color("a5efc2") if event.type == "heal" else Color("a2dcff") if event.get("absorbed", 0) > 0 else Color.WHITE)
		var reaction := _tween(owner)
		reaction.tween_method(func(v):
			if is_instance_valid(target): target.material_fx.set_shader_parameter("flash", v), 0.85, 0.0, 0.32)
		if event.type == "damage" and target != actor:
			target.reaction_until = Time.get_ticks_msec() + 500
			var recoil := _tween(owner).set_parallel(true)
			var target_home := Vector2(93, 257)
			if target.dead:
				recoil.tween_property(target.visual_root, "rotation", 0.23 * direction, 0.35)
				recoil.tween_property(target.visual_root, "position", target_home + Vector2(12 * direction, 12), 0.35)
				recoil.tween_property(target.visual_root, "modulate:a", 0.42, 0.40)
			else:
				recoil.tween_property(target.visual_root, "rotation", -0.10 * direction, 0.08)
				recoil.tween_property(target.visual_root, "position", target_home + Vector2(13 * direction, -3), 0.08)
				recoil.tween_property(target.visual_root, "scale", Vector2(0.94, 1.04) * target.depth, 0.08)
				recoil.chain().set_parallel(true)
				recoil.tween_property(target.visual_root, "rotation", 0.0, 0.24)
				recoil.tween_property(target.visual_root, "position", target_home, 0.24)
				recoil.tween_property(target.visual_root, "scale", Vector2.ONE * target.depth, 0.24)
		critical = critical or event.get("critical", false)
		if not popups.has(event.target): popups[event.target] = []
		popups[event.target].append_array(number_lines(event))
	for id in popups:
		var target = fighters[id]
		var number_at: Vector2 = target.hit_position() + Vector2(-82, -45)
		if id == result.actor: number_at = actor.position + Vector2(11, 257 - 108 * actor.depth - 45)
		_number(owner, effects, number_at, {"lines": popups[id]})

	# Hold the contact pose briefly, then show follow-through and travel home.
	await owner.get_tree().create_timer(0.24 if ultimate else 0.15 if critical else 0.10).timeout
	if version != generation or not is_instance_valid(actor): return false
	actor.set_pose(3)
	var recover := _tween(owner).set_parallel(true)
	recover.tween_property(actor.visual_root, "position", home, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	recover.tween_property(actor.visual_root, "rotation", 0.0, 0.38)
	recover.tween_property(actor.visual_root, "scale", Vector2.ONE * actor.depth, 0.38)
	recover.tween_method(func(v): actor.material_fx.set_shader_parameter("bend", v), -5.0 * direction, 0.0, 0.38)
	await owner.get_tree().create_timer(0.90 if ultimate else 0.66).timeout
	if version != generation or not is_instance_valid(actor): return false
	actor.reset_pose()
	return true

func play_ticks(owner: Node, effects: Control, fighters: Dictionary, events: Array, reduced: bool, on_tick: Callable) -> bool:
	var version := generation
	for event in events:
		if not event.has("amount"): continue
		if not reduced:
			await owner.get_tree().create_timer(0.38).timeout
			if version != generation: return false
		on_tick.call(event)
		if not reduced:
			_number(owner, effects, fighters[event.target].hit_position() + Vector2(-82, -28), event)
			await owner.get_tree().create_timer(0.95).timeout
			if version != generation: return false
	return true

func _visual_events(events: Array) -> Array:
	var grouped: Array = []
	for event in events:
		if event.type == "heal" and event.get("passive", false):
			var previous: Array = grouped.filter(func(e): return e.type == "heal" and e.target == event.target and e.get("source", "") == event.get("source", "") and e.get("passive", false))
			if not previous.is_empty():
				previous[0].amount += event.amount
				continue
		grouped.append(event.duplicate(true))
	return grouped

static func number_lines(event: Dictionary) -> Array:
	if event.has("lines"): return event.lines
	var lines: Array = []
	if event.get("reaction", false): lines.append(["CONTRA-ATAQUE", "d6bdff", 12])
	if event.get("intercepted", false): lines.append(["PROTETOR", "85dcff", 12])
	if event.has("combo"): lines.append(["COMBO!", "ffd17a", 15])
	if event.get("critical", false): lines.append(["CRÍTICO!", "ffd17a", 22])
	match event.type:
		"damage":
			lines.append(["−%d VIDA" % event.amount if event.amount > 0 else "VIDA PROTEGIDA", "ffc5b3", 21 if event.amount > 0 else 15])
			if event.get("absorbed", 0) > 0:
				lines.append(["−%d ESCUDO" % event.absorbed, "85dcff", 20])
				lines.append(["QUEBRADO · resta 0" if event.shieldAfter == 0 else "Escudo restante: %d" % event.shieldAfter, "85dcff", 12])
		"heal": lines.append(["+%d VIDA" % event.amount, "a1e6b3", 20])
		"shieldExpired":
			lines.append(["ESCUDO EXPIROU", "9ebad2", 15])
			lines.append(["−%d ESCUDO · resta 0" % event.amount, "85dcff", 15])
		"shield", "guard":
			lines.append(["+%d ESCUDO" % event.amount if event.amount > 0 else "ESCUDO RENOVADO", "85dcff", 20])
			lines.append(["Escudo total: %d" % event.get("shieldAfter", event.amount), "85dcff", 12])
		"energy": lines.append(["+%d ENERGIA" % event.amount, "c6b4ff", 18])
		"support": lines.append(["SUPORTE", "c6b4ff", 15])
		"burn", "bleed", "fracture":
			lines.append([{ "burn": "QUEIMADURA", "bleed": "SANGRAMENTO", "fracture": "FRATURA" }[event.type], "ffae88", 14])
			lines.append(["−%d VIDA" % event.amount, "ffc5b3", 22])
	if event.get("healingPenalty", 0) > 0: lines.append(["CURA −%d%%" % event.healingPenalty, "ffc18a", 13])
	if event.get("passive", false): lines.append(["REGENERAÇÃO" if event.has("remaining") else ("SEMENTE" if event.get("source", "") == "seed" else "DRENO DE VIDA"), "a1e6b3", 12])
	if event.has("remaining"): lines.append(["%d ativação(ões) restante(s)" % event.remaining, "d6dded", 11])
	if event.has("effect"):
		lines.append(["PURIFICADO" if event.effect == "cleanse" else "%s · %dT" % [Fighter.STATUS_NAMES.get(event.effect, event.effect), event.effectTurns], "eac4ee", 12])
	return lines

func _number(owner: Node, effects: Control, at: Vector2, event: Dictionary) -> void:
	var lines := number_lines(event)
	if lines.is_empty(): return
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(clampf(at.x, 4, maxf(4, effects.size.x - 190)), maxf(46, at.y))
	var box := StyleBoxFlat.new()
	box.bg_color = Color("07111ee6")
	box.border_color = Color("34465b")
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", box)
	effects.add_child(panel)
	transients.append(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)
	for line in lines:
		last_numbers.append(line[0])
		var number := Label.new()
		number.text = line[0]
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_size_override("font_size", line[2])
		number.add_theme_color_override("font_color", Color(line[1]))
		number.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(number)
	var tween := _tween(owner).set_parallel(true)
	tween.tween_property(panel, "position:y", panel.position.y - 24, 1.05)
	tween.tween_property(panel, "modulate:a", 0.0, 0.28).set_delay(0.83)
	tween.chain().tween_callback(panel.queue_free)
