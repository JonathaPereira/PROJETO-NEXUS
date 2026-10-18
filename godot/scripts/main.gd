extends Control
const Combat = preload("res://scripts/combat.gd")
const Fighter = preload("res://scripts/fighter.gd")
const CombatUI = preload("res://scripts/combat_ui.gd")
const Director = preload("res://scripts/animation_director.gd")
const Showcase = preload("res://scripts/showcase.gd")
const GOLD := Color("d5b480")
const MUTED := Color("9aacbf")
const ACTIONS := ["basic", "skill", "ultimate", "guard"]
var combat = Combat.new()
var catalog = combat.catalog
var state: Dictionary = {}
var teams: Array = []
var mode := "training"
var difficulty := "normal"
var selected_action := "basic"
var target_id := ""
var started := false
var busy := false
var ai_pending := false
var battle_version := 0
var result_shown := false
var reduced_motion := false
var field: Control
var effects: Control
var fighters: Dictionary = {}
var phase_label: Label
var round_label: Label
var initiative: Label
var active_label: Label
var description: Label
var log_view: RichTextLabel
var action_buttons: Dictionary = {}
var target_buttons: HBoxContainer
var execute_button: Button
var start_button: Button
var roster_button: Button
var mode_picker: OptionButton
var difficulty_picker: OptionButton
var sound_button: Button
var sound: AudioStreamPlayer
var restart_dialog: ConfirmationDialog
var result_dialog: AcceptDialog
var roster_dialog: AcceptDialog
var hero_grid: GridContainer
var roster_filter: OptionButton
var roster_side: OptionButton
var roster_count: Label
var hero_detail: Label
var roster_work: Array = []
var director = Director.new()
var showcase
var timeline: HBoxContainer
var backdrop: Control
var log_dialog: AcceptDialog
var active_portrait: TextureRect
var active_class: Label
var active_numbers: Label
var active_health: Control
var active_energy: Control
var active_energy_label: Label
var step_label: Label
var active_shield: Control
var active_shield_label: Label
var feedback: RichTextLabel
var feedback_panel: PanelContainer

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	teams = catalog.default_teams.duplicate(true)
	_load_preferences()
	_build_theme()
	_build_interface()
	_new_battle()

func _style(color: Color, border: Color = Color("37353f")) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

func _build_theme() -> void:
	theme = Theme.new()
	var body_font := FontVariation.new()
	body_font.base_font = preload("res://assets/manrope.ttf")
	body_font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 600.0}
	theme.default_font = body_font
	theme.default_font_size = 15
	theme.set_color("font_color", "Label", Color("eff4ff"))
	theme.set_color("font_color", "Button", Color("eff4ff"))
	theme.set_color("font_disabled_color", "Button", Color("8497b3"))
	for type in ["Button", "OptionButton"]:
		theme.set_stylebox("normal", type, _style(Color("152238")))
		theme.set_stylebox("hover", type, _style(Color("263a55"), GOLD))
		theme.set_stylebox("pressed", type, _style(Color("3a3540"), GOLD))
		theme.set_stylebox("disabled", type, _style(Color("0d1828"), Color("1e3047")))
		theme.set_stylebox("focus", type, _style(Color(0, 0, 0, 0), GOLD))
	theme.set_stylebox("panel", "PanelContainer", _style(Color("101c2df5")))
	theme.set_stylebox("panel", "AcceptDialog", _style(Color("101c2d"), GOLD))
	theme.set_constant("separation", "VBoxContainer", 10)
	theme.set_constant("separation", "HBoxContainer", 12)
	theme.set_constant("h_separation", "GridContainer", 10)
	theme.set_constant("v_separation", "GridContainer", 10)

func _label(text_value: String, font_size := 15, color := Color("eff4ff")) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	return button

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _build_interface() -> void:
	CombatUI.build(self)

