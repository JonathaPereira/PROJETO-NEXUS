extends Control
const Combat = preload("res://scripts/combat.gd")
const Fighter = preload("res://scripts/fighter.gd")
const Impact = preload("res://scripts/impact.gd")
const Sound = preload("res://scripts/sound.gd")
const GOLD := Color("d5b480")
const MUTED := Color("a5a2ad")
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
var animation_tweens: Array[Tween] = []

func _ready() -> void:
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
	box.set_corner_radius_all(7)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box

func _build_theme() -> void:
	theme = Theme.new()
	var body_font := FontVariation.new()
	body_font.base_font = preload("res://assets/manrope.ttf")
	body_font.variation_opentype = {"wght": 500.0}
	theme.default_font = body_font
	theme.default_font_size = 15
	theme.set_color("font_color", "Label", Color("eeece7"))
	theme.set_color("font_color", "Button", Color("eeece7"))
	theme.set_color("font_disabled_color", "Button", Color("74717d"))
	for type in ["Button", "OptionButton"]:
		theme.set_stylebox("normal", type, _style(Color("202027")))
		theme.set_stylebox("hover", type, _style(Color("33303a"), GOLD))
		theme.set_stylebox("pressed", type, _style(Color("40372b"), GOLD))
		theme.set_stylebox("disabled", type, _style(Color("18181e"), Color("28262f")))
		theme.set_stylebox("focus", type, _style(Color(0, 0, 0, 0), GOLD))
	theme.set_stylebox("panel", "PanelContainer", _style(Color("18191fe8")))
	theme.set_stylebox("panel", "AcceptDialog", _style(Color("18191f"), GOLD))
	theme.set_constant("separation", "VBoxContainer", 10)
	theme.set_constant("separation", "HBoxContainer", 12)
	theme.set_constant("h_separation", "GridContainer", 10)
	theme.set_constant("v_separation", "GridContainer", 10)

