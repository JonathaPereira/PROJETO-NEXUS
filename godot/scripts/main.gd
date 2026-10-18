extends Control
const Combat = preload("res://scripts/combat.gd")
const Fighter = preload("res://scripts/fighter.gd")
const CombatUI = preload("res://scripts/combat_ui.gd")
const Director = preload("res://scripts/animation_director.gd")
const Showcase = preload("res://scripts/showcase.gd")
const Campaign = preload("res://scripts/campaign.gd")
const Hub = preload("res://scripts/hub.gd")
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
var screen_button: Button
var display_mode := "windowed"
var display_resolution := Vector2i(1280, 720)
var windowed_resolution := Vector2i(1280, 720)
var inspected_hero := ""
var roster_front_picker: OptionButton
var feedback_panel: PanelContainer
var preview_requested := true
var tutorial_index := -1
var tutorial_progress: Dictionary = {}
var free_settings: Dictionary = {}
var lab
var campaign
var hub: Control
var combat_view: Control
var campaign_mission := -1
var roster_campaign := false
var mission_label: Label
var menu_dialog: ConfirmationDialog
const Lessons = preload("res://scripts/lessons.gd")
const Lab = preload("res://scripts/lab.gd")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	teams = catalog.default_teams.duplicate(true)
	_load_preferences()
	_build_theme()
	_build_interface()
	campaign = Campaign.new(catalog)
	Campaign.register_enemies(catalog)
	_new_battle()
	hub = Hub.new()
	hub.app = self
	add_child(hub)
	hub.open()
	if DisplayServer.get_name() != "headless": _apply_display.call_deferred()

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

func _enter_free() -> void:
	campaign_mission = -1
	hub.hide()
	combat_view.show()
	_new_battle()

func _begin_mission(index: int) -> void:
	if not hub.visible or not campaign.can_play(index): return
	campaign_mission = index
	hub.hide()
	combat_view.show()
	_new_battle()

func _open_menu() -> void:
	if started and state.phase == "playing":
		if not is_instance_valid(menu_dialog):
			menu_dialog = ConfirmationDialog.new()
			menu_dialog.title = "Voltar ao menu?"
			menu_dialog.dialog_text = "A batalha em andamento será encerrada.\nMissões concluídas, equipe e gemas salvas serão preservadas."
			menu_dialog.ok_button_text = "Voltar ao menu"
			menu_dialog.cancel_button_text = "Continuar batalha"
			menu_dialog.confirmed.connect(_leave_battle.bind("menu"))
			add_child(menu_dialog)
		menu_dialog.popup_centered()
	else: _leave_battle("menu")

func _leave_battle(page: String = "menu") -> void:
	battle_version += 1
	director.cancel()
	sound.stop()
	started = false
	busy = false
	ai_pending = false
	if tutorial_index >= 0: _end_lesson()
	campaign_mission = -1
	result_dialog.hide()
	hub.open(page)

func _result_confirmed() -> void:
	if campaign_mission >= 0 and state.winner == 0: _leave_battle("story")
	else: _new_battle()

func _new_battle() -> void:
	battle_version += 1
	director.cancel()
	if is_instance_valid(sound): sound.stop()
	started = false
	busy = false
	ai_pending = false
	result_shown = false
	selected_action = "basic"
	preview_requested = true
	target_id = ""
	if is_instance_valid(feedback): feedback.text = "[center][color=#d5b480]LEITURA DO COMBATE[/color]  ·  Dano à vida e ao escudo aparecem separados.[/center]"
	state = campaign.battle(combat, campaign_mission) if campaign_mission >= 0 else combat.new_battle(teams[0], teams[1], difficulty if mode == "training" else "normal")
	if tutorial_index >= 0:
		tutorial_progress = {}
		Lessons.prepare(state, tutorial_index)
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
			# MAA reference: the vanguard is at center/inward, rear units above and below.
			var slot: int = data.slot
			var x: float = [0.29, 0.12, 0.12][slot]
			if data.side == 1: x = 1.0 - x
			var foot := Vector2(field.size.x * x, field.size.y * [0.73, 0.40, 0.95][slot])
			if slot == 1: foot.y = maxf(174, foot.y)
			fighter.position = foot - Vector2(93, 257)
			fighter.set_depth([0.95, 0.82, 0.95][slot])
			fighter.set_formation(slot)
			fighter.z_index = [2, 1, 3][slot]
			var plate_x: float = foot.x + 92 if data.side == 0 else foot.x - 92 - fighter.plate.size.x
			var plate_y: float = [foot.y - 110, maxf(4, foot.y - 200 * fighter.depth - 10), foot.y - 88][slot]
			fighter.plate.position = Vector2(plate_x, plate_y) - fighter.position

