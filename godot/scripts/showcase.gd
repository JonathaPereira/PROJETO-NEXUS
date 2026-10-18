extends AcceptDialog
const Fighter = preload("res://scripts/fighter.gd")
const Director = preload("res://scripts/animation_director.gd")
const Backdrop = preload("res://scripts/arena_backdrop.gd")
const HEROES = ["veyra", "sylva", "axion", "astra", "vesper", "auren"]
var catalog
var audio
var director = Director.new()
var selected_hero := "veyra"
var playing := false
var reduced_motion := false
var stage: Control
var effects: Control
var fighters: Dictionary = {}
var hero_buttons: Array[Button] = []
var action_buttons: Array[Button] = []
var caption: Label
var explanation: Label
var version := 0

func _ready() -> void:
	title = "Galeria de golpes · um personagem de cada classe"
	ok_button_text = "Voltar ao combate"
	visibility_changed.connect(func():
		if not visible:
			version += 1
			director.cancel()
			playing = false)
	var content := VBoxContainer.new()
	content.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	content.custom_minimum_size = Vector2(1000, 590)
	add_child(content)
	var hint := Label.new()
	hint.text = "Escolha um personagem e experimente seus golpes. Esta demonstração não altera a partida."
	hint.add_theme_font_size_override("font_size", 14)
	content.add_child(hint)
	var heroes := HBoxContainer.new()
	content.add_child(heroes)
	for id in HEROES:
		var hero: Dictionary = catalog.hero_by_id[id]
		var button := Button.new()
		button.text = "%s\n%s" % [hero.name, catalog.class_by_id[hero.classId].name]
		button.icon = Fighter.portrait(int(hero.index))
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 38)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.pressed.connect(_select_hero.bind(id))
		heroes.add_child(button)
		hero_buttons.append(button)
	stage = Control.new()
	stage.custom_minimum_size = Vector2(1000, 356)
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.clip_contents = true
	content.add_child(stage)
	var background := Backdrop.new()
	background.motion_enabled = not reduced_motion
	stage.add_child(background)
	effects = Control.new()
	effects.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	effects.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects.z_index = 60
	stage.add_child(effects)
	stage.resized.connect(_position)
	caption = Label.new()
	caption.add_theme_font_size_override("font_size", 20)
	caption.add_theme_color_override("font_color", Color("e5c38c"))
	content.add_child(caption)
	explanation = Label.new()
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Give wrapping text a width before it enters the Window. Otherwise its
	# initial zero-width layout can permanently inflate the popup's height.
	explanation.custom_minimum_size = Vector2(980, 42)
	explanation.size = Vector2(980, 42)
	explanation.max_lines_visible = 2
	explanation.add_theme_font_size_override("font_size", 14)
	content.add_child(explanation)
	var actions := HBoxContainer.new()
	content.add_child(actions)
	for id in ["basic", "skill", "ultimate"]:
		var button := Button.new()
		button.text = {"basic": "Ver ataque", "skill": "Ver técnica", "ultimate": "Ver supremo"}[id]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_play.bind(id))
		actions.add_child(button)
		action_buttons.append(button)
	_select_hero(selected_hero)

func _select_hero(id: String) -> void:
	version += 1
	director.cancel()
	playing = false
	selected_hero = id
	for fighter in fighters.values():
		stage.remove_child(fighter)
		fighter.queue_free()
	fighters.clear()
	for child in effects.get_children():
		effects.remove_child(child)
		child.queue_free()
	var hero: Dictionary = catalog.hero_by_id[id]
	var dummy: Dictionary = catalog.hero_by_id["axion" if id != "axion" else "vesper"]
	for entry in [[hero, "actor"], [dummy, "target"]]:
		var fighter = Fighter.new()
		fighter.setup(entry[0], entry[1], catalog.affinity_color(entry[0].classId))
		fighter.disabled = true
		fighter.motion_enabled = not reduced_motion
		stage.add_child(fighter)
		fighter.refresh({"hp": entry[0].hp, "maxHp": entry[0].hp, "energy": 100, "shield": 0, "statuses": [], "guarding": false}, entry[1] == "actor", false, false)
		if entry[1] == "target":
			fighter.title.text = "Alvo de treino"
			fighter.artwork.flip_h = true
		fighters[entry[1]] = fighter
	for index in range(HEROES.size()): hero_buttons[index].set_pressed_no_signal(HEROES[index] == id)
	for button in action_buttons: button.disabled = false
	caption.text = "%s · %s" % [hero.name, catalog.class_by_id[hero.classId].name]
	explanation.text = "Antecipação, ataque, impacto e retorno. Escolha um golpe abaixo para assistir."
	_position.call_deferred()

func _position() -> void:
	if fighters.size() != 2: return
	fighters.actor.position = Vector2(stage.size.x * 0.25 - 93, maxf(0, (stage.size.y - 350) / 2))
	fighters.target.position = Vector2(stage.size.x * 0.75 - 93, maxf(0, (stage.size.y - 350) / 2))

func _play(action_id: String) -> void:
	if playing: return
	playing = true
	var stamp := version
	for button in action_buttons: button.disabled = true
	var hero: Dictionary = catalog.hero_by_id[selected_hero]
	var action: Dictionary = hero[action_id]
	caption.text = "%s · %s" % [hero.name, action.name]
	explanation.text = action.description
	if reduced_motion: explanation.text += " Animações reduzidas estão ativadas."
	var type := "heal" if action.kind.begins_with("heal") else ("shield" if action.kind.begins_with("shield") else "damage")
	var result := {"actor": "actor", "actionId": action_id, "events": [{"type": type, "target": "target", "amount": 0}]}
	var completed: bool = await director.play(self, effects, fighters, hero, action, result, reduced_motion, func():
		if is_instance_valid(audio): audio.play_cue(int(catalog.class_by_id[hero.classId].index)))
	if stamp != version or not completed: return
	playing = false
	for button in action_buttons: button.disabled = false
