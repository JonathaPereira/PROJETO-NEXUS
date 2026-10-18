extends RefCounted
## Campaign progression is local and separate from the baseline combat catalog.
const STORE := "user://campaign-0.7.json"
const GEMS := [
	{"id": "ember", "name": "Brasa lapidada", "effect": "+4% ATQ", "detail": "Aumenta o ataque em 4%. Não altera recargas, críticos ou duração dos efeitos.", "color": "f49b70", "stat": "attack", "factor": 1.04},
	{"id": "sap", "name": "Seiva cristalizada", "effect": "+5% VIDA", "detail": "Aumenta a vida máxima e inicial em 5%. O limite de escudo continua sendo 25% da vida máxima.", "color": "8bd5a4", "stat": "maxHp", "factor": 1.05},
	{"id": "pulse", "name": "Pulso de éter", "effect": "+8 EN inicial", "detail": "Começa cada missão com 48 de energia, em vez de 40. Não aumenta a energia gerada durante o combate.", "color": "a9a0f6", "stat": "energy", "factor": 1.0},
]
const MISSIONS := [
	{"id": "gate", "name": "01 · Os portões quebrados", "location": "ARREDORES DO FAROL", "story": "O Farol silenciou. Sentinelas de pedra abandonaram seus postos e as raízes ganharam vida. Seu trio precisa abrir caminho até o pátio.", "enemies": ["minion-sentinel", "minion-root", "minion-acolyte"], "scale": 1.0, "reward": "ember", "tip": "Elimine o Acólito para impedir exposição da defesa. Ataques básicos podem escolher qualquer alvo.", "ending": "Os sentinelas caem. Nos cacos há um fragmento de gema e o mesmo selo que Vesper carrega em sua lâmina."},
	{"id": "court", "name": "02 · Ecos no pátio", "location": "PÁTIO DAS RAÍZES", "story": "A corrupção engrossa perto do núcleo. O selo não pertence a Vesper: alguém o está usando para prendê-lo ao Farol. Derrube os guardiões antes que a passagem se feche.", "enemies": ["minion-root", "minion-sentinel", "minion-acolyte"], "scale": 1.24, "reward": "sap", "tip": "Sangramento reduz a cura recebida em 35%. Purifique os feridos e concentre dano para diminuir as ações inimigas.", "ending": "A passagem se abre. Uma voz pede que vocês destruam a âncora do eclipse, mesmo que seu guardião lute para impedi-los."},
	{"id": "eclipse", "name": "03 · O guardião do eclipse", "location": "NÚCLEO DO FAROL · CHEFE", "story": "Preso ao núcleo, Vesper é forçado a defender a âncora. Vença o guardião e seus dois servos para quebrar o vínculo. O Vesper do seu elenco continua disponível: este é um confronto de história.", "enemies": ["boss-vesper", "minion-sentinel", "minion-acolyte"], "scale": 1.05, "reward": "pulse", "tip": "Vesper provoca e contra-ataca. Ataques em área ignoram a restrição de Provocação; o escudo dele expira e não acumula.", "ending": "O eclipse se desfaz. Livre da âncora, Vesper guarda um caco do Farol: a energia que o aprisionava veio de além do Trono. Fim do capítulo I — a próxima viagem ainda será escrita."},
]
var cleared := 0
var team: Array = []
var equipped: Dictionary = {}
var error_text := ""
var catalog
var store_path := STORE

func _init(source = null, path: String = STORE) -> void:
	catalog = source
	store_path = path
	if catalog != null:
		team = catalog.default_teams[0].duplicate()
		load_progress()

func active_hero(id: String) -> bool:
	return catalog.heroes.any(func(hero): return hero.id == id)

func gem(id: String) -> Dictionary:
	for item in GEMS:
		if item.id == id: return item
	return {}

func copies(id: String) -> int:
	if gem(id).is_empty(): return 0
	var count := 1
	for index in range(cleared):
		if MISSIONS[index].reward == id: count += 1
	return count

func available(id: String, excluding: String = "") -> int:
	var used := 0
	for hero in equipped:
		if hero != excluding and equipped[hero] == id: used += 1
	return copies(id) - used

func can_play(index: int) -> bool:
	return index >= 0 and index < MISSIONS.size() and index <= cleared

func load_progress() -> void:
	if not FileAccess.file_exists(store_path): return
	var parser := JSON.new()
	var parse_error := parser.parse(FileAccess.get_file_as_string(store_path))
	var data: Variant = parser.data
	if parse_error != OK or not data is Dictionary or data.get("schemaVersion") != 1:
		error_text = "O progresso salvo não pôde ser lido. O arquivo foi preservado; uma nova gravação o substituirá."
		return
	var count: Variant = data.get("cleared", 0)
	if (count is int or count is float) and is_finite(float(count)):
		cleared = clampi(int(count), 0, MISSIONS.size())
	var saved_team: Variant = data.get("team", [])
	if catalog.valid_team(saved_team) and saved_team.all(func(id): return active_hero(id)): team = saved_team.duplicate()
	var saved_gems: Variant = data.get("equipped", {})
	if saved_gems is Dictionary:
		for id in saved_gems:
			if not id is String or not active_hero(id) or not saved_gems[id] is String: continue
			var type: String = saved_gems[id]
			if not gem(type).is_empty() and available(type) > 0: equipped[id] = type