func _new_battle() -> void:
	battle_version += 1
	director.cancel()
	if is_instance_valid(sound): sound.stop()
	started = false
	busy = false
	ai_pending = false
	result_shown = false
	selected_action = "basic"
	target_id = ""
	if is_instance_valid(feedback): feedback.text = "[center][color=#d5b480]LEITURA DO COMBATE[/color]  ·  Dano à vida e ao escudo aparecem separados.[/center]"
	state = combat.new_battle(teams[0], teams[1], difficulty if mode == "training" else "normal")
	for fighter in fighters.values():
		field.remove_child(fighter)
		fighter.queue_free()
	fighters.clear()
	_clear(effects)
	for data in state.units:
		var hero: Dictionary = catalog.hero_by_id[data.heroId]
		var fighter = Fighter.new()
		fighter.setup(hero, data.id, catalog.affinity_color(hero.classId))
		fighter.targeted.connect(_select_target)
		field.add_child(fighter)
		fighters[data.id] = fighter
	_position_fighters.call_deferred()
	_refresh()

func _position_fighters() -> void:
	if not is_instance_valid(field): return
	for index in range(state.get("units", []).size()):
		var data: Dictionary = state.units[index]
		var fighter = fighters.get(data.id)
		if is_instance_valid(fighter):
			# Slot 0 is the vanguard; slots 1 and 2 form the back of the triangle.
			var x: float = [0.36, 0.10, 0.23][int(data.slot)]
			if data.side == 1: x = 1.0 - x
			var foot := Vector2(field.size.x * x, field.size.y - [140, 175, 130][int(data.slot)])
			fighter.position = foot - Vector2(93, 257)
			fighter.set_depth([1.0, 0.80, 0.91][int(data.slot)])
			fighter.z_index = int(data.slot) + 3 if data.slot == 0 else int(data.slot)
			# Information cards stay in their own row and retain a readable size.
			fighter.plate.position = Vector2(foot.x - 88, field.size.y - 128) - fighter.position

func _human_turn() -> bool:
	return mode == "local" or combat.current(state).get("side", 1) == 0

func _can_act() -> bool:
	return started and not busy and state.phase == "playing" and _human_turn()

func _refresh() -> void:
	CombatUI.refresh(self)
	_update_log()
	if state.phase == "finished" and not result_shown:
		result_shown = true
		var damage := 0
		var healing := 0
		for data in state.units:
			if data.side == state.winner:
				damage += int(data.stats.damage)
				healing += int(data.stats.healing)
		result_dialog.dialog_text = "Equipe %d venceu!\n\n%d rodadas · %d ações\nDano da equipe vencedora: %d\nCura: %d\n\nJogue novamente ou feche para consultar o resultado." % [int(state.winner) + 1, state.round, state.turns, damage, healing]
		result_dialog.popup_centered()

func _start() -> void:
	started = true
	_refresh()
	_schedule_ai()

func _select_action(id: String) -> void:
	if not _can_inspect() or not id in ACTIONS: return
	selected_action = id
	_refresh()

func _select_target(id: String) -> void:
	if not _can_act(): return
	var legal := combat.legal_targets(state, combat.current(state), combat.get_action(combat.current(state), selected_action))
	if not legal.any(func(u): return u.id == id): return
	target_id = id
	_refresh()

func _execute() -> void:
	if _can_act(): _play_turn(selected_action, target_id)

