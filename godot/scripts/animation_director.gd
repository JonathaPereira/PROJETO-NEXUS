extends RefCounted
const Impact = preload("res://scripts/impact.gd")
const PROFILES = {"igneo": "flame_dash", "natural": "verdant_bloom", "tecnico": "ion_cannon", "arcano": "astral_rift", "sombrio": "shadow_step", "lumi": "dawn_lance"}
var generation := 0
var tweens: Array[Tween] = []
var last_profile := ""
var impact_count := 0

func cancel() -> void:
	generation += 1
	for tween in tweens: tween.kill()
	tweens.clear()

func _tween(owner: Node) -> Tween:
	var tween := owner.create_tween()
	tweens.append(tween)
	return tween

func play(owner: Node, effects: Control, fighters: Dictionary, hero: Dictionary, action: Dictionary, result: Dictionary, reduced: bool, on_impact: Callable) -> bool:
	cancel()
	var version := generation
	last_profile = PROFILES[hero.classId]
	var actor = fighters[result.actor]
	if reduced:
		await owner.get_tree().process_frame
		if version != generation: return false
		on_impact.call()
		impact_count += 1
		return true
	actor.posing = true
	actor.visual_root.z_index = 30
	var home: Vector2 = actor.visual_root.position
	var direction := -1.0 if actor.artwork.flip_h else 1.0
	var bend := -7.0 * direction
	var anticipate := _tween(owner).set_parallel(true)
	anticipate.tween_property(actor.visual_root, "rotation", -0.07 * direction, 0.16)
	anticipate.tween_method(func(v): actor.material_fx.set_shader_parameter("bend", v), 0.0, bend, 0.16)
	if hero.classId in ["natural", "arcano", "lumi"]:
		anticipate.tween_property(actor.visual_root, "position", home - Vector2(0, 12), 0.16)
	else:
		anticipate.tween_property(actor.visual_root, "scale", Vector2(0.96, 1.02), 0.16)
	await owner.get_tree().create_timer(0.17).timeout
	if version != generation or not is_instance_valid(actor): return false
	var targets: Array = result.events.filter(func(e): return e.has("amount") and not e.get("passive", false))
	var target_id: String = targets[0].target if not targets.is_empty() else result.actor
	var primary = fighters[target_id]
	var target_position: Vector2 = primary.position + Vector2(93, 257)
	var travel: Vector2 = target_position - (actor.position + home)
	var strike := _tween(owner).set_parallel(true)
	var support: bool = action.kind.begins_with("heal") or action.kind.begins_with("shield") or action.kind == "guard"
	match hero.classId:
		"igneo":
			strike.tween_property(actor.visual_root, "position", home + travel * (0.56 if not support else 0.0) - Vector2(0, 10), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			strike.tween_property(actor.visual_root, "rotation", 0.14 * direction, 0.14)
		"sombrio":
			strike.tween_property(actor.visual_root, "modulate:a", 0.15, 0.07)
			strike.tween_property(actor.visual_root, "position", home + travel * (0.65 if not support else 0.0), 0.12)
		"tecnico":
			strike.tween_property(actor.visual_root, "position", home + Vector2(-10 * direction, 0), 0.12)
			strike.tween_property(actor.visual_root, "rotation", 0.05 * direction, 0.12)
		"arcano": strike.tween_property(actor.visual_root, "position", home - Vector2(0, 22), 0.14)
		"natural": strike.tween_property(actor.visual_root, "rotation", 0.05 * direction, 0.14)
		"lumi":
			strike.tween_property(actor.visual_root, "rotation", -0.1 * direction, 0.14)
			strike.tween_method(func(v): actor.material_fx.set_shader_parameter("flash", v), 0.0, 0.35, 0.14)
	for event in result.events:
		if not event.has("amount"): continue
		var target = fighters[event.target]
		var effect = Impact.new()
		effect.origin = actor.position + home - Vector2(0, 110)
		effect.destination = target.position + Vector2(93, 147)
		effect.tint = actor.tint
		effect.affinity = hero.classId
		effect.kind = "heal" if event.type == "heal" else (action.kind if event.type in ["guard", "shield"] else "damage")
		effect.ultimate = result.actionId == "ultimate"
		effects.add_child(effect)
	await owner.get_tree().create_timer(0.19).timeout
	if version != generation or not is_instance_valid(actor): return false
	on_impact.call()
	impact_count += 1
	actor.visual_root.modulate.a = 1.0
	for event in result.events:
		if not event.has("amount"): continue
		var target = fighters[event.target]
		target.material_fx.set_shader_parameter("flash_color", Color("a5efc2") if event.type == "heal" else Color.WHITE)
		var reaction := _tween(owner)
		reaction.tween_method(func(v):
			if is_instance_valid(target): target.material_fx.set_shader_parameter("flash", v), 0.8, 0.0, 0.25)
		if event.type == "damage" and event.amount > 0 and target != actor:
			var recoil := _tween(owner)
			recoil.tween_property(target.visual_root, "rotation", -0.06 * direction, 0.07)
			recoil.tween_property(target.visual_root, "rotation", 0.0, 0.18)
		_number(owner, effects, target.position + Vector2(60, 80), event)
	var recover := _tween(owner).set_parallel(true)
	recover.tween_property(actor.visual_root, "position", home, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	recover.tween_property(actor.visual_root, "rotation", 0.0, 0.3)
	recover.tween_property(actor.visual_root, "scale", Vector2.ONE, 0.3)
	recover.tween_method(func(v): actor.material_fx.set_shader_parameter("bend", v), bend, 0.0, 0.3)
	await owner.get_tree().create_timer(0.64).timeout
	if version != generation or not is_instance_valid(actor): return false
	actor.reset_pose()
	return true

func _number(owner: Node, effects: Control, at: Vector2, event: Dictionary) -> void:
	var number := Label.new()
	var positive: bool = event.type in ["heal", "shield", "guard"]
	number.text = ("+" if positive else "−") + str(event.amount)
	if event.get("critical", false): number.text += " CRÍTICO"
	if event.amount == 0: number.text = {"heal": "CURA", "shield": "BARREIRA", "guard": "DEFESA"}.get(event.type, "IMPACTO")
	number.position = at
	number.add_theme_font_size_override("font_size", 26)
	number.add_theme_color_override("font_color", Color("b6f0cd") if positive else Color("fff0d4"))
	number.add_theme_color_override("font_outline_color", Color("09111c"))
	number.add_theme_constant_override("outline_size", 5)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects.add_child(number)
	var tween := _tween(owner).set_parallel(true)
	tween.tween_property(number, "position:y", at.y - 40, 0.5)
	tween.tween_property(number, "modulate:a", 0.0, 0.5).set_delay(0.12)
	tween.chain().tween_callback(number.queue_free)
