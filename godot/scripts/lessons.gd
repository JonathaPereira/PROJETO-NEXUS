extends RefCounted
const TITLES = ["1 · Turnos, energia e defesa", "2 · Afinidades e combos", "3 · Escudos e dano contínuo", "4 · Purificação e Égide", "5 · Interceptação e aflições"]
const TEAMS = [
	[["veyra", "sylva", "axion"], ["vesper", "oren", "kira"]],
	[["veyra", "cindra", "saira"], ["oren", "nima", "sylva"]],
	[["riven", "oren", "sylva"], ["vesper", "maura", "astra"]],
	[["auren", "elyra", "vektor"], ["noct", "riven", "cindra"]],
	[["bast", "maura", "ivo"], ["noct", "torv", "brin"]]
]
const GOALS = [["basic", "skill", "guard"], ["advantage", "combo"], ["shieldHit", "dot", "recovery"], ["cleanse", "elementalWard", "guard"], ["spread", "cover"]]
const LABELS = {"basic": "Ataque", "skill": "Técnica", "guard": "Defesa", "advantage": "Vantagem", "combo": "Combo", "shieldHit": "Acertar escudo", "dot": "Dano contínuo", "recovery": "Cura/proteção", "cleanse": "Purificar aflições", "elementalWard": "Aplicar Égide", "spread": "Transmitir aflição", "cover": "Proteger com interceptação"}

static func prepare(state: Dictionary, index: int) -> void:
	if index == 1:
		# The visible starting burn lets the first action teach the combo.
		state.units[3].statuses = [{"type": "burn", "turns": 2}]
	if index == 2:
		for unit in state.units: unit.shield = 150
		state.units[3].statuses = [{"type": "burn", "turns": 2}]

	if index == 3:
		for unit in state.units:
			if unit.id == "0-elyra":
				unit.hp = roundi(unit.maxHp * .65)
				unit.statuses = [{"type":"bleed","turns":2},{"type":"expose","turns":2}]
	if index == 4:
		for unit in state.units:
			if unit.id == "1-noct": unit.statuses = [{"type":"darkmark","turns":2,"owner":"0-maura"}]

static func observe(progress: Dictionary, result: Dictionary, side: int) -> void:
	if side == 0:
		progress[result.actionId] = true
		for event in result.events:
			if event.type == "status" and event.get("source") == "spread": progress.spread = true
			if event.get("effect") == "cover": progress.cover = true
			if not event.get("cleansed", []).is_empty(): progress.cleanse = true
			if event.get("effect") == "elementalWard" or event.get("extraEffect") == "elementalWard": progress.elementalWard = true
			if event.get("advantage", 1) > 1: progress.advantage = true
			if event.has("combo"): progress.combo = true
			if event.get("absorbed", 0) > 0: progress.shieldHit = true
			if event.type in ["heal", "shield", "guard"]: progress.recovery = true
	for event in result.get("turnEvents", []):
		if event.type in ["burn", "bleed"]: progress.dot = true

static func complete(index: int, progress: Dictionary) -> bool:
	return GOALS[index].all(func(goal): return progress.get(goal, false))

static func hint(index: int, progress: Dictionary) -> String:
	var items: Array = []
	for goal in GOALS[index]: items.append(("Feito: " if progress.get(goal, false) else "Pendente: ") + LABELS[goal])
	var tip: String = ["Ataque dá 24 EN; defesa dá 25. Técnica custa 30.", "Oren começa queimando neste treino. A técnica de Veyra consome a queimadura: +40%. Cindra reaplica.", "Escudo absorve golpes. Queima e sangra atravessam; Sylva cura.", "Elyra começa sangrando e exposta. Auren purifica e aplica Égide; defesa recupera energia. Curas vêm antes da purificação.", "Noct começa marcado por Maura. Ivo transmite a aflição; Bast protege um aliado. Golpes em área não são desviados."][index]
	if complete(index, progress): tip = "Objetivos concluídos! Termine a batalha ou escolha outro treino em Aprender."
	return TITLES[index] + "\n" + " · ".join(items) + "\n" + tip