func _play_turn(action_id: String, target: String) -> void:
	if busy or not started or state.phase != "playing": return
	var version := battle_version
	var actor := combat.current(state)
	var hero: Dictionary = catalog.hero_by_id[actor.heroId]
	var action := combat.get_action(actor, action_id)
	# Compute separately: the displayed actor stays stable until the strike lands.
	var pending := state.duplicate(true)
	var result := combat.act(pending, action_id, target)
	if result.has("error"):
		description.text = result.error
		return
	busy = true
	CombatUI.lock_action(self, hero, action)
	var hit := func():
		if version != battle_version: return
		sound.play_cue(int(catalog.class_by_id[hero.classId].index) if action_id != "guard" else 6)
		for data in result.impactUnits:
			fighters[data.id].refresh(data, data.id == actor.id, false, false)
		CombatUI.update_actor_stats(self, result.impactUnits.filter(func(u): return u.id == actor.id)[0])
		CombatUI.show_report(self, result.events, action.name)
	var completed: bool = await director.play(self, effects, fighters, hero, action, result, reduced_motion, hit)
	if version != battle_version or not completed: return
	if not result.turnEvents.is_empty():
		var ticks_done: bool = await director.play_ticks(self, effects, fighters, result.turnEvents, reduced_motion, func(event):
			if version != battle_version: return
			var fighter = fighters[event.target]
			for member in fighters.values(): member.refresh(member.display_data, member == fighter, false, false)
			fighter.apply_tick(event)
			var tick_hero: Dictionary = catalog.hero_by_id[combat.unit(pending, event.target).heroId]
			phase_label.text = "%s · efeitos de turno" % tick_hero.name
			active_label.text = tick_hero.name
			active_class.text = "%s\n%s" % [catalog.class_by_id[tick_hero.classId].name, tick_hero.role]
			active_class.add_theme_color_override("font_color", catalog.affinity_color(tick_hero.classId))
			active_portrait.texture = Fighter.portrait(int(tick_hero.index))
			var tick_stats: Dictionary = combat.unit(pending, event.target).duplicate(true)
			tick_stats.hp = event.hpAfter
			tick_stats.shield = event.shieldAfter
			CombatUI.update_actor_stats(self, tick_stats)
			step_label.text = "Resolvendo efeitos antes da próxima ação."
			sound.play_cue(0 if event.type == "burn" else 4 if event.type == "bleed" else 5)
			CombatUI.show_report(self, [event], "INÍCIO DO TURNO"))
		if version != battle_version or not ticks_done: return
	state = pending
	busy = false
	selected_action = "basic"
	_refresh()
	_schedule_ai()

func _can_inspect() -> bool:
	return not busy and (not started or (state.phase == "playing" and _human_turn()))

func _set_reduced(enabled: bool) -> void:
	reduced_motion = enabled
	_save_preferences()
	backdrop.motion_enabled = not enabled
	for fighter in fighters.values(): fighter.motion_enabled = not enabled
	# A preference change must not repaint pre-impact health over a live strike.
	if not busy: _refresh()

func _schedule_ai() -> void:
	if ai_pending or busy or not started or mode != "training" or state.phase != "playing" or _human_turn(): return
	ai_pending = true
	var version := battle_version
	await get_tree().create_timer(0.45).timeout
	if version != battle_version: return
	while _any_dialog():
		await get_tree().create_timer(0.1).timeout
		if version != battle_version: return
	ai_pending = false
	var choice := combat.choose_ai(state)
	if not choice.is_empty(): _play_turn(choice.actionId, choice.targetId)

func _update_log() -> void:
	var lines: Array = []
	for entry in state.log:
		var actor := _unit_name(entry.get("actor", ""))
		var target := _unit_name(entry.get("target", ""))
		var message := ""
		match entry.type:
			"action": message = "%s usou %s." % [actor, entry.name]
			"damage", "heal", "shield", "guard", "burn", "bleed", "fracture": message = "%s: %s" % [target, CombatUI._plain(CombatUI.event_detail(entry))]
			"defeated": message = "%s foi derrotado." % target
		if not message.is_empty(): lines.append("[R%d] %s" % [entry.round, message])
	log_view.text = "\n\n".join(lines) if not lines.is_empty() else "Escolha três personagens para cada equipe.\n\nVocê pode enfrentar a IA ou jogar com outra pessoa neste dispositivo."

func _unit_name(id: String) -> String:
	var data := combat.unit(state, id)
	return catalog.hero_by_id[data.heroId].name if not data.is_empty() else ""

func _ask_restart() -> void:
	if started and state.phase == "playing": restart_dialog.popup_centered()
	else: _new_battle()

func _toggle_sound() -> void:
	sound.enabled = not sound.enabled
	sound_button.text = "Som: ligado" if sound.enabled else "Som: desligado"
	sound.play_cue(5)

func _show_classes() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Ciclo de afinidades"
	var text := "Cada personagem possui uma afinidade permanente.\n\n"
	for affinity in catalog.classes:
		text += "%s → %s  (+25%% de dano)\n%s\n\n" % [affinity.name, catalog.class_by_id[affinity.strongAgainst].name, affinity.description]
	text += "Atacar quem supera sua classe causa 15% menos dano.\nAs demais relações são neutras."
	dialog.dialog_text = text
	add_child(dialog)
	var help_text: String = dialog.dialog_text
	dialog.dialog_text = ""
	var scroll_text := RichTextLabel.new()
	scroll_text.custom_minimum_size = Vector2(820, 440)
	scroll_text.text = help_text
	dialog.add_child(scroll_text)
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered_clamped(Vector2i(860, 520), 0.95)

