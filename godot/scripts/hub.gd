extends Control
const Campaign = preload("res://scripts/campaign.gd")
const Fighter = preload("res://scripts/fighter.gd")
const GemIcon = preload("res://scripts/gem_icon.gd")
const Codex = preload("res://scripts/hero_codex.gd")
const AbilityArt = preload("res://scripts/ability_art.gd")
const Backdrop = preload("res://scripts/hub_backdrop.gd")
const RulesText = preload("res://scripts/rules_text.gd")
const SURFACE := Color("0c1729f5")
const CYAN := Color("66dcff")
const VIOLET := Color("a598ff")
const WHITE := Color("eff5ff")
var app
var page := "menu"
var body: VBoxContainer
var footer: Label
var selected_hero := ""
var selected_slot := 0
var message := ""
var mission_buttons: Array[Button] = []
var gem_buttons: Dictionary = {}
var hero_buttons: Dictionary = {}
var slot_buttons: Array[Button] = []
var nav_buttons: Dictionary = {}
var gem_preview_label: Label
var transfer_buttons: Dictionary = {}
var owner_pickers: Dictionary = {}
var fill_button: Button
var remove_all_button: Button
var hero_picker: OptionButton
var remove_button: Button
var play_button: Button
var story_button: Button
var next_mission_button: Button
var team_button: Button
var notice: Label
var hero_details: TabContainer
var hero_name: Label
var hero_lore: Label
var hero_tab := 0
var scroll: ScrollContainer
var wide := true
var selected_chapter := 0
var chapter_buttons: Array[Button] = []
var mission_slots: Dictionary = {}
var subnav: HBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var background := TextureRect.new()
	background.texture = preload("res://assets/nexus-sanctum.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	background.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color("040a15cf")
	shade.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	shade.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(shade)
	var lines := Backdrop.new()
	lines.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(lines)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for side in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 28)
	for side in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var masthead := HBoxContainer.new()
	masthead.add_theme_constant_override("separation", 18)
	column.add_child(masthead)
	var logo := _heading(masthead, "NEXUS", 30, WHITE)
	logo.autowrap_mode = TextServer.AUTOWRAP_OFF
	logo.size_flags_horizontal = SIZE_SHRINK_BEGIN
	var subtitle := _text(masthead, "ECOS DO CREPÚSCULO  /  TÁTICO 2D", 11, CYAN)
	subtitle.size_flags_vertical = SIZE_SHRINK_CENTER
	masthead.add_child(app._button("⛶ Tela", app._show_display))
	masthead.add_child(app._button("Sair", func(): get_tree().quit()))
	var nav := _row(column, 8)
	for item in [["INÍCIO", "menu"], ["MODO HISTÓRIA", "story"], ["COLEÇÃO", "heroes"], ["JOGAR", "play"], ["EXTRAS", "extras"]]:
		var target: String = item[1]
		var button: Button = app._button(item[0], open.bind(target))
		button.custom_minimum_size = Vector2(132, 42)
		button.add_theme_font_size_override("font_size", 12)
		nav.add_child(button)
		nav_buttons[target] = button
	subnav = HBoxContainer.new()
	subnav.add_theme_constant_override("separation", 8)
	column.add_child(subnav)
	scroll = ScrollContainer.new()
	scroll.follow_focus = true
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = SIZE_EXPAND_FILL
	body.size_flags_vertical = SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	scroll.add_child(body)
	footer = app._label("", 12, app.MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(footer)
	wide = size.x >= 1180
	resized.connect(_resize_page)

func _resize_page() -> void:
	var next_wide := size.x >= 1180
	if next_wide == wide or not is_instance_valid(body): return
	wide = next_wide
	if visible: open.call_deferred(page)

func open(target: String = "menu") -> void:
	page = target
	visible = true
	app.combat_view.hide()
	app._clear(body)
	mission_buttons.clear()
	mission_slots.clear()
	chapter_buttons.clear()
	app._clear(subnav)
	subnav.visible = page in ["heroes", "gems"]
	if subnav.visible:
		for item in [["Heróis e habilidades", "heroes"], ["Engastes e gemas", "gems"]]:
			var target_page: String = item[1]
			var entry: Button = app._button(item[0], open.bind(target_page))
			entry.custom_minimum_size = Vector2(210,38)
			entry.disabled = page == target_page
			subnav.add_child(entry)
	gem_buttons.clear()
	transfer_buttons.clear()
	owner_pickers.clear()
	hero_buttons.clear()
	slot_buttons.clear()
	hero_details = null
	hero_name = null
	hero_lore = null
	selected_slot = clampi(selected_slot, 0, 2)
	if selected_hero == "" or not app.campaign.active_hero(selected_hero): selected_hero = app.campaign.team[0]
	for id in nav_buttons:
		var active: bool = id == page or id == "heroes" and page == "gems"
		nav_buttons[id].add_theme_stylebox_override("normal", _surface(Color("14344a") if active else Color("0b1527b8"), CYAN if active else Color("223448"), 10))
		nav_buttons[id].add_theme_color_override("font_color", CYAN if active else app.MUTED)
	match page:
		"story": _story()
		"gems": _gems()
		"heroes": _heroes()
		"play": _play_menu()
		"extras": _extras()
		_: _menu()
	footer.text = app.campaign.error_text if app.campaign.error_text != "" else message if message != "" else "Progresso salvo neste dispositivo  ·  Configure sua equipe em Coleção  ·  Tab para navegar, Enter para selecionar"
	footer.add_theme_color_override("font_color", Color("ffb8a8") if app.campaign.error_text != "" else app.MUTED)
	scroll.set_deferred("scroll_vertical", 0)

func _surface(color: Color = SURFACE, border := Color("263b54"), padding := 18) -> StyleBoxFlat:
	var style: StyleBoxFlat = app._style(color, border)
	style.set_corner_radius_all(14)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _text(parent: Node, value: String, font_size: int = 16, color := Color("cad7ea")) -> Label:
	var label: Label = app._label(value, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _heading(parent: Node, value: String, font_size := 30, color := WHITE) -> Label:
	var label := _text(parent, value, font_size, color)
	label.add_theme_font_override("font", preload("res://assets/space-grotesk.ttf"))
	return label

func _panel(parent: Node, border := Color("263b54")) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _surface(SURFACE, border))
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	return column

func _portrait(parent: Node, hero: Dictionary, dimensions: Vector2, full := false) -> TextureRect:
	var art := TextureRect.new()
	art.texture = Fighter.portrait(int(hero.index), full)
	art.custom_minimum_size = dimensions
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(art)
	return art

func _row(parent: Node, gap := 14, adaptive := false) -> BoxContainer:
	var row: BoxContainer = HBoxContainer.new() if not adaptive or wide else VBoxContainer.new()
	row.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", gap)
	parent.add_child(row)
	return row

func _menu() -> void:
	var row := _row(body, 28, true)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.20
	left.add_theme_constant_override("separation", 18)
	row.add_child(left)
	_text(left, "UMA CIDADE. CINCO RESSONÂNCIAS.", 12, CYAN)
	_heading(left, "O mundo ainda\nse lembra.", 58 if wide else 38)
	_text(left, "Reúna seu trio. Recupere as vozes do Farol.\nEscolha como lutar em uma jornada de três capítulos.", 19)
	_text(left, "Combate tático em 2D, habilidades que se combinam e uma equipe que cresce com suas escolhas.", 15, app.MUTED)
	story_button = app._button("COMEÇAR HISTÓRIA  →" if app.campaign.cleared == 0 else "CONTINUAR HISTÓRIA  ·  %d/%d  →" % [app.campaign.cleared, Campaign.MISSIONS.size()], _continue_story)
	story_button.custom_minimum_size.y = 54
	story_button.add_theme_stylebox_override("normal", _surface(Color("123b50"), CYAN, 14))
	story_button.add_theme_color_override("font_color", CYAN)
	left.add_child(story_button)
	var choices := _row(left, 10)
	play_button = app._button("Combate livre", app._enter_free)
	play_button.custom_minimum_size = Vector2(180,44)
	choices.add_child(play_button)
	var collection: Button = app._button("Minha coleção", open.bind("heroes"))
	collection.custom_minimum_size = Vector2(180,44)
	choices.add_child(collection)
	_text(left, "3 capítulos  /  9 missões  /  15 heróis", 12, CYAN)
	var right := _panel(row, Color("36576d"))
	right.size_flags_stretch_ratio = 1.0
	_text(right, "SEU PRÓXIMO DESTINO", 11, CYAN)
	var chapter: int = mini(2, int(mini(app.campaign.cleared,8)/3.0))
	var record: Dictionary = Campaign.CHAPTERS[chapter]
	var art := TextureRect.new()
	art.texture = _chapter_art(chapter)
	art.custom_minimum_size = Vector2(0,240 if wide else 160)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = MOUSE_FILTER_IGNORE
	right.add_child(art)
	_text(right, record.eyebrow, 11, Color(record.color))
	_heading(right, record.name, 29)
	_text(right, record.summary, 15, app.MUTED)
	var progress := ProgressBar.new()
	progress.max_value = Campaign.MISSIONS.size()
	progress.value = app.campaign.cleared
	progress.custom_minimum_size.y = 8
	progress.show_percentage = false
	right.add_child(progress)

func _continue_story() -> void:
	selected_chapter = mini(2, int(mini(app.campaign.cleared,8)/3.0))
	open("story")
	next_mission_button.grab_focus()

func _chapter_art(index: int) -> Texture2D:
	if index == 1 and ResourceLoader.exists("res://assets/environments/tidal-observatory.png"): return load("res://assets/environments/tidal-observatory.png")
	return preload("res://assets/arena.png") if index == 2 else preload("res://assets/nexus-sanctum.png")

func _play_menu() -> void:
	_text(body, "JOGAR  /  ESCOLHA SEU MODO", 11, CYAN)
	_heading(body, "Seu ritmo. Sua equipe.", 38)
	var row := _row(body,18,true)
	for item in [["Contra a IA", "Pratique combinações, escolha a dificuldade e ative o automático quando quiser.", "training"], ["Duelo local", "Duas pessoas no mesmo dispositivo, com os mesmos atributos e regras.", "local"]]:
		var card := _panel(row)
		_heading(card,item[0],26)
		_text(card,item[1],16,app.MUTED)
		var chosen_mode: String = item[2]
		var launch: Button = app._button("Preparar equipes  →", func():
			app.mode = chosen_mode
			app.mode_picker.select(0 if chosen_mode == "training" else 1)
			app._save_preferences()
			app._enter_free())
		launch.custom_minimum_size.y = 48
		card.add_child(launch)
	_text(body,"Na campanha, gemas aprimoram seus heróis. O combate livre preserva os atributos de referência.",14,app.MUTED)

func _extras() -> void:
	_text(body,"EXTRAS  /  APRENDER E EXPLORAR",11,CYAN)
	_heading(body,"Tudo no seu lugar.",36)
	var grid := GridContainer.new()
	grid.columns = 2 if wide else 1
	grid.add_theme_constant_override("h_separation",16)
	grid.add_theme_constant_override("v_separation",16)
	body.add_child(grid)
	for item in [["Aprender a jogar","Treinos guiados sobre afinidades, escudos e estados.",app._show_lessons], ["Galeria de golpes","Explore as habilidades dos quinze heróis.",app._open_showcase], ["Afinidades e regras","Consulte vantagens e funcionamento do combate.",app._show_classes], ["Laboratório","Simulações, resultados e registros de balanceamento.",app._show_lab], ["Arquivo 3D · Vesper","O estudo de modelo e animações permanece disponível.",app._open_vesper]]:
		var card := _panel(grid)
		_heading(card,item[0],23)
		_text(card,item[1],14,app.MUTED)
		card.add_child(app._button("Abrir  →",item[2]))

func _team_row(parent: Node) -> void:
	var row := _row(parent)
	for index in range(3):
		var hero: Dictionary = app.catalog.hero_by_id[app.campaign.team[index]]
		var card := _panel(row, app.catalog.affinity_color(hero.classId).darkened(0.55))
		var identity := _row(card, 10)
		_portrait(identity, hero, Vector2(43, 60))
		var labels := VBoxContainer.new()
		labels.size_flags_horizontal = SIZE_EXPAND_FILL
		identity.add_child(labels)
		_heading(labels, hero.name, 18)
		_text(labels, "FRENTE" if index == 0 else "RETAGUARDA", 10, app.MUTED)
		_text(labels, app.campaign.summary(hero.id), 11, CYAN)
	var buttons := VBoxContainer.new()
	row.add_child(buttons)
	team_button = app._button("Escolher trio", app._open_roster)
	buttons.add_child(team_button)
	buttons.add_child(app._button("Engastes", open.bind("gems")))

func _select_chapter(index: int) -> void:
	selected_chapter = clampi(index,0,Campaign.CHAPTERS.size()-1)
	open("story")
	chapter_buttons[selected_chapter].grab_focus()

func _story() -> void:
	_text(body,"MODO HISTÓRIA  /  JORNADA DO FAROL",11,CYAN)
	var top := _row(body,18,true)
	_heading(top,"Sua jornada",36)
	var next_mission: int = mini(app.campaign.cleared,Campaign.MISSIONS.size()-1)
	next_mission_button = app._button("Continuar · missão %02d  →" % (next_mission+1) if app.campaign.cleared < Campaign.MISSIONS.size() else "Revisitar o desfecho  →",app._begin_mission.bind(next_mission))
	next_mission_button.custom_minimum_size = Vector2(285,48)
	next_mission_button.add_theme_color_override("font_color",CYAN)
	top.add_child(next_mission_button)
	_text(body,"%d/%d missões concluídas · Cada primeira vitória concede uma gema. Repetições preservam seu progresso." % [app.campaign.cleared,Campaign.MISSIONS.size()],13,app.MUTED)
	var chapters := _row(body,12,true)
	for index in range(Campaign.CHAPTERS.size()):
		var chapter: Dictionary = Campaign.CHAPTERS[index]
		var unlocked: bool = app.campaign.cleared >= index*3
		var completed: int = clampi(app.campaign.cleared-index*3,0,3)
		var button: Button = app._button("%s  ·  %d/3\n%s%s" % [chapter.eyebrow,completed,chapter.name,"  ·  BLOQUEADO" if not unlocked else ""],_select_chapter.bind(index))
		button.custom_minimum_size.y = 76
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size",15)
		button.add_theme_stylebox_override("normal",_surface(Color("103044") if selected_chapter == index else SURFACE,Color(chapter.color) if selected_chapter == index else Color("263b54"),12))
		button.tooltip_text = "Você pode consultar este capítulo. Para jogar, conclua o anterior." if not unlocked else chapter.summary
		chapters.add_child(button)
		chapter_buttons.append(button)
	var chapter: Dictionary = Campaign.CHAPTERS[selected_chapter]
	var overview := _panel(body,Color(chapter.color).darkened(.5))
	var chapter_row := _row(overview,20,true)
	var art := TextureRect.new()
	art.texture = _chapter_art(selected_chapter)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.custom_minimum_size = Vector2(270,140)
	chapter_row.add_child(art)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = SIZE_EXPAND_FILL
	words.add_theme_constant_override("separation",8)
	chapter_row.add_child(words)
	_heading(words,chapter.name,28,Color(chapter.color))
	_text(words,chapter.summary,15)
	_text(words,chapter.lesson,13,app.MUTED)
	_team_row(body)
	var missions := _row(body,14,true)
	for index in range(selected_chapter*3,selected_chapter*3+3):
		var mission: Dictionary = Campaign.MISSIONS[index]
		var intel: Dictionary = Codex.mission(index)
		var unlocked: bool = app.campaign.can_play(index)
		var complete: bool = index < app.campaign.cleared
		var card := _panel(missions,Color("447080") if unlocked else Color("253348"))
		_text(card,"CONCLUÍDA" if complete else "DISPONÍVEL" if unlocked else "BLOQUEADA · CONCLUA A ANTERIOR",11,CYAN if unlocked else app.MUTED)
		_heading(card,mission.name,21)
		_text(card,mission.location,10,app.MUTED)
		var enemies := _row(card,8)
		enemies.alignment = BoxContainer.ALIGNMENT_CENTER
		for id in mission.enemies: _portrait(enemies,app.catalog.hero_by_id[id],Vector2(54,65))
		_text(card,intel.before,14)
		_text(card,"TÁTICA  /  "+mission.tip,12,Color("a7c3de"))
		var reward: Dictionary = app.campaign.gem(mission.reward)
		_text(card,("RECEBIDA  /  " if complete else "PRIMEIRA VITÓRIA  /  ")+reward.name,12,Color(reward.color))
		var launch: Button = app._button("Rejogar missão" if complete else "Jogar missão  →" if unlocked else "Missão bloqueada",app._begin_mission.bind(index))
		launch.disabled = not unlocked
		launch.tooltip_text = mission.name + "\n" + (mission.tip if unlocked else "Conclua a missão anterior para desbloquear.")
		launch.custom_minimum_size.y = 46
		card.add_child(launch)
		mission_buttons.append(launch)
		mission_slots[index] = launch
		if complete:
			var archive := _panel(card,Color("263b4a"))
			_text(archive,"REGISTRO RECUPERADO",10,CYAN)
			_text(archive,intel.after,12,app.MUTED)
	if app.campaign.cleared >= (selected_chapter+1)*3:
		var ending := _panel(body,Color(chapter.color).darkened(.4))
		_heading(ending,"Capítulo concluído",25,Color(chapter.color))
		_text(ending,Campaign.MISSIONS[selected_chapter*3+2].ending,15)

func _heroes() -> void:
	var introduction := VBoxContainer.new()
	introduction.add_theme_constant_override("separation", 5)
	body.add_child(introduction)
	_text(introduction, "ARQUIVO DE RESSONÂNCIA  /  20 HERÓIS", 11, CYAN)
	_heading(introduction, "Cada herói, uma razão para lutar.", 30)
	_text(introduction, "Afinidade define vantagens. Função define o estilo. Você escolhe livremente os três integrantes da equipe.", 13, app.MUTED)
	var split := _row(body, 20, true)
	var roster := _panel(split)
	if wide:
		roster.get_parent().size_flags_horizontal = SIZE_FILL
		roster.get_parent().custom_minimum_size.x = 310
	_text(roster, "ELENCO  /  SELECIONE UM HERÓI", 11, CYAN)
	var grid := GridContainer.new()
	grid.columns = 3 if wide else 5
	grid.size_flags_horizontal = SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	roster.add_child(grid)
	for entry in app.catalog.heroes:
		var hero: Dictionary = entry
		var color: Color = app.catalog.affinity_color(hero.classId)
		var button: Button = app._button("", _choose_hero.bind(hero.id))
		button.custom_minimum_size = Vector2(82, 104 if wide else 86)
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.add_theme_stylebox_override("normal", _surface(color.darkened(0.80) if selected_hero == hero.id else Color("0b1423"), color if selected_hero == hero.id else Color("20334b"), 5))
		button.tooltip_text = "%s · %s · %s" % [hero.name, app.catalog.class_by_id[hero.classId].name, hero.role]
		grid.add_child(button)
		var content := VBoxContainer.new()
		content.mouse_filter = MOUSE_FILTER_IGNORE
		content.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		content.offset_top = 5
		content.offset_bottom = -5
		content.add_theme_constant_override("separation", 1)
		button.add_child(content)
		var portrait := _portrait(content, hero, Vector2(0, 57 if wide else 43))
		portrait.size_flags_horizontal = SIZE_EXPAND_FILL
		var name_label := _text(content, hero.name, 12, WHITE)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = MOUSE_FILTER_IGNORE
		var role := _text(content, hero.role.to_upper(), 9, color)
		role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		role.mouse_filter = MOUSE_FILTER_IGNORE
		hero_buttons[hero.id] = button
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 16)
	split.add_child(detail)
	var selected: Dictionary = app.catalog.hero_by_id[selected_hero]
	var record: Dictionary = Codex.entry(selected_hero)
	var tint: Color = app.catalog.affinity_color(selected.classId)
	var top := _panel(detail, tint.darkened(0.30))
	var identity := _row(top, 20)
	var portrait := _portrait(identity, selected, Vector2(166 if wide else 120, 205 if wide else 180), true)
	portrait.size_flags_vertical = SIZE_EXPAND_FILL
	var words := VBoxContainer.new()
	words.size_flags_horizontal = SIZE_EXPAND_FILL
	words.add_theme_constant_override("separation", 7)
	identity.add_child(words)
	var affinity: Dictionary = app.catalog.class_by_id[selected.classId]
	_text(words, "%s  /  %s" % [affinity.name.to_upper(), selected.role.to_upper()], 12, tint)
	hero_name = _heading(words, selected.name.to_upper(), 34)
	_text(words, selected.title, 16, WHITE)
	_text(words, selected.get("specialty", selected.role) + " · " + selected.identity + ".", 13, app.MUTED)
	var stats := _row(words, 9)
	for item in [["VIDA", selected.hp], ["ATQ", selected.attack], ["DEF", selected.defense], ["VEL", selected.speed]]:
		var stat := _panel(stats, Color("21374f"))
		stat.get_parent().add_theme_stylebox_override("panel", _surface(Color("0a1322"), Color("21374f"), 10))
		stat.add_theme_constant_override("separation", 2)
		_text(stat, item[0], 10, app.MUTED)
		_heading(stat, str(int(item[1])), 20)
	var strong: Dictionary = app.catalog.class_by_id[affinity.strongAgainst]
	var weak: Dictionary = app.catalog.class_by_id[affinity.weakAgainst]
	_text(words, "Vantagem contra %s  +%s  ·  Resistência de %s  −%s" % [strong.name, RulesText.percent(app.combat.rules.affinity.advantageMultiplier - 1), weak.name, RulesText.percent(1 - app.combat.rules.affinity.resistanceMultiplier)], 11, tint)
	hero_details = TabContainer.new()
	hero_details.size_flags_horizontal = SIZE_EXPAND_FILL
	hero_details.custom_minimum_size.y = 350
	hero_details.add_theme_stylebox_override("panel", _surface(SURFACE, Color("263b54"), 16))
	hero_details.add_theme_stylebox_override("tab_selected", _surface(Color("16344b"), CYAN, 11))
	hero_details.add_theme_stylebox_override("tab_unselected", _surface(Color("0b1526"), Color("223448"), 11))
	hero_details.add_theme_color_override("font_selected_color", CYAN)
	detail.add_child(hero_details)
	var skills := _tab("Habilidades")
	_text(skills, "SINERGIA  /  " + selected.synergy, 14, tint)
	var skill_row := _row(skills, 12, true)
	for action_id in ["basic", "skill", "ultimate"]:
		var action: Dictionary = selected[action_id]
		var card := _panel(skill_row, tint.darkened(0.57))
		var header := _row(card, 9)
		var image := TextureRect.new()
		image.texture = AbilityArt.icon(int(selected.index), action_id)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(60, 60)
		header.add_child(image)
		var action_words := VBoxContainer.new()
		action_words.size_flags_horizontal = SIZE_EXPAND_FILL
		header.add_child(action_words)
		_text(action_words, {"basic": "ATAQUE", "skill": "TÉCNICA", "ultimate": "SUPREMO"}[action_id], 10, tint)
		_heading(action_words, action.name, 17)
		_text(card, "+%d energia" % int(app.combat.rules.energy.basicGain) if action_id == "basic" else "%d energia  ·  %s" % [action.cost, "recarga de %d ações" % action.cooldown if action.cooldown > 0 else "sem recarga"], 12, CYAN)
		_text(card, action.description, 14)
	_text(skills, "Valores base antes de defesa, afinidade, crítico e efeitos. Escudos não acumulam: limite de %s da vida, por %d ações do protegido. Sangramento reduz cura em %s." % [RulesText.percent(app.combat.rules.shield.maxHpRatio), int(app.combat.rules.shield.durationActions), RulesText.percent(1 - app.combat.rules.status.bleedHealingMultiplier)], 12, app.MUTED)
	var story := _tab("História")
	_text(story, record.origin.to_upper(), 11, tint)
	_heading(story, "“" + record.quote + "”", 22, WHITE)
	hero_lore = _text(story, record.story, 16)
	_text(story, "MOTIVAÇÃO  /  " + record.calling, 14, tint)
	_text(story, "NO FAROL  /  " + record.connection, 14, app.MUTED)
	var gems := _tab("Engastes")
	_gem_loadout(gems, true)
	hero_details.current_tab = clampi(hero_tab, 0, 2)
	hero_details.tab_changed.connect(func(index): hero_tab = index)