func _human_turn() -> bool:
	return (campaign_mission < 0 and mode == "local") or combat.current(state).get("side", 1) == 0

func _can_act() -> bool:
	return combat_view.visible and started and not busy and state.phase == "playing" and _human_turn()

func _refresh() -> void:
	CombatUI.refresh(self)
	_update_log()
	if state.phase == "finished" and not result_shown:
		result_shown = true
		if tutorial_index < 0 and campaign_mission < 0: Lab.record(state, mode, difficulty)
		var damage := 0
		var healing := 0
		for data in state.units:
			if data.side == state.winner:
				damage += int(data.stats.damage)
				healing += int(data.stats.healing)
		result_dialog.dialog_text = "Equipe %d venceu!\n\n%d rodadas · %d ações\nDano da equipe vencedora: %d\nCura: %d\n\nJogue novamente ou feche para consultar o resultado." % [int(state.winner) + 1, state.round, state.turns, damage, healing]
		if tutorial_index >= 0:
			result_dialog.dialog_text += "\n\n" + Lessons.hint(tutorial_index, tutorial_progress)
		result_dialog.ok_button_text = "Jogar novamente"
		if campaign_mission >= 0:
			var mission: Dictionary = Campaign.MISSIONS[campaign_mission]
			result_dialog.ok_button_text = "Voltar às missões" if state.winner == 0 else "Tentar novamente"
			result_dialog.dialog_text = ("VITÓRIA · " if state.winner == 0 else "DERROTA · ") + mission.name + "\n\n"
			if state.winner == 0:
				var reward: Dictionary = campaign.complete(campaign_mission)
				result_dialog.dialog_text += mission.ending + "\n\n" + ("Primeira vitória: +1 " + reward.gem if reward.get("first", false) else "Missão repetida: sem recompensa adicional.")
				if not reward.get("saved", false): result_dialog.dialog_text += "\n\nATENÇÃO: " + campaign.error_text
			else:
				result_dialog.dialog_text += "Seu progresso e suas gemas foram preservados. Ajuste o trio ou os engastes no menu e tente de novo.\n\n" + mission.tip
			result_dialog.dialog_text += "\n\n%d rodadas · %d ações" % [state.round, state.turns]
		result_dialog.popup_centered()

func _start() -> void:
	if not combat_view.visible: return
	started = true
	_refresh()
	_schedule_ai()

func _select_action(id: String) -> void:
	if not _can_inspect() or not id in ACTIONS: return
	selected_action = id
	preview_requested = true
	_refresh()

func _select_target(id: String) -> void:
	if not _can_act(): return
	var legal := combat.legal_targets(state, combat.current(state), combat.get_action(combat.current(state), selected_action))
	if not legal.any(func(u): return u.id == id): return
	target_id = id
	preview_requested = true
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
	preview_requested = false
	CombatUI.lock_action(self, hero, action)
	var hit := func():
		if version != battle_version: return
		var cue := int(catalog.class_by_id[hero.classId].index) if action_id != "guard" else 6
		if result.events.any(func(e): return e.get("critical", false)): cue = 8
		elif result.events.any(func(e): return e.get("absorbed", 0) > 0): cue = 7
		sound.play_cue(cue)
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
			sound.play_cue(9 if event.type in ["burn", "bleed", "fracture"] else 5)
			CombatUI.show_report(self, [event], "INÍCIO DO TURNO"))
		if version != battle_version or not ticks_done: return
	if tutorial_index >= 0: Lessons.observe(tutorial_progress, result, actor.side)
	state = pending
	busy = false
	selected_action = "basic"
	_refresh()
	_schedule_ai()

func _can_inspect() -> bool:
	return combat_view.visible and not busy and (not started or (state.phase == "playing" and _human_turn()))

