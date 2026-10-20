extends RefCounted
## Campaign progression is local and separate from the baseline combat catalog.
const STORE := "user://campaign-0.7.json"
const SLOT_COUNT := 3
const STARTING_COPIES := 3
const GEMS := [
	{"id": "ember", "name": "Brasa lapidada", "effect": "+4% ATQ", "detail": "Cada cópia soma 4% do ataque base na campanha; três somam 12%. Não altera recargas, críticos ou duração dos efeitos.", "color": "f49b70", "stat": "attack", "bonus": 0.04},
	{"id": "sap", "name": "Seiva cristalizada", "effect": "+5% VIDA", "detail": "Cada cópia soma 5% da vida base na campanha; três somam 15%. O limite de escudo continua sendo 25% da vida máxima.", "color": "8bd5a4", "stat": "maxHp", "bonus": 0.05},
	{"id": "pulse", "name": "Pulso de éter", "effect": "+8 EN inicial", "detail": "Cada cópia soma 8 de energia no início da missão: 48, 56 ou 64. Não aumenta a energia gerada durante o combate.", "color": "a9a0f6", "stat": "energy", "bonus": 8},
]
const CHAPTERS := [
	{"id": "beacon", "name": "O Farol Partido", "eyebrow": "CAPÍTULO I", "theme": "sanctum", "color": "79ceef", "summary": "A cidade perdeu seu pulso. Atravesse os portões, liberte o pátio e rompa a âncora que aprisiona Vesper.", "lesson": "Aprenda a escolher alvos, lidar com estados e quebrar escudos."},
	{"id": "tides", "name": "Marés da Memória", "eyebrow": "CAPÍTULO II", "theme": "tides", "color": "70dfd7", "summary": "As coordenadas do Farol levam a um observatório submerso. Recupere os nomes que a maré levou antes que a cidade esqueça seus próprios guardiões.", "lesson": "Combine dano, purificação e proteção para atravessar a maré."},
	{"id": "forge", "name": "A Última Fornalha", "eyebrow": "CAPÍTULO III", "theme": "forge", "color": "f7ae79", "summary": "O sinal roubado alimenta uma forja além do Trono. Interrompa a extração, desarme suas sentinelas e devolva ao Farol as cinco ressonâncias.", "lesson": "Administre energia, recargas e supremos no confronto final."},
]
const MISSIONS := [
	{"id": "gate", "name": "01 · Os portões quebrados", "location": "ARREDORES DO FAROL", "story": "O Farol silenciou. Sentinelas de pedra abandonaram seus postos e as raízes ganharam vida. Seu trio precisa abrir caminho até o pátio.", "enemies": ["minion-sentinel", "minion-root", "minion-acolyte"], "scale": 1.0, "reward": "ember", "tip": "Elimine o Acólito para impedir exposição da defesa. Ataques básicos podem escolher qualquer alvo.", "ending": "Os sentinelas caem. Nos cacos há um fragmento de gema e o mesmo selo que Vesper carrega em sua lâmina."},
	{"id": "court", "name": "02 · Ecos no pátio", "location": "PÁTIO DAS RAÍZES", "story": "A corrupção engrossa perto do núcleo. O selo não pertence a Vesper: alguém o está usando para prendê-lo ao Farol. Derrube os guardiões antes que a passagem se feche.", "enemies": ["minion-root", "minion-sentinel", "minion-acolyte"], "scale": 1.24, "reward": "sap", "tip": "Sangramento reduz a cura recebida em 35%. Purifique os feridos e concentre dano para diminuir as ações inimigas.", "ending": "A passagem se abre. Uma voz pede que vocês destruam a âncora do eclipse, mesmo que seu guardião lute para impedi-los."},
	{"id": "eclipse", "name": "03 · O guardião do eclipse", "location": "NÚCLEO DO FAROL · CHEFE", "story": "Preso ao núcleo, Vesper é forçado a defender a âncora. Vença o guardião e seus dois servos para quebrar o vínculo. O Vesper do seu elenco continua disponível: este é um confronto de história.", "enemies": ["boss-vesper", "minion-sentinel", "minion-acolyte"], "scale": 1.05, "reward": "pulse", "tip": "Vesper provoca e contra-ataca. Ataques em área ignoram a restrição de Provocação; o escudo dele expira e não acumula.", "ending": "O eclipse se desfaz. Livre da âncora, Vesper guarda um caco do Farol: a energia que o aprisionava veio de além do Trono. Fim do capítulo I — as coordenadas apontam para o Observatório das Marés."},
	{"id": "tidal-gate", "name": "04 · A escadaria das marés", "location": "OBSERVATÓRIO · CAIS EXTERIOR", "story": "A água recua apenas por alguns instantes. Sentinelas de sal guardam a escadaria, enquanto um coro repete nomes que ninguém mais recorda. Abra passagem até o observatório.", "enemies": ["minion-tide", "minion-acolyte", "minion-root"], "scale": 1.08, "reward": "ember", "tip": "Concentre ataques em um inimigo. Reduzir o número de adversários diminui a pressão sobre os aliados.", "ending": "Sob a escadaria, Saira ouve um nome conhecido. O coro não pertence à água: são as memórias desviadas do Farol."},
	{"id": "tidal-archive", "name": "05 · O arquivo submerso", "location": "OBSERVATÓRIO · SALA DOS NOMES", "story": "Vektor encontra os registros presos em cristais de sal. A corrupção tenta apagá-los à medida que o trio avança. Proteja os guardiões e purifique as feridas antes da subida da maré.", "enemies": ["minion-tide", "minion-siren", "minion-acolyte"], "scale": 1.08, "reward": "sap", "tip": "Cure aliados feridos; Sangramento reduz a cura. Habilidades de purificação removem estados negativos.", "ending": "Os registros voltam a ter voz. Cada nome aponta para a mesma transferência: a energia foi enviada à Última Fornalha."},
	{"id": "tidal-heart", "name": "06 · A guardiã da memória", "location": "OBSERVATÓRIO · CÂMARA LUNAR · CHEFE", "story": "A guardiã do observatório confunde o trio com os saqueadores do núcleo. Seu juramento a obriga a proteger os nomes. Rompa o selo para que ela consiga reconhecer seus aliados.", "enemies": ["boss-tide", "minion-tide", "minion-siren"], "scale": 1.0, "reward": "pulse", "tip": "A guardiã restaura os aliados. Ataque o suporte ou prepare um supremo antes de a cura estabilizar o grupo.", "ending": "A guardiã devolve os nomes à cidade e abre o caminho da forja. Fim do capítulo II — o Farol recupera sua memória, mas ainda lhe falta uma voz."},
	{"id": "forge-road", "name": "07 · A estrada das cinzas", "location": "ÚLTIMA FORNALHA · PONTE EXTERIOR", "story": "Cinzas cobrem a ponte que liga o Trono à forja. Os coletores drenam fragmentos do Farol em silêncio. Interrompa o transporte antes que outra carga atravesse o portal.", "enemies": ["minion-cinder", "minion-sentinel", "minion-acolyte"], "scale": 1.12, "reward": "ember", "tip": "Ataques básicos recuperam energia. Guarde recursos suficientes para a proteção e o golpe decisivo.", "ending": "O último coletor para. Veyra reconhece nas cargas a luz da manhã que sua cidade perdeu. A extração ainda continua no interior."},
	{"id": "forge-relay", "name": "08 · O coração das máquinas", "location": "ÚLTIMA FORNALHA · ANEL DE CONTENÇÃO", "story": "Três relés mantêm a câmara final fechada. A primeira descarga desperta suas sentinelas. Derrube o conjunto e abra uma janela para alcançar a origem do sinal.", "enemies": ["minion-cinder", "minion-tide", "minion-siren"], "scale": 1.17, "reward": "sap", "tip": "Escudos não acumulam e expiram. Renove a proteção quando necessário e use os estados de enfraquecimento.", "ending": "Os relés silenciam. Pela primeira vez, o Farol responde sem interferência. Apenas o juramento do Arconte impede que sua energia retorne."},
	{"id": "forge-heart", "name": "09 · O último juramento", "location": "ÚLTIMA FORNALHA · NÚCLEO · CHEFE", "story": "O Arconte acredita que aprisionar as ressonâncias é a única forma de impedir outra queda. Mostre que elas podem voltar a coexistir. Vença a guarda e encerre o ciclo de contenção.", "enemies": ["boss-forge", "minion-cinder", "minion-acolyte"], "scale": 1.0, "reward": "pulse", "tip": "O Arconte combina pressão em área e defesa. Preserve a cura, espere a abertura e use seus supremos em conjunto.", "ending": "As cinco ressonâncias retornam ao Farol. Os nomes, as manhãs e as vozes encontram seus lugares. Vesper quebra a última corrente. Fim do capítulo III — a cidade volta a escolher seu próprio futuro."},
]
var cleared := 0
var team: Array = []
var equipped: Dictionary = {}
var error_text := ""
var catalog
var store_path := STORE
var _backup_suffix := ""