func save_progress() -> bool:
	var temporary := store_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		error_text = "Não foi possível salvar o progresso: " + error_string(FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify({"schemaVersion": 1, "cleared": cleared, "team": team, "equipped": equipped}, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		error_text = "Não foi possível gravar o progresso: " + error_string(write_error)
		return false
	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(store_path))
	if error != OK:
		error_text = "Não foi possível concluir o salvamento: " + error_string(error)
		return false
	error_text = ""
	return true

func set_team(ids: Array) -> bool:
	if not catalog.valid_team(ids) or not ids.all(func(id): return active_hero(id)): return false
	var before := team.duplicate()
	team = ids.duplicate()
	if save_progress(): return true
	team = before
	return false

func equip(hero: String, type: String) -> bool:
	if not active_hero(hero): return false
	if type != "" and (gem(type).is_empty() or available(type, hero) <= 0): return false
	var before := equipped.duplicate()
	if type == "": equipped.erase(hero)
	else: equipped[hero] = type
	if save_progress(): return true
	equipped = before
	return false

func complete(index: int) -> Dictionary:
	if not can_play(index): return {"error": "Missão bloqueada."}
	if index < cleared: return {"first": false, "saved": save_progress()}
	cleared += 1
	# Keep earned progress in memory on write failure; the result explicitly reports it.
	return {"first": true, "saved": save_progress(), "gem": gem(MISSIONS[index].reward).name}

static func _action(id: String, title: String, kind: String, power: float, description: String, effect: String = "") -> Dictionary:
	var value := {"id": id, "name": title, "kind": kind, "power": power, "description": description, "cost": {"basic": 0, "skill": 30, "ultimate": 80}[id], "cooldown": 2 if id == "skill" else 0}
	if effect != "": value.effect = effect
	return value

static func register_enemies(source) -> void:
	var definitions := [
		{"id": "minion-sentinel", "index": 24, "name": "Sentinela", "classId": "tecnico", "title": "Sentinela de cacos", "hp": 830, "attack": 149, "defense": 88, "speed": 62, "weapon": "spear", "animation": "rail", "role": "Minion", "identity": "Autômato de pedra que protege o próprio núcleo.", "synergy": "Sua barreira é pequena: concentre ataques ou elimine seus aliados.", "lore": "Antigo vigia do Farol, movido por um fragmento corrompido.",
		"basic": _action("basic", "Lança de cacos", "damage", 0.85, "85% do ataque em um alvo. Recupera 24 de energia."),
		"skill": _action("skill", "Placas fechadas", "shield", 0.12, "Escudo próprio de 12% por 2 ações. Não acumula."),
		"ultimate": _action("ultimate", "Estilhaçar", "aoe", 1.0, "100% do ataque contra todos os adversários.")},
		{"id": "minion-root", "index": 25, "name": "Rastejante", "classId": "natural", "title": "Rastejante de raiz", "hp": 670, "attack": 171, "defense": 57, "speed": 98, "weapon": "claws", "animation": "daggers", "role": "Minion", "identity": "Predador de raízes que abre feridas.", "synergy": "Sangramento reduz cura: purifique ou elimine o rastejante cedo.", "lore": "A mata despertou para defender um núcleo que nunca lhe pertenceu.",
		"basic": _action("basic", "Mordida de casca", "damage", 0.85, "85% do ataque em um alvo. Recupera 24 de energia."),
		"skill": _action("skill", "Garras farpadas", "damage", 1.1, "110% do ataque e sangramento por 2 turnos; cura recebida −35%.", "bleed"),
		"ultimate": _action("ultimate", "Bote selvagem", "damage", 1.8, "180% do ataque em um alvo.")},
		{"id": "minion-acolyte", "index": 26, "name": "Acólito", "classId": "sombrio", "title": "Acólito do Véu", "hp": 620, "attack": 165, "defense": 52, "speed": 84, "weapon": "staff", "animation": "threads", "role": "Minion", "identity": "Conjurador frágil que expõe as defesas.", "synergy": "Exposição abre espaço para o ataque dos outros minions.", "lore": "Escuta ordens nos ecos do Farol silenciado.",
		"basic": _action("basic", "Faísca do véu", "damage", 0.85, "85% do ataque em um alvo. Recupera 24 de energia."),
		"skill": _action("skill", "Selo rachado", "damage", 1.0, "100% do ataque e defesa −25% por 2 turnos.", "expose"),
		"ultimate": _action("ultimate", "Véu desfeito", "aoe", 0.9, "90% do ataque em área e ataque inimigo −20% por 2 turnos.", "weaken")},
	]
	definitions[0].skill.self = true
	for enemy in definitions:
		enemy.facesLeft = true
		source.hero_by_id[enemy.id] = enemy
	var boss: Dictionary = source.hero_by_id.vesper.duplicate(true)
	boss.merge({"id": "boss-vesper", "visualHero": "vesper", "title": "Guardião preso ao eclipse", "role": "Chefe", "hp": 1800, "attack": 205, "defense": 108, "speed": 78}, true)
	source.hero_by_id[boss.id] = boss

func battle(engine, index: int) -> Dictionary:
	if not can_play(index) or not catalog.valid_team(team): return {"error": "Missão ou equipe inválida."}
	register_enemies(engine.catalog)
	var mission: Dictionary = MISSIONS[index]
	var state: Dictionary = engine.new_battle(team, mission.enemies, "normal", 730 + index * 37)
	for actor in state.units:
		if actor.side == 1:
			actor.maxHp = engine.rounded(actor.maxHp * mission.scale)
			actor.hp = actor.maxHp
			actor.attack = engine.rounded(actor.attack * mission.scale)
			if actor.heroId == "boss-vesper": actor.energy = 64
		else:
			var item := gem(equipped.get(actor.heroId, ""))
			if item.is_empty(): continue
			match item.stat:
				"attack": actor.attack = engine.rounded(actor.attack * item.factor)
				"maxHp":
					actor.maxHp = engine.rounded(actor.maxHp * item.factor)
					actor.hp = actor.maxHp
				"energy": actor.energy = mini(100, actor.energy + 8)
			actor.gem = item.name + " · " + item.effect
	state.campaignMission = index
	return state
