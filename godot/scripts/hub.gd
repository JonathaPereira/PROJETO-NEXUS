extends Control
const Campaign = preload("res://scripts/campaign.gd")
const Fighter = preload("res://scripts/fighter.gd")
const GemIcon = preload("res://scripts/gem_icon.gd")
var app
var page := "menu"
var body: VBoxContainer
var footer: Label
var selected_hero := ""
var message := ""
var mission_buttons: Array[Button] = []
var gem_buttons: Dictionary = {}
var hero_picker: OptionButton
var remove_button: Button
var play_button: Button
var story_button: Button
var team_button: Button
var notice: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var background := TextureRect.new()
	background.texture = preload("res://assets/arena.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	background.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color("07101aeb")
	shade.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	shade.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for side in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 36)
	for side in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 10)
	column.add_child(nav)
	var logo: Label = app._label("NEXUS", 30, app.GOLD)
	logo.add_theme_font_override("font", preload("res://assets/cinzel.ttf"))
	nav.add_child(logo)
	var subtitle: Label = app._label("ECOS DO CREPÚSCULO  /  ALPHA 0.7", 11, app.MUTED)
	subtitle.size_flags_horizontal = SIZE_EXPAND_FILL
	nav.add_child(subtitle)
	for item in [["Início", "menu"], ["História", "story"], ["Gemas", "gems"]]:
		var target: String = item[1]
		nav.add_child(app._button(item[0], open.bind(target)))
	nav.add_child(app._button("Combate livre", app._enter_free))
	nav.add_child(app._button("⛶ Tela", app._show_display))
	nav.add_child(app._button("Sair", func(): get_tree().quit()))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = SIZE_EXPAND_FILL
	body.size_flags_vertical = SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	scroll.add_child(body)
	footer = app._label("", 13, app.MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(footer)

func open(target: String = "menu") -> void:
	page = target
	visible = true
	app.combat_view.hide()
	app._clear(body)
	mission_buttons.clear()
	gem_buttons.clear()
	if selected_hero == "": selected_hero = app.campaign.team[0]
	match page:
		"story": _story()
		"gems": _gems()
		_: _menu()
	footer.text = app.campaign.error_text if app.campaign.error_text != "" else message if message != "" else "Progresso salvo neste dispositivo · Gemas valem somente na história · Trocas gratuitas entre missões"
	footer.add_theme_color_override("font_color", Color("f6b696") if app.campaign.error_text != "" else app.MUTED)

func _text(parent: Node, value: String, font_size: int = 16, color := Color("c4cfdf")) -> Label:
	var label: Label = app._label(value, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _panel(parent: Node, color := Color("30435a")) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", app._style(Color("0b1828ed"), color))
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)
	return column

func _portrait(parent: Node, hero: Dictionary, dimensions: Vector2, full := false) -> TextureRect:
	var art := TextureRect.new()
	art.texture = Fighter.portrait(int(hero.index), full)
	art.custom_minimum_size = dimensions
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(art)
	return art

func _menu() -> void:
	var row := HBoxContainer.new()
	row.size_flags_vertical = SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 30)
	body.add_child(row)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.3
	left.add_theme_constant_override("separation", 20)
	row.add_child(left)
	_text(left, "CAPÍTULO I", 14, app.GOLD)
	var title := _text(left, "O Farol\nPartido", 58, Color("f0e0c3"))
	title.add_theme_font_override("font", preload("res://assets/cinzel.ttf"))
	_text(left, "Três heróis. Um núcleo em silêncio.\nUm guardião preso ao próprio eclipse.", 22)
	_text(left, "Escolha seu trio, atravesse os portões e liberte Vesper em uma história curta de três batalhas. Engaste as gemas encontradas para preparar a próxima missão.", 17, app.MUTED)
	story_button = app._button("COMEÇAR HISTÓRIA" if app.campaign.cleared == 0 else "CONTINUAR HISTÓRIA  ·  %d/3" % app.campaign.cleared if app.campaign.cleared < 3 else "REVISITAR O CAPÍTULO", open.bind("story"))
	story_button.custom_minimum_size.y = 58
	story_button.add_theme_color_override("font_color", app.GOLD)
	left.add_child(story_button)
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 12)
	left.add_child(choices)
	play_button = app._button("Combate livre", app._enter_free)
	play_button.size_flags_horizontal = SIZE_EXPAND_FILL
	play_button.custom_minimum_size.y = 46
	choices.add_child(play_button)
	var gems: Button = app._button("Engastar gemas", open.bind("gems"))
	gems.size_flags_horizontal = SIZE_EXPAND_FILL
	choices.add_child(gems)
	var tools := HBoxContainer.new()
	left.add_child(tools)
	tools.add_child(app._button("Aprender", app._show_lessons))
	tools.add_child(app._button("Galeria de golpes", app._open_showcase))
	tools.add_child(app._button("Balanço / logs", app._show_lab))
	var right := _panel(row, Color("69516b"))
	_text(right, "VESPER  /  GUARDIÃO DO ECLIPSE", 14, app.GOLD)
	var art := _portrait(right, app.catalog.hero_by_id.vesper, Vector2(0, 390), true)
	art.size_flags_vertical = SIZE_EXPAND_FILL
	_text(right, "Ele não protege o Farol por vontade própria.", 17)
	_text(right, "15 heróis disponíveis · composição livre\n3 missões · 3 tipos de gema · progresso local", 14, app.MUTED)