func _show_help() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Como jogar"
	dialog.dialog_text = "1. Monte duas equipes de três personagens diferentes.\n2. Escolha treino contra IA ou duelo no mesmo dispositivo.\n3. Inicie o combate e acompanhe a ordem dos turnos.\n4. Escolha uma ação, depois o alvo e confirme.\n5. Derrote os três rivais.\n\nAtaque: recupera 24 de energia.\nTécnica: custa 30; recarga de dois turnos pessoais.\nSupremo: custa 80 e atinge vários alvos.\nDefesa: reduz dano, concede escudo e recupera 25 de energia.\nCuras e escudos escolhem aliados.\n\nVerde = vida; azul = escudo; violeta = energia.\nOs números separam vida perdida, escudo absorvido e escudo restante.\nCrítico: 10% de chance, +40% de dano, inclusive contra escudos.\nQueimadura e sangramento: 6,5% da vida máxima no início de 2 turnos.\nAtravessam escudos; reaplicar renova a duração. Purificação remove ambos.\nRegen: +7% da vida máxima no início de 2 turnos.\nATQ↓ = enfraquecimento (−20%); DEF↓ = exposição (−25%).\nPasse o mouse sobre a ficha para consultar nomes e duração dos estados.\nVulnerável: +25% de dano; Resistente: −15%, em relação ao herói que age.\nA formação triangular é visual; a posição não altera defesa nem seleção.\n\nA partir da rodada 12, a Fratura causa dano crescente antes de agir.\nA formação fica salva; a batalha em andamento não.\nDuelo local usa atributos iguais para os dois lados."
	add_child(dialog)
	var help_text: String = dialog.dialog_text
	dialog.dialog_text = ""
	var scroll_text := RichTextLabel.new()
	scroll_text.custom_minimum_size = Vector2(820, 440)
	scroll_text.text = help_text
	dialog.add_child(scroll_text)
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered_clamped(Vector2i(860, 520), 0.95)

func _build_roster() -> void:
	roster_dialog = AcceptDialog.new()
	roster_dialog.title = "Monte suas equipes · escolha três por lado"
	roster_dialog.ok_button_text = "Usar equipes"
	roster_dialog.confirmed.connect(_save_roster)
	add_child(roster_dialog)
	var content := VBoxContainer.new()
	content.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	content.custom_minimum_size = Vector2(960, 560)
	roster_dialog.add_child(content)
	var toolbar := HBoxContainer.new()
	content.add_child(toolbar)
	roster_side = OptionButton.new()
	roster_side.add_item("Equipe 1")
	roster_side.add_item("Equipe 2 / IA")
	roster_side.item_selected.connect(func(_index): _refresh_roster())
	toolbar.add_child(roster_side)
	roster_filter = OptionButton.new()
	roster_filter.add_item("Todas as afinidades")
	for affinity in catalog.classes: roster_filter.add_item(affinity.name)
	roster_filter.item_selected.connect(func(_index): _refresh_roster())
	toolbar.add_child(roster_filter)
	roster_count = _label("", 14, GOLD)
	toolbar.add_child(roster_count)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 330
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	hero_grid = GridContainer.new()
	hero_grid.columns = 4
	hero_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(hero_grid)
	hero_detail = _label("Selecione um personagem para consultar suas habilidades.", 13, MUTED)
	hero_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_detail.custom_minimum_size = Vector2(940, 135)
	content.add_child(hero_detail)

func _open_roster() -> void:
	if started and state.phase == "playing": return
	roster_work = teams.duplicate(true)
	roster_side.select(0)
	roster_filter.select(0)
	_refresh_roster()
	roster_dialog.popup_centered_clamped(Vector2i(1010, 660), 0.95)