func _init(source = null, path: String = STORE) -> void:
	catalog = source
	store_path = path
	if catalog != null:
		team = catalog.default_teams[0].duplicate()
		load_progress()

func active_hero(id: String) -> bool:
	return catalog != null and catalog.heroes.any(func(hero): return hero.id == id)

func gem(id: String) -> Dictionary:
	for item in GEMS:
		if item.id == id: return item
	return {}

func copies(id: String) -> int:
	if gem(id).is_empty(): return 0
	var count := STARTING_COPIES
	for index in range(clampi(cleared, 0, MISSIONS.size())):
		if MISSIONS[index].reward == id: count += 1
	return count

func slots(hero: String) -> Array:
	var result: Array = ["", "", ""]
	var saved: Variant = equipped.get(hero, [])
	if saved is Array:
		for index in range(mini(saved.size(), SLOT_COUNT)):
			if saved[index] is String and not gem(saved[index]).is_empty(): result[index] = saved[index]
	return result

func available(id: String, excluding_hero: String = "", excluding_slot: int = -1) -> int:
	if gem(id).is_empty(): return 0
	var used := 0
	for hero in equipped:
		var items := slots(hero)
		for index in range(SLOT_COUNT):
			if hero == excluding_hero and index == excluding_slot: continue
			if items[index] == id: used += 1
	return maxi(0, copies(id) - used)