func _team_row(parent: Node) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)
	for index in range(3):
		var hero: Dictionary = app.catalog.hero_by_id[app.campaign.team[index]]
		var card := _panel(row)
		var identity := HBoxContainer.new()
		card.add_child(identity)
		_portrait(identity, hero, Vector2(45, 55))
		var labels := VBoxContainer.new()
		labels.size_flags_horizontal = SIZE_EXPAND_FILL
		identity.add_child(labels)
		_text(labels, hero.name + (" · FRENTE" if index == 0 else " · ATRÁS"), 15, app.GOLD)
		var item: Dictionary = app.campaign.gem(app.campaign.equipped.get(hero.id, ""))
		_text(labels, item.effect if not item.is_empty() else "Engaste vazio", 13, app.MUTED)
	var buttons := VBoxContainer.new()
	row.add_child(buttons)
	team_button = app._button("Escolher trio", app._open_roster)
	buttons.add_child(team_button)
	buttons.add_child(app._button("Engastes", open.bind("gems")))

func _story() -> void:
	_text(body, "O FAROL PARTIDO", 32, app.GOLD)
	_text(body, "Capítulo I · %d/3 missões concluídas · Escolha qualquer trio. A vida e a energia são restauradas entre missões." % app.campaign.cleared, 16)
	_team_row(body)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	body.add_child(row)
	for index in range(Campaign.MISSIONS.size()):
		var mission: Dictionary = Campaign.MISSIONS[index]
		var unlocked: bool = app.campaign.can_play(index)
		var complete: bool = index < app.campaign.cleared
		var card := _panel(row, Color("8e7753") if unlocked else Color("253348"))
		_text(card, "CONCLUÍDA" if complete else "DISPONÍVEL" if unlocked else "BLOQUEADA", 12, app.GOLD if unlocked else app.MUTED)
		_text(card, mission.name, 22, Color("eee0c5"))
		_text(card, mission.location, 11, app.MUTED)
		var enemies := HBoxContainer.new()
		enemies.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(enemies)
		for id in mission.enemies: _portrait(enemies, app.catalog.hero_by_id[id], Vector2(66, 72))
		_text(card, mission.story, 15)
		_text(card, "TÁTICA · " + mission.tip, 13, Color("9fb7ce"))
		var reward: Dictionary = app.campaign.gem(mission.reward)
		_text(card, ("RECOMPENSA RECEBIDA · " if complete else "PRIMEIRA VITÓRIA · ") + reward.name, 13, Color(reward.color))
		_text(card, "Repetir não concede outra gema." if complete else "Desbloqueia a próxima etapa." if index < 2 else "Conclusão do capítulo I.", 12, app.MUTED)
		var spacer := Control.new()
		spacer.size_flags_vertical = SIZE_EXPAND_FILL
		card.add_child(spacer)
		var launch: Button = app._button("Rejogar missão" if complete else "Jogar missão" if unlocked else "Conclua a missão anterior", app._begin_mission.bind(index))
		launch.disabled = not unlocked
		launch.custom_minimum_size.y = 42
		card.add_child(launch)
		mission_buttons.append(launch)
	if app.campaign.cleared == 3:
		_text(body, Campaign.MISSIONS[2].ending, 17, app.GOLD)