func _label(text_value: String, font_size := 15, color := Color("eeece7")) -> Label:
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
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	var brand := VBoxContainer.new()
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	var title := _label("NEXUS", 30, GOLD)
	title.add_theme_font_override("font", preload("res://assets/cinzel.ttf"))
	brand.add_child(title)
	brand.add_child(_label("ECOS DO CREPÚSCULO", 11, MUTED))
	roster_button = _button("Montar equipes", _open_roster)
	header.add_child(roster_button)
	header.add_child(_button("Afinidades", _show_classes))
	header.add_child(_button("Como jogar", _show_help))
	sound_button = _button("Som: desligado", _toggle_sound)
	header.add_child(sound_button)
	sound = Sound.new()
	add_child(sound)
	var brief := PanelContainer.new()
	layout.add_child(brief)
	var brief_row := HBoxContainer.new()
	brief.add_child(brief_row)
	var brief_text := VBoxContainer.new()
	brief_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brief_row.add_child(brief_text)
	phase_label = _label("", 20, GOLD)
	brief_text.add_child(phase_label)
	initiative = _label("", 12, MUTED)
	brief_text.add_child(initiative)
	mode_picker = OptionButton.new()
	mode_picker.add_item("Treino contra IA")
	mode_picker.add_item("Duelo local · 2 jogadores")
	mode_picker.select(0 if mode == "training" else 1)
	mode_picker.item_selected.connect(func(index):
		mode = "training" if index == 0 else "local"
		_save_preferences()
		_new_battle())
	brief_row.add_child(mode_picker)
	difficulty_picker = OptionButton.new()
	for level in ["Iniciante", "Normal", "Desafiador"]: difficulty_picker.add_item(level)
	difficulty_picker.select(["easy", "normal", "hard"].find(difficulty))
	difficulty_picker.item_selected.connect(func(index):
		difficulty = ["easy", "normal", "hard"][index]
		_save_preferences()
		_new_battle())
	brief_row.add_child(difficulty_picker)
	var battlefield := HBoxContainer.new()
	battlefield.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(battlefield)
	var arena_panel := PanelContainer.new()
	arena_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battlefield.add_child(arena_panel)
	var arena_column := VBoxContainer.new()
	arena_panel.add_child(arena_column)
	round_label = _label("", 12, GOLD)
	arena_column.add_child(round_label)
	field = Control.new()
	field.custom_minimum_size = Vector2(0, 345)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena_column.add_child(field)
	var background := TextureRect.new()
	background.texture = preload("res://assets/arena.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.68, 0.68, 0.72)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	field.add_child(background)
	effects = Control.new()
	effects.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	effects.z_index = 20
	field.add_child(effects)
	field.resized.connect(_position_fighters)
	var log_panel := PanelContainer.new()
	log_panel.custom_minimum_size.x = 250
	battlefield.add_child(log_panel)
	var log_column := VBoxContainer.new()
	log_panel.add_child(log_column)
	log_column.add_child(_label("REGISTRO DA BATALHA", 12, GOLD))
	log_view = RichTextLabel.new()
	log_view.custom_minimum_size.x = 220
	log_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_view.scroll_following = true
	log_view.add_theme_font_size_override("normal_font_size", 13)
	log_column.add_child(log_view)
	var commands := PanelContainer.new()
	layout.add_child(commands)
	var command_column := VBoxContainer.new()
	commands.add_child(command_column)
	active_label = _label("", 18, GOLD)
	command_column.add_child(active_label)
	var actions := HBoxContainer.new()
	command_column.add_child(actions)
	for index in range(ACTIONS.size()):
		var id: String = ACTIONS[index]
		var button := _button("", _select_action.bind(id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 58
		button.toggle_mode = true
		actions.add_child(button)
		action_buttons[id] = button
	description = _label("", 13, MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 36
	command_column.add_child(description)
	var targets := HBoxContainer.new()
	command_column.add_child(targets)
	targets.add_child(_label("ALVO", 12, GOLD))
	target_buttons = HBoxContainer.new()
	target_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	targets.add_child(target_buttons)
	execute_button = _button("Confirmar ação", _execute)
	execute_button.custom_minimum_size = Vector2(230, 40)
	targets.add_child(execute_button)
	var footer := HBoxContainer.new()
	layout.add_child(footer)
	var note := _label("1–4: ação  ·  Enter: confirmar  ·  Passe o cursor para ver os atributos", 12, MUTED)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(note)
	var reduce := CheckButton.new()
	reduce.text = "Reduzir animações"
	reduce.button_pressed = reduced_motion
	reduce.toggled.connect(func(enabled):
		reduced_motion = enabled
		_save_preferences())
	footer.add_child(reduce)
	footer.add_child(_button("Reiniciar", _ask_restart))
	start_button = _button("Iniciar combate", _start)
	start_button.custom_minimum_size.x = 180
	footer.add_child(start_button)
	restart_dialog = ConfirmationDialog.new()
	restart_dialog.title = "Reiniciar batalha?"
	restart_dialog.dialog_text = "A batalha atual será encerrada. Você poderá alterar as equipes."
	restart_dialog.ok_button_text = "Reiniciar"
	restart_dialog.cancel_button_text = "Continuar jogando"
	restart_dialog.confirmed.connect(_new_battle)
	add_child(restart_dialog)
	result_dialog = AcceptDialog.new()
	result_dialog.title = "Resultado da batalha"
	result_dialog.ok_button_text = "Jogar novamente"
	result_dialog.confirmed.connect(_new_battle)
	add_child(result_dialog)
	_build_roster()

func _new_battle() -> void:
	battle_version += 1
	for tween in animation_tweens:
		tween.kill()
	animation_tweens.clear()
	started = false
	busy = false
	ai_pending = false
	result_shown = false
	selected_action = "basic"
	target_id = ""
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
	var positions := [Vector2(0.10, 0.25), Vector2(0.27, 0.8), Vector2(0.41, 0.0), Vector2(0.59, 0.0), Vector2(0.73, 0.8), Vector2(0.90, 0.25)]
	for index in range(state.get("units", []).size()):
		var fighter: Control = fighters.get(state.units[index].id)
		if is_instance_valid(fighter):
			fighter.position = Vector2(positions[index].x * field.size.x - 87, 8 + positions[index].y * maxf(0, field.size.y - 330))

func _human_turn() -> bool:
	return mode == "local" or combat.current(state).get("side", 1) == 0

func _can_act() -> bool:
	return started and not busy and state.phase == "playing" and _human_turn()

func _refresh() -> void:
	var actor := combat.current(state)
	if actor.is_empty(): return
	var hero: Dictionary = catalog.hero_by_id[actor.heroId]
	var action := combat.get_action(actor, selected_action)
	var targets := combat.legal_targets(state, actor, action)
	var ids: Array = targets.map(func(u): return u.id)
	if not target_id in ids: target_id = ids[0] if not ids.is_empty() else ""
	roster_button.disabled = started and state.phase == "playing"
	roster_button.tooltip_text = "Reinicie a batalha para mudar a formação." if roster_button.disabled else "Escolha três personagens para cada equipe."
	mode_picker.disabled = started and state.phase == "playing"
	difficulty_picker.disabled = (started and state.phase == "playing") or mode == "local"
	difficulty_picker.tooltip_text = "No duelo local, as duas equipes usam atributos iguais." if mode == "local" else "A dificuldade ajusta somente os atributos da IA."
	start_button.visible = not started
	var side_label := ("Sua equipe" if mode == "training" else "Equipe 1") if actor.side == 0 else ("Equipe rival" if mode == "training" else "Equipe 2")
	phase_label.text = "Escolha sua formação e inicie o combate" if not started else ("Batalha encerrada" if state.phase == "finished" else ("%s · vez de %s" % [side_label, hero.name]))
	var order: Array = []
	for id in state.order:
		var data := combat.unit(state, id)
		if data.hp > 0: order.append(catalog.hero_by_id[data.heroId].name)
	initiative.text = "Ordem da rodada: " + "  →  ".join(order)
	round_label.text = "RODADA %02d    ·    EQUIPE 1  ×  EQUIPE 2" % state.round
	if state.round >= 12: round_label.text += "    ·    FRATURA DO NEXUS: dano crescente a cada turno"
	active_label.text = "%s  ·  %s  ·  %d / 100 de energia" % [hero.name, catalog.class_by_id[hero.classId].name, actor.energy]
	for index in range(ACTIONS.size()):
		var id: String = ACTIONS[index]
		var ability := combat.get_action(actor, id)
		var cooldown: int = actor.cooldowns.get(id, 0)
		var suffix := "%d energia" % ability.cost if ability.cost > 0 else ("+25 energia" if id == "guard" else "+24 energia")
		if cooldown > 0: suffix = "Recarga: %d turno(s)" % cooldown
		var button: Button = action_buttons[id]
		button.text = "%d · %s\n%s" % [index + 1, ability.name, suffix]
		button.tooltip_text = ability.description
		button.set_pressed_no_signal(selected_action == id)
		button.disabled = not _can_act() or not combat.can_use(actor, id)
	description.text = action.description
	if action.kind in ["aoe", "healAll", "shieldAll"]: description.text += "  Atinge todos os alvos válidos."
	_clear(target_buttons)
	for target in targets:
		var target_hero: Dictionary = catalog.hero_by_id[target.heroId]
		var label: String = target_hero.name
		if target.side != actor.side:
			var multiplier := combat.advantage(hero.classId, target_hero.classId)
			label += " +25%" if multiplier > 1 else (" −15%" if multiplier < 1 else "")
		var button := _button(label, _select_target.bind(target.id))
		button.toggle_mode = true
		button.set_pressed_no_signal(target.id == target_id)
		button.disabled = not _can_act()
		target_buttons.add_child(button)
	execute_button.text = "Usar em %s" % catalog.hero_by_id[combat.unit(state, target_id).heroId].name if not target_id.is_empty() else "Confirmar ação"
	execute_button.disabled = not _can_act() or not combat.can_use(actor, selected_action) or target_id.is_empty()
	for data in state.units:
		var fighter: Button = fighters[data.id]
		fighter.refresh(data, data.id == actor.id and state.phase == "playing", data.id == target_id, data.id in ids and _can_act())
		fighter.disabled = not _can_act() or not data.id in ids
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
	if not _can_act() or not combat.can_use(combat.current(state), id): return
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
	if busy or state.phase != "playing": return
	var version := battle_version
	var result := combat.act(state, action_id, target)
	if result.has("error"):
		description.text = result.error
		return
	busy = true
	execute_button.disabled = true
	for button in action_buttons.values(): button.disabled = true
	for button in target_buttons.get_children(): button.disabled = true
	await _animate(result)
	if version != battle_version: return
	busy = false
	selected_action = "basic"
	_refresh()
	_schedule_ai()

func _animate(result: Dictionary) -> void:
	var hero: Dictionary = catalog.hero_by_id[result.heroId]
	var color: Color = catalog.affinity_color(hero.classId)
	sound.play_cue(int(catalog.class_by_id[hero.classId].index) if result.actionId != "guard" else 6)
	if reduced_motion:
		await get_tree().process_frame
		return
	var fighter: Control = fighters[result.actor]
	var home := fighter.position
	var direction := 1.0 if combat.unit(state, result.actor).side == 0 else -1.0
	var movement := create_tween()
	animation_tweens.clear()
	animation_tweens.append(movement)
	movement.tween_property(fighter, "position", home + Vector2(direction * 30, -12), 0.14).set_trans(Tween.TRANS_QUAD)
	movement.tween_property(fighter, "position", home, 0.24)
	for event in result.events:
		if not event.has("amount"): continue
		var target: Control = fighters[event.target]
		var effect = Impact.new()
		effect.origin = fighter.position + Vector2(87, 130)
		effect.destination = target.position + Vector2(87, 130)
		effect.tint = Color("8cba7a") if event.type == "heal" else color
		effect.signature = int(hero.index)
		effect.ultimate = result.actionId == "ultimate"
		effects.add_child(effect)
		var number := _label(("+" if event.type in ["heal", "shield", "guard"] else "−") + str(event.amount), 26, effect.tint)
		number.position = target.position + Vector2(55, 80)
		effects.add_child(number)
		var floating := create_tween().set_parallel(true)
		animation_tweens.append(floating)
		floating.tween_property(number, "position:y", number.position.y - 50, 0.65)
		floating.tween_property(number, "modulate:a", 0.0, 0.65)
		floating.chain().tween_callback(number.queue_free)
	await get_tree().create_timer(0.7).timeout

func _schedule_ai() -> void:
	if ai_pending or busy or not started or mode != "training" or state.phase != "playing" or _human_turn(): return
	ai_pending = true
	var version := battle_version
	await get_tree().create_timer(0.45).timeout
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
			"damage": message = "%s recebeu %d de dano%s." % [target, entry.amount, " · crítico" if entry.critical else ""]
			"heal": message = "%s recuperou %d PV." % [target, entry.amount]
			"shield", "guard": message = "%s ganhou %d de barreira." % [target, entry.amount]
			"burn": message = "%s: −%d PV por queimadura." % [target, entry.amount]
			"fracture": message = "%s: −%d PV pela Fratura." % [target, entry.amount]
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
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered()

func _show_help() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Como jogar"
	dialog.dialog_text = "1. Monte duas equipes de três personagens diferentes.\n2. Escolha treino contra IA ou duelo no mesmo dispositivo.\n3. Inicie o combate e acompanhe a ordem dos turnos.\n4. Escolha uma ação, depois o alvo e confirme.\n5. Derrote os três rivais.\n\nAtaque: recupera 24 de energia.\nTécnica: custa 30; recarga de dois turnos pessoais.\nSupremo: custa 80 e atinge vários alvos.\nDefesa: reduz dano, concede barreira e recupera 25 de energia.\nCuras e barreiras escolhem aliados.\n\nA partir da rodada 12, a Fratura causa dano crescente antes de agir.\nA formação fica salva; a batalha em andamento não.\nDuelo local usa atributos iguais para os dois lados."
	add_child(dialog)
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered()

func _build_roster() -> void:
	roster_dialog = AcceptDialog.new()
	roster_dialog.title = "Monte suas equipes · escolha três por lado"
	roster_dialog.ok_button_text = "Usar equipes"
	roster_dialog.confirmed.connect(_save_roster)
	add_child(roster_dialog)
	var content := VBoxContainer.new()
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
	roster_count.text = "%d/3 · %s" % [selected.size(), ", ".join(team_names)]
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

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if roster_dialog.visible or restart_dialog.visible or result_dialog.visible: return
	if event.keycode >= KEY_1 and event.keycode <= KEY_4:
		_select_action(ACTIONS[event.keycode - KEY_1])
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ENTER and not get_viewport().gui_get_focus_owner() is Button:
		_execute()
		get_viewport().set_input_as_handled()