func _tab(title: String) -> VBoxContainer:
	var container := ScrollContainer.new()
	container.name = title
	container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hero_details.add_child(container)
	var contents := VBoxContainer.new()
	contents.size_flags_horizontal = SIZE_EXPAND_FILL
	contents.add_theme_constant_override("separation", 14)
	container.add_child(contents)
	return contents

func _choose_hero(id: String) -> void:
	selected_hero = id
	selected_slot = 0
	message = ""
	open(page)

func _gems() -> void:
	var hero: Dictionary = app.catalog.hero_by_id[selected_hero]
	var tint: Color = app.catalog.affinity_color(hero.classId)
	var introduction := VBoxContainer.new()
	introduction.add_theme_constant_override("separation", 5)
	body.add_child(introduction)
	_text(introduction, "COLEÇÃO  /  OFICINA DE RESSONÂNCIA", 11, CYAN)
	_heading(introduction, "Prepare seu herói", 32)
	_text(introduction, "Selecione um engaste, confira os atributos e escolha uma gema. Trocas e remoções são gratuitas; bônus valem na história.", 14, app.MUTED)
	var layout := _row(body, 16, true)
	var character := _panel(layout, tint.darkened(.4))
	character.get_parent().size_flags_stretch_ratio = .85
	_text(character, "PERSONAGEM", 11, tint)
	hero_picker = OptionButton.new()
	hero_picker.custom_minimum_size.y = 40
	for entry in app.catalog.heroes: hero_picker.add_item("%s · %s" % [entry.name, entry.get("specialty", entry.role)])
	hero_picker.select(app.catalog.heroes.find(hero))
	hero_picker.item_selected.connect(func(index): _choose_hero(app.catalog.heroes[index].id))
	character.add_child(hero_picker)
	var portrait := _portrait(character, hero, Vector2(230, 240), true)
	portrait.size_flags_horizontal = SIZE_EXPAND_FILL
	_heading(character, hero.name.to_upper(), 28, tint)
	_text(character, "%s · %s" % [app.catalog.class_by_id[hero.classId].name, hero.get("specialty", hero.role)], 13)
	_text(character, hero.identity, 12, app.MUTED)
	character.add_child(app._button("Habilidades e sinergias →", open.bind("heroes")))
	var equipment := _panel(layout, Color("355770"))
	equipment.get_parent().size_flags_stretch_ratio = .95
	_text(equipment, "ENGASTES  /  3 ESPAÇOS", 11, CYAN)
	var equipped: Array = app.campaign.slots(selected_hero)
	for index in range(Campaign.SLOT_COUNT):
		var item: Dictionary = app.campaign.gem(equipped[index])
		var row := _row(equipment, 6)
		var button: Button = app._button("%02d  %s\n%s" % [index+1, item.name if not item.is_empty() else "Engaste vazio", item.effect if not item.is_empty() else "Selecione para equipar"], _select_slot.bind(index))
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 65
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_stylebox_override("normal", _surface(Color("153348") if selected_slot == index else Color("0a1424"), CYAN if selected_slot == index else Color("2b4056"), 9))
		button.tooltip_text = "Engaste %d · %s" % [index+1, item.detail if not item.is_empty() else "Aceita qualquer tipo de gema."]
		row.add_child(button)
		slot_buttons.append(button)
		var remove: Button = app._button("×", _remove_slot.bind(index))
		remove.disabled = item.is_empty()
		remove.tooltip_text = "Desengastar a gema do espaço %d e devolver ao inventário" % (index+1)
		remove.custom_minimum_size = Vector2(36, 40)
		_tight_button(remove, 40)
		row.add_child(remove)
		if index == selected_slot: remove_button = remove
	_text(equipment, "ATRIBUTOS NA PRÓXIMA MISSÃO", 10, CYAN)
	var bonus: Dictionary = app.campaign.bonuses(selected_hero)
	for stat in [["Vida", hero.hp, app.combat.rounded(hero.hp*(1+bonus.health)), "8bd5a4"], ["Ataque", hero.attack, app.combat.rounded(hero.attack*(1+bonus.attack)), "f49b70"], ["Energia inicial", int(app.combat.rules.energy.initial), mini(int(app.combat.rules.energy.maximum), int(app.combat.rules.energy.initial)+int(bonus.energy)), "a9a0f6"]]:
		_text(equipment, "%s   %d → %d  (+%d)" % [stat[0], stat[1], stat[2], stat[2]-stat[1]], 14, Color(stat[3]))
	var fill: Button = app._button("Preencher vazios por função", _fill_gems)
	fill.disabled = not equipped.has("") or not Campaign.GEMS.any(func(g): return app.campaign.available(g.id) > 0)
	fill.tooltip_text = "Usa somente cópias livres: dano prioriza ataque, tanque vida e suporte energia. Preserva engastes ocupados e os outros heróis."
	fill_button = fill
	equipment.add_child(fill)
	var remove_all: Button = app._button("Desengastar tudo", _remove_all_gems)
	remove_all.disabled = equipped.all(func(id): return id == "")
	remove_all_button = remove_all
	equipment.add_child(remove_all)
	var inventory := _panel(layout, Color("524774"))
	inventory.get_parent().size_flags_stretch_ratio = 1.15
	inventory.add_theme_constant_override("separation", 8)
	_text(inventory, "INVENTÁRIO COMPARTILHADO", 11, VIOLET)
	_text(inventory, "DESTINO  /  %s · engaste %02d" % [hero.name, selected_slot+1], 13, CYAN)
	gem_preview_label = _text(inventory, "Passe sobre uma gema ou use Tab para conferir os atributos após a troca.", 12, app.MUTED)
	gem_preview_label.custom_minimum_size.y = 32
	for type in Campaign.GEMS:
		var card := _panel(inventory, Color(type.color).darkened(.55))
		card.get_parent().add_theme_stylebox_override("panel", _surface(Color("091323"), Color(type.color).darkened(.55), 8))
		card.add_theme_constant_override("separation", 3)
		var line := _row(card, 9)
		var icon := GemIcon.new()
		icon.tint = Color(type.color)
		icon.custom_minimum_size = Vector2(28, 28)
		line.add_child(icon)
		var words := VBoxContainer.new()
		words.size_flags_horizontal = SIZE_EXPAND_FILL
		line.add_child(words)
		_heading(words, type.name + " · " + type.effect, 15, Color(type.color))
		var free: int = app.campaign.available(type.id)
		_text(card, "%d livres   ·   %d equipadas   ·   %d no total" % [free, app.campaign.copies(type.id)-free, app.campaign.copies(type.id)], 11, app.MUTED)
		var current: bool = equipped[selected_slot] == type.id
		var button: Button = app._button("Já neste engaste" if current else "Engastar no espaço %02d →" % (selected_slot+1) if free > 0 else "Sem cópias livres", _equip.bind(type.id))
		button.disabled = current or free <= 0
		button.tooltip_text = _gem_preview(type.id)
		var preview_text: String = button.tooltip_text
		button.mouse_entered.connect(func(): gem_preview_label.text = preview_text)
		button.focus_entered.connect(func(): gem_preview_label.text = preview_text)
		button.add_theme_font_size_override("font_size", 12)
		_tight_button(button, 28)
		card.add_child(button)
		gem_buttons[type.id] = button
		var owners: Array = []
		var owner_row := _row(card, 5)
		var picker := OptionButton.new()
		picker.size_flags_horizontal = SIZE_EXPAND_FILL
		picker.add_theme_font_size_override("font_size", 11)
		for entry in app.catalog.heroes:
			var slots: Array = app.campaign.slots(entry.id)
			for index in range(Campaign.SLOT_COUNT):
				if slots[index] != type.id: continue
				if entry.id == selected_hero and index == selected_slot: continue
				owners.append({"hero": entry.id, "slot": index})
				picker.add_item("%s · espaço %02d" % [entry.name, index+1])
		if owners.is_empty(): picker.add_item("Nenhuma cópia para transferir")
		_tight_button(picker, 28)
		owner_row.add_child(picker)
		var bring: Button = app._button("Trazer", _transfer_gem.bind(picker, owners))
		bring.disabled = owners.is_empty()
		bring.tooltip_text = "Move a cópia do herói escolhido para este engaste. A gema substituída volta ao inventário."
		bring.add_theme_font_size_override("font_size", 12)
		_tight_button(bring, 28)
		owner_row.add_child(bring)
		transfer_buttons[type.id] = bring
		owner_pickers[type.id] = picker