func bonuses(hero: String) -> Dictionary:
	var result := {"attack": 0.0, "health": 0.0, "energy": 0}
	for type in slots(hero):
		var item := gem(type)
		if item.is_empty(): continue
		var key: String = "health" if item.stat == "maxHp" else item.stat
		result[key] += item.bonus
	return result

func summary(hero: String) -> String:
	var labels: PackedStringArray = []
	var items := slots(hero)
	for index in range(SLOT_COUNT):
		var item := gem(items[index])
		labels.append("%d · %s" % [index + 1, "Vazio" if item.is_empty() else item.name + " (" + item.effect + ")"])
	return " | ".join(labels)

func can_play(index: int) -> bool:
	return index >= 0 and index < MISSIONS.size() and index <= cleared

func load_progress() -> void:
	cleared = 0
	equipped.clear()
	error_text = ""
	_backup_suffix = ""
	if catalog != null: team = catalog.default_teams[0].duplicate()
	if not FileAccess.file_exists(store_path): return
	var parser := JSON.new()
	var parse_error := parser.parse(FileAccess.get_file_as_string(store_path))
	var data: Variant = parser.data
	var schema: Variant = data.get("schemaVersion") if data is Dictionary else null
	var known_schema: bool = (schema is int or schema is float) and (schema == 1 or schema == 2 or schema == 3)
	if parse_error != OK or not data is Dictionary or not known_schema:
		_backup_suffix = ".invalid.bak"
		error_text = "O progresso salvo não pôde ser lido. O arquivo foi preservado; uma cópia será guardada antes de uma nova gravação."
		return
	var legacy: bool = data.schemaVersion == 1
	if legacy: _backup_suffix = ".v1.bak"
	elif data.schemaVersion == 2: _backup_suffix = ".v2.bak"
	var repaired := false
	var count: Variant = data.get("cleared", 0)
	if (count is int or count is float) and is_finite(float(count)):
		cleared = int(clampf(float(count), 0, 3 if data.schemaVersion < 3 else MISSIONS.size()))
		repaired = float(count) != float(cleared)
	else: repaired = true
	var saved_team: Variant = data.get("team", [])
	if catalog.valid_team(saved_team) and saved_team.all(func(id): return active_hero(id)): team = saved_team.duplicate()
	else: repaired = true
	var saved_gems: Variant = data.get("equipped", {})
	if saved_gems is Dictionary:
		equipped.clear()
		for id in saved_gems:
			if not id is String or not active_hero(id):
				repaired = true
				continue
			var saved: Variant = saved_gems[id]
			if legacy and saved is String: saved = [saved, "", ""]
			if not saved is Array:
				repaired = true
				continue
			if saved.size() != SLOT_COUNT: repaired = true
			var items: Array = ["", "", ""]
			for index in range(mini(saved.size(), SLOT_COUNT)):
				var type: Variant = saved[index]
				if type is String and type == "": continue
				if not type is String or gem(type).is_empty() or available(type) <= 0:
					repaired = true
					continue
				items[index] = type
				# Register every accepted slot immediately so repeated gems consume real copies.
				equipped[id] = items.duplicate()
	else: repaired = true
	if repaired:
		if not legacy: _backup_suffix = ".invalid.bak"
		error_text = "Alguns dados do progresso eram inválidos e foram corrigidos. O original será guardado em uma cópia antes de salvar."

