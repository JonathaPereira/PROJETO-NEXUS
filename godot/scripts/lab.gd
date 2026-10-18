extends AcceptDialog
## Two bounded, independent local datasets: played matches and deterministic AI samples.
const Combat = preload("res://scripts/combat.gd")
const STORE := "user://balance.json"
var catalog
var source: OptionButton
var summary: Label
var table: Tree
var simulate: Button
var running := false
var rows: Array = []

static func read_records() -> Array:
	if not FileAccess.file_exists(STORE): return []
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(STORE))
	if not data is Dictionary or data.get("schema") != 1 or not data.get("matches") is Array: return []
	return data.matches.filter(func(m):
		return m is Dictionary and m.get("source") in ["played", "ai"] and m.get("rounds") is float and m.get("actions") is float and m.get("fracture") is bool and m.get("mode") is String and m.get("difficulty") is String and m.get("units") is Array and m.units.all(func(u):
			return u is Dictionary and u.get("heroId") is String and u.get("stats") is Dictionary and u.get("won") is bool and ["damage", "healing", "shieldDamage", "protected", "energyGiven", "combos"].all(func(k): return u.stats.get(k) is float)))

static func persist(records: Array) -> void:
	var file := FileAccess.open(STORE, FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"schema": 1, "matches": records.slice(maxi(0, records.size() - 500))}))

static func receipt(state: Dictionary, origin: String, mode: String, difficulty: String) -> Dictionary:
	return {"source": origin, "mode": mode, "difficulty": difficulty, "rounds": state.round, "actions": state.turns,
		"fracture": state.log.any(func(e): return e.type == "fracture"),
		"units": state.units.map(func(u): return {"heroId": u.heroId, "won": u.side == state.winner, "stats": u.stats.duplicate(true)})}

static func record(state: Dictionary, mode: String, difficulty: String) -> void:
	var data := read_records()
	data.append(receipt(state, "played", mode, difficulty))
	persist(data)

func _ready() -> void:
	title = "Laboratório de balanceamento · Alpha 0.4"
	ok_button_text = "Voltar"
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(1060, 530)
	add_child(column)
	var note := Label.new()
	note.text = "Amostras locais. Partidas jogadas incluem seu oponente IA; simulações são IA × IA, sem dados de jogadores.\nResultados dependem das equipes, dificuldade e decisões. Não representam equilíbrio competitivo."
	note.add_theme_font_size_override("font_size", 13)
	column.add_child(note)
	var toolbar := HBoxContainer.new()
	column.add_child(toolbar)
	source = OptionButton.new()
	for text in ["Partidas jogadas", "Simulações IA × IA"]: source.add_item(text)
	source.item_selected.connect(func(_i): refresh())
	toolbar.add_child(source)
	simulate = Button.new()
	simulate.text = "Simular 60 partidas"
	simulate.pressed.connect(_simulate)
	toolbar.add_child(simulate)
	summary = Label.new()
	summary.custom_minimum_size = Vector2(1040, 42)
	summary.clip_text = true
	column.add_child(summary)
	table = Tree.new()
	table.hide_root = true
	table.columns = 10
	table.column_titles_visible = true
	table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	table.custom_minimum_size.y = 360
	var titles := ["Herói / função", "Classe", "N", "Vitórias", "Dano dir.", "Dano esc.", "Cura dir.", "Absorvido*", "Energia", "Combos"]
	for i in range(titles.size()):
		table.set_column_title(i, titles[i])
		table.set_column_custom_minimum_width(i, 160 if i == 0 else 80)
	column.add_child(table)
	var foot := Label.new()
	foot.text = "Dano e cura diretos (sem ticks). Valores por aparição, exceto N e vitória. *Escudo efetivamente consumido + dano desviado pelo protetor.\nTrês funções por equipe; classes únicas e mistas, pares espelhados, dificuldade normal, sementes fixas. Até 500 partidas locais."
	foot.add_theme_font_size_override("font_size", 12)
	column.add_child(foot)
	refresh()

func refresh() -> void:
	if not is_instance_valid(table): return
	rows = read_records().filter(func(m): return m.source == ("played" if source.selected == 0 else "ai"))
	table.clear()
	var root := table.create_item()
	var rounds := 0.0
	var fractures := 0
	for row in rows:
		rounds += row.rounds
		if row.fracture: fractures += 1
	summary.text = "%d partidas · média %.1f rodadas · Fratura: %d (%.1f%%)\nVitória por herói ainda depende de quem jogou com ele e das composições usadas." % [rows.size(), rounds / maxf(1, rows.size()), fractures, fractures * 100.0 / maxf(1, rows.size())]
	for hero in catalog.heroes:
		var samples: Array = []
		for row in rows:
			for unit in row.units:
				if unit.heroId == hero.id: samples.append(unit)
		var n := samples.size()
		var totals := {"damage": 0.0, "shieldDamage": 0.0, "healing": 0.0, "protected": 0.0, "energyGiven": 0.0, "combos": 0.0}
		var wins := 0
		for unit in samples:
			if unit.won: wins += 1
			for key in totals: totals[key] += unit.stats.get(key, 0)
		# Each shield point consumed is useful protection on its owner's team.
		var absorbed := 0.0
		for row in rows:
			for unit in row.units:
				if unit.heroId == hero.id: absorbed += unit.stats.get("shieldAbsorbed", 0)
		var item := table.create_item(root)
		item.set_text(0, hero.name + " · " + hero.role)
		item.set_text(1, catalog.class_by_id[hero.classId].name)
		item.set_text(2, str(n))
		item.set_text(3, "%.1f%%" % (wins * 100.0 / n) if n else "—")
		var values: Array = [totals.damage, totals.shieldDamage, totals.healing, totals.protected + absorbed, totals.energyGiven, totals.combos]
		for i in range(values.size()): item.set_text(i + 4, "%.1f" % (values[i] / n) if n else "—")
		for i in range(10): item.set_tooltip_text(i, hero.identity + "\nSinergia: " + hero.synergy)

func _simulate() -> void:
	if running: return
	running = true
	simulate.disabled = true
	var engine = Combat.new()
	var data: Array = []
	var roles := ["Tanque", "Suporte", "Dano"]
	for pair in range(30):
		var teams: Array = [[], []]
		for side in range(2):
			for role in range(3):
				var group: int = pair / 5
				var base: int = pair % 5
				var offsets: Array = [side * 2, group + side, group * 2 + side * 3]
				var class_index: int = (base + side) % 5 if pair < 5 else (base + offsets[role]) % 5
				var affinity: String = catalog.classes[class_index].id
				teams[side].append(catalog.heroes.filter(func(h): return h.classId == affinity and h.role == roles[role])[0].id)
		for swap in range(2):
			var state := engine.new_battle(teams[swap], teams[1 - swap], "normal", 73 + pair * 113)
			while state.phase == "playing" and state.turns < 400:
				var choice := engine.choose_ai(state)
				engine.act(state, choice.actionId, choice.targetId)
			if state.phase == "finished": data.append(receipt(state, "ai", "simulation", "normal"))
		simulate.text = "Simulando %d / 60" % ((pair + 1) * 2)
		await get_tree().process_frame
	# A live battle may finish while the simulation yields frames. Preserve it.
	persist(read_records() + data)
	source.select(1)
	refresh()
	simulate.text = "Simular 60 partidas"
	simulate.disabled = false
	running = false