func _gem_preview(type: String) -> String:
	var hero: Dictionary = app.catalog.hero_by_id[selected_hero]
	var bonus: Dictionary = app.campaign.bonuses(selected_hero).duplicate()
	var previous: Dictionary = app.campaign.gem(app.campaign.slots(selected_hero)[selected_slot])
	var next: Dictionary = app.campaign.gem(type)
	if not previous.is_empty(): bonus["health" if previous.stat == "maxHp" else previous.stat] -= previous.bonus
	bonus["health" if next.stat == "maxHp" else next.stat] += next.bonus
	return "Após a troca: %d vida · %d ataque · %d energia inicial. A gema anterior retorna ao inventário." % [app.combat.rounded(hero.hp*(1+bonus.health)), app.combat.rounded(hero.attack*(1+bonus.attack)), mini(int(app.combat.rules.energy.maximum), int(app.combat.rules.energy.initial)+int(bonus.energy))]

func _remove_slot(index: int) -> void:
	selected_slot = index
	_equip("")

func _remove_all_gems() -> void:
	if app.campaign.remove_gems(selected_hero): message = "Todas as gemas de %s voltaram ao inventário." % app.catalog.hero_by_id[selected_hero].name
	open(page)

func _fill_gems() -> void:
	if app.campaign.fill_gems(selected_hero): message = "Espaços vazios preenchidos com cópias livres. Os outros heróis mantiveram seus engastes."
	open(page)