func _gems() -> void:
	_text(body, "ENGASTES", 32, app.GOLD)
	_text(body, "Um espaço por personagem · Três gemas iniciais, uma de cada tipo · Troca e remoção gratuitas", 16)
	_text(body, "Uma cópia só pode estar em um herói por vez. Cada primeira vitória concede mais uma gema. Os bônus valem somente no modo história, para todos os heróis equipados que estiverem no trio.", 14, app.MUTED)
	var summary := _panel(body)
	var identity := HBoxContainer.new()
	identity.add_theme_constant_override("separation", 20)
	summary.add_child(identity)
	var hero: Dictionary = app.catalog.hero_by_id[selected_hero]
	_portrait(identity, hero, Vector2(72, 88))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = SIZE_EXPAND_FILL
	identity.add_child(info)
	hero_picker = OptionButton.new()
	for entry in app.catalog.heroes: hero_picker.add_item("%s · %s" % [entry.name, entry.role])
	hero_picker.select(app.catalog.heroes.find(hero))
	hero_picker.item_selected.connect(func(index):
		selected_hero = app.catalog.heroes[index].id
		message = ""
		open("gems"))
	info.add_child(hero_picker)
	var item: Dictionary = app.campaign.gem(app.campaign.equipped.get(selected_hero, ""))
	_text(info, "ENGASTE · " + (item.name + " / " + item.effect if not item.is_empty() else "VAZIO"), 17, Color(item.color) if not item.is_empty() else app.GOLD)
	var hp: int = int(floor(hero.hp * (1.05 if item.get("id") == "sap" else 1.0) + 0.5))
	var attack: int = int(floor(hero.attack * (1.04 if item.get("id") == "ember" else 1.0) + 0.5))
	_text(info, "VIDA %d → %d   ·   ATQ %d → %d   ·   EN inicial 40 → %d" % [hero.hp, hp, hero.attack, attack, 48 if item.get("id") == "pulse" else 40], 14)
	remove_button = app._button("Remover gema", _equip.bind(""))
	remove_button.disabled = item.is_empty()
	identity.add_child(remove_button)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	body.add_child(row)
	for type in Campaign.GEMS:
		var current: bool = app.campaign.equipped.get(selected_hero, "") == type.id
		var free: int = app.campaign.available(type.id)
		var card := _panel(row, Color(type.color) if current else Color("30435a"))
		var icon := GemIcon.new()
		icon.tint = Color(type.color)
		icon.custom_minimum_size = Vector2(0, 92)
		card.add_child(icon)
		_text(card, type.name, 21, Color(type.color))
		_text(card, type.effect, 24, Color("eee5d4"))
		_text(card, type.detail, 15)
		var total: int = app.campaign.copies(type.id)
		_text(card, "%d %s / %d %s" % [free, "livre" if free == 1 else "livres", total, "cópia" if total == 1 else "cópias"], 14, app.MUTED)
		var owners: Array = []
		for id in app.campaign.equipped:
			if app.campaign.equipped[id] == type.id: owners.append(app.catalog.hero_by_id[id].name)
		_text(card, "Em uso: " + (", ".join(owners) if not owners.is_empty() else "ninguém"), 13, app.MUTED)
		var button: Button = app._button("Engastada neste herói" if current else "Engastar" if free > 0 else "Todas as cópias estão em uso", _equip.bind(type.id))
		button.disabled = current or free <= 0
		button.custom_minimum_size.y = 42
		card.add_child(button)
		gem_buttons[type.id] = button
	body.add_child(app._button("Voltar às missões", open.bind("story")))

func _equip(type: String) -> void:
	if app.campaign.equip(selected_hero, type):
		message = "Gema removida; a cópia voltou ao inventário." if type == "" else "%s engastada em %s. Aplicada na próxima missão." % [app.campaign.gem(type).name, app.catalog.hero_by_id[selected_hero].name]
	open("gems")