func _set_reduced(enabled: bool) -> void:
	reduced_motion = enabled
	_save_preferences()
	backdrop.motion_enabled = not enabled
	for fighter in fighters.values(): fighter.motion_enabled = not enabled
	# A preference change must not repaint pre-impact health over a live strike.
	if not busy: _refresh()

func _schedule_ai() -> void:
	if ai_pending or busy or not started or (mode != "training" and campaign_mission < 0) or state.phase != "playing" or _human_turn(): return
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
			"damage", "heal", "shield", "guard", "burn", "bleed", "fracture", "energy", "status", "support", "converted", "shieldExpired": message = "%s: %s" % [target, CombatUI._plain(CombatUI.event_detail(entry))]
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
	text += "Classe define afinidade; tanque, suporte e dano são funções dos kits. Cada classe tem as três funções. Lumi e nove personagens estão arquivados para esta fase de testes.\n\nAtacar quem supera sua classe causa 15% menos dano.\nAs demais relações são neutras."
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
	dialog.dialog_text = "1. Monte duas equipes de três personagens diferentes.\n2. Escolha treino contra IA ou duelo no mesmo dispositivo.\n3. Inicie o combate e acompanhe a ordem dos turnos.\n4. Escolha uma ação, depois o alvo e confirme.\n5. Derrote os três rivais.\n\nAtaque básico: acerta UM inimigo escolhido, na frente ou atrás, e recupera 24 de energia.\nTécnica: custa 30; recarga de dois turnos pessoais.\nSupremo: custa 80; o alcance varia por personagem.\nDefesa: reduz dano, concede escudo e recupera 25 de energia.\nCuras e escudos escolhem aliados.\n\nVerde = vida; azul = escudo; violeta = energia.\nOs números separam vida perdida, escudo absorvido e escudo restante.\nCrítico: 10% de chance, +40% de dano, inclusive contra escudos.\nQueimadura e sangramento: 6,5% da vida máxima no início de 2 turnos.\nAtravessam escudos; reaplicar renova a duração. Sangramento reduz TODA cura recebida em 35%, inclusive regeneração, Semente e dreno. Purificação remove ambos. Curas com purificação curam antes de remover o efeito.\nRegen: +4% da vida máxima no início de 2 turnos.\nATQ↓ = enfraquecimento (−20%); DEF↓ = exposição (−25%).\nPasse o mouse sobre a ficha para consultar nomes e duração dos estados.\nVulnerável: +25% de dano; Resistente: −15%, em relação ao herói que age.\nFRENTE: centro do trio, mais perto do adversário. ATRÁS: alto e baixo da lateral.\nA posição é visual: qualquer inimigo vivo pode ser escolhido. Provocação restringe ataques individuais ao provocador; área atinge todos.\nEscudos não somam: mantém o maior, até 25% da vida, por 2 ações do protegido. Aplicar um menor não renova a duração do maior.\nSombrio drena 15% do dano direto à vida; escudo absorvido não gera cura.\nTela: escolha 1920×1080 e tela cheia. F11 alterna; Esc volta à janela.\n\nFratura: começa na rodada 12 com 4% da vida máxima antes de cada ação pessoal. Cresce 2,5 pontos percentuais por rodada (limite 85%) e ignora escudos. Também reduz TODA cura recebida: −10% na rodada 12, −20% na 13, até −100% na 21. O valor aparece no alto da arena; não pode ser purificado. A redução de Sangramento é multiplicada pela da Fratura. Evita esperar pela Fratura apenas se curando.\nProvocação limita ataques individuais ao tanque; ataques em área ignoram isso.\nProteção de Oren desvia 25% de um ataque individual ao protetor vivo.\nFortificação reduz dano em 15%; inspiração aumenta ATQ em 20%.\nSemente cura o próximo atacante aliado; Foco amplia o próximo golpe em 25%.\nCombos e condições próprias aparecem na descrição de cada habilidade.\nA formação fica salva; a batalha em andamento não.\nDuelo local usa atributos iguais para os dois lados."
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
	roster_dialog.title = "15 ativos · tanque, suporte e dano em cada classe · 9 arquivados"
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
	var formation_row := HBoxContainer.new()
	content.add_child(formation_row)
	formation_row.add_child(_label("Personagem na FRENTE:", 14, GOLD))
	roster_front_picker = OptionButton.new()
	roster_front_picker.custom_minimum_size.x = 180
	roster_front_picker.item_selected.connect(func(index):
		inspected_hero = roster_work[roster_side.selected][index]
		_move_to_front())
	formation_row.add_child(roster_front_picker)
	formation_row.add_child(_label("Posição visual; qualquer inimigo pode ser alvo.", 13, MUTED))