func _refresh_roster() -> void:
	_clear(hero_grid)
	var selected: Array = roster_work[roster_side.selected]
	var team_names: Array = selected.map(func(id): return catalog.hero_by_id[id].name)
	roster_count.text = "%d/3 · Frente: %s · Atrás: %s" % [selected.size(), team_names[0] if not team_names.is_empty() else "—", ", ".join(team_names.slice(1))]
	for hero in catalog.heroes:
		if roster_filter.selected > 0 and hero.classId != catalog.classes[roster_filter.selected - 1].id: continue
		var button := _button("%s%s\n%s · %s" % ["✓ " if hero.id in selected else "", hero.name, catalog.class_by_id[hero.classId].name, hero.role], _toggle_hero.bind(hero.id))
		button.name = hero.id
		button.icon = Fighter.portrait(int(hero.index))
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 50)
		button.custom_minimum_size = Vector2(225, 76)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.set_pressed_no_signal(hero.id in selected)
		button.tooltip_text = "%s\n%s" % [hero.title, hero.lore]
		hero_grid.add_child(button)
	roster_dialog.get_ok_button().disabled = not catalog.valid_team(roster_work[0]) or not catalog.valid_team(roster_work[1])

func _toggle_hero(id: String) -> void:
	var selected: Array = roster_work[roster_side.selected]
	if id in selected: selected.erase(id)
	elif selected.size() < 3: selected.append(id)
	var hero: Dictionary = catalog.hero_by_id[id]
	hero_detail.text = "%s · %s\nPV %d · ATQ %d · DEF %d · VEL %d\n%s\nTécnica — %s: %s\nSupremo — %s: %s" % [hero.name, hero.title, hero.hp, hero.attack, hero.defense, hero.speed, hero.lore, hero.skill.name, hero.skill.description, hero.ultimate.name, hero.ultimate.description]
	_refresh_roster()

func _save_roster() -> void:
	if not catalog.valid_team(roster_work[0]) or not catalog.valid_team(roster_work[1]): return
	teams = roster_work.duplicate(true)
	_save_preferences()
	_new_battle()

func _load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load("user://preferences.cfg") != OK: return
	for side in range(2):
		var saved: Variant = config.get_value("teams", str(side), [])
		if catalog.valid_team(saved): teams[side] = saved.duplicate()
	var saved_mode: Variant = config.get_value("game", "mode", "training")
	if saved_mode in ["training", "local"]: mode = saved_mode
	var saved_difficulty: Variant = config.get_value("game", "difficulty", "normal")
	if saved_difficulty in ["easy", "normal", "hard"]: difficulty = saved_difficulty
	var saved_motion: Variant = config.get_value("game", "reduced_motion", false)
	if saved_motion is bool: reduced_motion = saved_motion

func _save_preferences() -> void:
	var config := ConfigFile.new()
	for side in range(2): config.set_value("teams", str(side), teams[side])
	config.set_value("game", "mode", mode)
	config.set_value("game", "difficulty", difficulty)
	config.set_value("game", "reduced_motion", reduced_motion)
	var error := config.save("user://preferences.cfg")
	if error != OK: push_warning("Não foi possível salvar as preferências: %s" % error_string(error))

func _any_dialog() -> bool:
	return get_children().any(func(child): return child is Window and child.visible)

func _open_showcase() -> void:
	if not is_instance_valid(showcase):
		showcase = Showcase.new()
		showcase.catalog = catalog
		showcase.audio = sound
		showcase.reduced_motion = reduced_motion
		add_child(showcase)
	else:
		showcase.reduced_motion = reduced_motion
		showcase._select_hero(showcase.selected_hero)
	showcase.popup_centered_clamped(Vector2i(1080, 740), 0.95)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or _any_dialog(): return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit: return
	if event.keycode >= KEY_1 and event.keycode <= KEY_4:
		_select_action(ACTIONS[event.keycode - KEY_1])
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_LEFT, KEY_RIGHT] and _can_act():
		var targets := combat.legal_targets(state, combat.current(state), combat.get_action(combat.current(state), selected_action))
		var ids: Array = targets.map(func(u): return u.id)
		var index: int = ids.find(target_id)
		_select_target(ids[posmod(index + (-1 if event.keycode == KEY_LEFT else 1), ids.size())])
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		var battle_focus: bool = focused == null or focused == execute_button or focused in action_buttons.values() or focused in fighters.values() or focused in target_buttons.get_children()
		if battle_focus and _can_act():
			_execute()
			get_viewport().set_input_as_handled()