func _transfer_gem(picker: OptionButton, owners: Array) -> void:
	if picker.selected < 0 or picker.selected >= owners.size(): return
	var source: Dictionary = owners[picker.selected]
	if app.campaign.transfer_gem(source.hero, source.slot, selected_hero, selected_slot): message = "Gema transferida de %s para %s. A cópia substituída voltou ao inventário." % [app.catalog.hero_by_id[source.hero].name, app.catalog.hero_by_id[selected_hero].name]
	open(page)

func _gem_loadout(parent: Node, compact := false) -> void:
	var hero: Dictionary = app.catalog.hero_by_id[selected_hero]
	var equipped: Array = app.campaign.slots(selected_hero)
	var bonus: Dictionary = app.campaign.bonuses(selected_hero)
	var summary := _panel(parent, Color("355770"))
	if compact:
		parent.add_theme_constant_override("separation", 6)
		summary.get_parent().add_theme_stylebox_override("panel", _surface(SURFACE, Color("355770"), 10))
		summary.add_theme_constant_override("separation", 6)
	else:
		_text(summary, "ENGASTES DE " + hero.name.to_upper() + "  /  HISTÓRIA", 11, CYAN)
	var hp: int = int(floor(hero.hp * (1.0 + float(bonus.health)) + 0.5))
	var attack: int = int(floor(hero.attack * (1.0 + float(bonus.attack)) + 0.5))
	var initial_energy: int = int(app.combat.rules.energy.initial)
	_text(summary, "VIDA %d → %d   ·   ATQ %d → %d   ·   EN INICIAL %d → %d" % [hero.hp, hp, hero.attack, attack, initial_energy, mini(int(app.combat.rules.energy.maximum), initial_energy + int(bonus.energy))], 13)
	var row := _row(summary, 6 if compact else 10)
	for index in range(3):
		var item: Dictionary = app.campaign.gem(equipped[index])
		var button: Button = app._button("%02d  ·  %s" % [index + 1, item.name if not item.is_empty() else "ESPAÇO VAZIO"], _select_slot.bind(index))
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 43
		button.add_theme_font_size_override("font_size", 11)
		button.add_theme_stylebox_override("normal", _surface(Color("16344b") if selected_slot == index else Color("0b1526"), CYAN if selected_slot == index else Color("2c4058"), 10))
		if compact: _tight_button(button, 34)
		button.tooltip_text = "Selecionar engaste %d. %s" % [index + 1, item.effect if not item.is_empty() else "Pode receber qualquer gema disponível."]
		row.add_child(button)
		slot_buttons.append(button)
	var target := _row(summary, 6 if compact else 12)
	_text(target, "ENGASTE %02d  ·  escolha uma gema abaixo" % (selected_slot + 1) if compact else "EDITANDO ENGASTE %02d  ·  escolha uma gema abaixo" % (selected_slot + 1), 11, CYAN)
	remove_button = app._button("Remover gema", _equip.bind(""))
	remove_button.disabled = equipped[selected_slot] == ""
	remove_button.add_theme_font_size_override("font_size", 12)
	if compact:
		remove_button.add_theme_font_size_override("font_size", 11)
		_tight_button(remove_button, 28)
	target.add_child(remove_button)
	var choices := _row(parent, 12, not compact)
	for type in Campaign.GEMS:
		var current: bool = equipped[selected_slot] == type.id
		var free: int = app.campaign.available(type.id)
		var can_replace: int = app.campaign.available(type.id, selected_hero, selected_slot)
		var card := _panel(choices, Color(type.color) if current else Color("263b54"))
		if compact:
			card.get_parent().add_theme_stylebox_override("panel", _surface(SURFACE, Color(type.color) if current else Color("263b54"), 10))
			card.get_parent().tooltip_text = type.detail
			card.add_theme_constant_override("separation", 6)
		var header := _row(card, 6 if compact else 10)
		var icon := GemIcon.new()
		icon.tint = Color(type.color)
		icon.custom_minimum_size = Vector2(32 if compact else 54, 32 if compact else 58)
		header.add_child(icon)
		var title := VBoxContainer.new()
		title.size_flags_horizontal = SIZE_EXPAND_FILL
		if compact: title.add_theme_constant_override("separation", 2)
		header.add_child(title)
		_heading(title, type.name, 14 if compact else 20, Color(type.color))
		_text(title, type.effect, 15 if compact else 22, WHITE)
		if not compact: _text(card, type.detail, 14)
		_text(card, "%d livres  /  %d cópias no inventário" % [free, app.campaign.copies(type.id)], 11, app.MUTED)
		var owners: Array[String] = []
		for id in app.campaign.equipped:
			var count: int = app.campaign.slots(id).count(type.id)
			if count > 0: owners.append("%s ×%d" % [app.catalog.hero_by_id[id].name, count])
		_text(card, "Em uso: " + (", ".join(owners) if not owners.is_empty() else "ninguém"), 10, app.MUTED)
		var button: Button = app._button("No engaste %02d" % (selected_slot + 1) if current else "Engastar  →" if can_replace > 0 else "Cópias em uso", _equip.bind(type.id))
		button.disabled = current or can_replace <= 0
		button.custom_minimum_size.y = 39
		button.add_theme_font_size_override("font_size", 12)
		if compact:
			_tight_button(button, 32)
			button.tooltip_text = type.detail
		card.add_child(button)
		gem_buttons[type.id] = button

func _tight_button(button: Button, height: int) -> void:
	button.custom_minimum_size.y = height
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style: StyleBox = button.get_theme_stylebox(state_name).duplicate() if button.has_theme_stylebox_override(state_name) else app.get_theme_stylebox(state_name, "Button").duplicate()
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		style.content_margin_left = 8
		style.content_margin_right = 8
		button.add_theme_stylebox_override(state_name, style)

func _select_slot(index: int) -> void:
	selected_slot = clampi(index, 0, 2)
	message = ""
	if page == "heroes": hero_tab = 2
	open(page)

func _equip(type: String) -> void:
	if app.campaign.equip(selected_hero, type, selected_slot):
		message = "Engaste %02d vazio. A cópia voltou ao inventário." % (selected_slot + 1) if type == "" else "%s no engaste %02d de %s. Bônus aplicado na próxima missão." % [app.campaign.gem(type).name, selected_slot + 1, app.catalog.hero_by_id[selected_hero].name]
	if page == "heroes": hero_tab = 2
	open(page)