func _preserve_source() -> bool:
	if _backup_suffix == "" or not FileAccess.file_exists(store_path): return true
	var backup := store_path + _backup_suffix
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(backup)):
		error_text = "Não foi possível preservar o progresso anterior: há uma pasta no caminho da cópia. O arquivo original não foi substituído."
		return false
	if FileAccess.file_exists(backup):
		if FileAccess.get_file_as_string(backup) == FileAccess.get_file_as_string(store_path): return true
		var suffix := 1
		while FileAccess.file_exists(backup + ".%d" % suffix) or DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(backup + ".%d" % suffix)): suffix += 1
		backup += ".%d" % suffix
	var error := DirAccess.copy_absolute(ProjectSettings.globalize_path(store_path), ProjectSettings.globalize_path(backup))
	if error != OK:
		error_text = "Não foi possível preservar o progresso anterior: " + error_string(error) + ". O arquivo original não foi substituído."
		return false
	return true

func save_progress() -> bool:
	var temporary := store_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		error_text = "Não foi possível salvar o progresso: " + error_string(FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify({"schemaVersion": 3, "cleared": cleared, "team": team, "equipped": equipped}, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		error_text = "Não foi possível gravar o progresso: " + error_string(write_error)
		return false
	if not _preserve_source(): return false
	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(store_path))
	if error != OK:
		error_text = "Não foi possível concluir o salvamento: " + error_string(error)
		return false
	error_text = ""
	_backup_suffix = ""
	return true

func set_team(ids: Array) -> bool:
	if not catalog.valid_team(ids) or not ids.all(func(id): return active_hero(id)): return false
	var before := team.duplicate()
	team = ids.duplicate()
	if save_progress(): return true
	team = before
	return false

func equip(hero: String, type: String, slot: int = 0) -> bool:
	if not active_hero(hero) or slot < 0 or slot >= SLOT_COUNT: return false
	if type != "" and (gem(type).is_empty() or available(type, hero, slot) <= 0): return false
	var before := equipped.duplicate(true)
	var items := slots(hero)
	items[slot] = type
	if items.all(func(id): return id == ""): equipped.erase(hero)
	else: equipped[hero] = items
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
	for variant in [
		{"id":"minion-tide","source":"oren","name":"Vigia de sal","hp":820,"attack":158,"defense":82,"role":"Minion"},
		{"id":"minion-siren","source":"saira","name":"Eco da maré","hp":630,"attack":145,"defense":51,"role":"Minion"},
		{"id":"minion-cinder","source":"cindra","name":"Coletora de brasas","hp":750,"attack":171,"defense":65,"role":"Minion"},
		{"id":"boss-tide","source":"saira","name":"Guardiã das marés","hp":1550,"attack":190,"defense":85,"role":"Chefe"},
		{"id":"boss-forge","source":"rhazen","name":"Arconte da fornalha","hp":1750,"attack":207,"defense":104,"role":"Chefe"},
	]:
		var enemy: Dictionary = source.hero_by_id[variant.source].duplicate(true)
		enemy.merge(variant, true)
		enemy.visualHero = variant.source
		enemy.title = variant.name
		source.hero_by_id[enemy.id] = enemy

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
			if actor.heroId.begins_with("boss-"): actor.energy = 64
		else:
			if slots(actor.heroId).all(func(id): return id == ""): continue
			var bonus := bonuses(actor.heroId)
			# Add percentages first, then round exactly once against baseline stats.
			actor.attack = engine.rounded(actor.attack * (1.0 + bonus.attack))
			actor.maxHp = engine.rounded(actor.maxHp * (1.0 + bonus.health))
			actor.hp = actor.maxHp
			actor.energy = mini(int(engine.rules.energy.maximum), actor.energy + bonus.energy)
			actor.gem = summary(actor.heroId)
	state.campaignMission = index
	return state