func _open_roster() -> void:
	if tutorial_index >= 0 or (started and state.phase == "playing"): return
	roster_campaign = is_instance_valid(hub) and hub.visible and hub.page in ["story", "gems"]
	if campaign_mission >= 0: return
	roster_work = [campaign.team.duplicate(), catalog.default_teams[1].duplicate()] if roster_campaign else teams.duplicate(true)
	roster_side.select(0)
	roster_side.disabled = roster_campaign
	roster_dialog.ok_button_text = "Salvar trio da história" if roster_campaign else "Usar equipes"
	roster_filter.select(0)
	_refresh_roster()
	roster_dialog.popup_centered_clamped(Vector2i(1010, 660), 0.95)

func _refresh_roster() -> void:
	_clear(hero_grid)
	var selected: Array = roster_work[roster_side.selected]
	roster_front_picker.clear()
	for id in selected: roster_front_picker.add_item(catalog.hero_by_id[id].name)
	roster_front_picker.disabled = selected.size() < 2
	var team_names: Array = selected.map(func(id): return catalog.hero_by_id[id].name)
	roster_count.text = "%d/3 · Frente: %s · Atrás: %s" % [selected.size(), team_names[0] if not team_names.is_empty() else "—", ", ".join(team_names.slice(1))]
	for hero in catalog.heroes:
		if roster_filter.selected > 0 and hero.classId != catalog.classes[roster_filter.selected - 1].id: continue
		var button := _button("%s%s\n%s · %s" % [(str(selected.find(hero.id) + 1) + "· " + ("FRENTE · " if selected.find(hero.id) == 0 else "ATRÁS · ")) if hero.id in selected else "", hero.name, catalog.class_by_id[hero.classId].name, hero.role], _toggle_hero.bind(hero.id))
		button.name = hero.id
		button.icon = Fighter.portrait(int(hero.index))
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 50)
		button.custom_minimum_size = Vector2(225, 76)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.set_pressed_no_signal(hero.id in selected)
		button.tooltip_text = "%s · %s\n%s\nSinergia: %s" % [hero.title, hero.role, hero.identity, hero.synergy]
		hero_grid.add_child(button)
	roster_dialog.get_ok_button().disabled = not catalog.valid_team(roster_work[0]) or not catalog.valid_team(roster_work[1])

func _toggle_hero(id: String) -> void:
	var selected: Array = roster_work[roster_side.selected]
	if id in selected: selected.erase(id)
	elif selected.size() < 3: selected.append(id)
	var hero: Dictionary = catalog.hero_by_id[id]
	inspected_hero = id
	hero_detail.text = "%s · %s\nPV %d · ATQ %d · DEF %d · VEL %d\n%s\nTécnica — %s: %s\nSupremo — %s: %s" % [hero.name, hero.title, hero.hp, hero.attack, hero.defense, hero.speed, hero.identity + " · Sinergia: " + hero.synergy, hero.skill.name, hero.skill.description, hero.ultimate.name, hero.ultimate.description]
	_refresh_roster()

func _save_roster() -> void:
	if not catalog.valid_team(roster_work[0]) or not catalog.valid_team(roster_work[1]): return
	if roster_campaign:
		campaign.set_team(roster_work[0])
		hub.open(hub.page)
		return
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
	var saved_display: Variant = config.get_value("display", "mode", "windowed")
	if saved_display in ["windowed", "fullscreen"]: display_mode = saved_display
	var saved_resolution: Variant = config.get_value("display", "resolution", Vector2i(1280, 720))
	if saved_resolution in [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]: display_resolution = saved_resolution
	var saved_motion: Variant = config.get_value("game", "reduced_motion", false)
	if saved_motion is bool: reduced_motion = saved_motion

func _save_preferences() -> void:
	var config := ConfigFile.new()
	var saved_teams: Array = free_settings.get("teams", teams)
	for side in range(2): config.set_value("teams", str(side), saved_teams[side])
	config.set_value("game", "mode", free_settings.get("mode", mode))
	config.set_value("game", "difficulty", free_settings.get("difficulty", difficulty))
	config.set_value("game", "reduced_motion", reduced_motion)
	config.set_value("display", "mode", display_mode)
	config.set_value("display", "resolution", display_resolution)
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
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if _any_dialog(): return
	if event.keycode == KEY_ESCAPE and display_mode == "fullscreen":
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(hub) and hub.visible: return
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

func _show_lab() -> void:
	if not is_instance_valid(lab):
		lab = Lab.new()
		lab.catalog = catalog
		add_child(lab)
	lab.refresh()
	lab.popup_centered_clamped(Vector2i(1130, 660), 0.95)

func _show_lessons() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Aprender · três batalhas guiadas"
	add_child(dialog)
	var column := VBoxContainer.new()
	dialog.add_child(column)
	for i in range(3):
		var tip := _label(Lessons.hint(i, {}), 13, MUTED)
		column.add_child(tip)
		column.add_child(_button(Lessons.TITLES[i], func():
			dialog.hide()
			_begin_lesson(i)))
	if tutorial_index >= 0:
		column.add_child(_button("Voltar ao treino livre", func():
			dialog.hide()
			_end_lesson()))
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered()

func _begin_lesson(index: int) -> void:
	if is_instance_valid(hub) and hub.visible: _enter_free()
	if free_settings.is_empty(): free_settings = {"teams": teams.duplicate(true), "mode": mode, "difficulty": difficulty}
	tutorial_index = index
	teams = Lessons.TEAMS[index].duplicate(true)
	mode = "training"
	difficulty = "easy"
	mode_picker.select(0)
	difficulty_picker.select(0)
	_new_battle()

func _end_lesson() -> void:
	if free_settings.is_empty(): return
	teams = free_settings.teams
	mode = free_settings.mode
	difficulty = free_settings.difficulty
	free_settings = {}
	tutorial_index = -1
	mode_picker.select(0 if mode == "training" else 1)
	difficulty_picker.select(["easy", "normal", "hard"].find(difficulty))
	_new_battle()

func _move_to_front() -> void:
	var ids: Array = roster_work[roster_side.selected]
	if not inspected_hero in ids: return
	ids.erase(inspected_hero)
	ids.push_front(inspected_hero)
	_refresh_roster()

func _apply_display() -> void:
	if DisplayServer.get_name() == "headless": return
	if display_mode == "fullscreen":
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		get_window().size = Vector2i(1920, 1080)
	else:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = display_resolution
		var screen := DisplayServer.screen_get_usable_rect()
		get_window().position = screen.position + (screen.size - display_resolution) / 2

func _toggle_fullscreen() -> void:
	if display_mode == "fullscreen":
		display_mode = "windowed"
		display_resolution = windowed_resolution
	else:
		windowed_resolution = display_resolution
		display_mode = "fullscreen"
		display_resolution = Vector2i(1920, 1080)
	_apply_display()
	_save_preferences()

func _show_display() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Tela · Full HD"
	dialog.ok_button_text = "Aplicar"
	add_child(dialog)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 430
	dialog.add_child(column)
	column.add_child(_label("F11: alterna tela cheia · Esc: volta à janela", 14, MUTED))
	var picker := OptionButton.new()
	for text in ["Janela 1280×720", "Janela 1600×900", "Janela Full HD 1920×1080", "Tela cheia Full HD 1920×1080"]: picker.add_item(text)
	picker.select(3 if display_mode == "fullscreen" else [Vector2i(1280,720), Vector2i(1600,900), Vector2i(1920,1080)].find(display_resolution))
	column.add_child(picker)
	dialog.confirmed.connect(func():
		display_mode = "fullscreen" if picker.selected == 3 else "windowed"
		display_resolution = [Vector2i(1280,720), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(1920,1080)][picker.selected]
		if display_mode == "windowed": windowed_resolution = display_resolution
		_apply_display()
		_save_preferences())
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered()
