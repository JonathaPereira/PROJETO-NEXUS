extends RefCounted
## Pure deterministic rules: no scene nodes, network, rendering or persistence.
const Catalog = preload("res://scripts/catalog.gd")
var catalog = Catalog.new()

func rounded(value: float) -> int:
	# JavaScript Math.round for the nonnegative quantities in this ruleset.
	return int(floor(value + 0.5))

func advantage(from: String, to: String) -> float:
	var affinity: Dictionary = catalog.class_by_id[from]
	return 1.25 if affinity.strongAgainst == to else (0.85 if affinity.weakAgainst == to else 1.0)

func new_battle(team_a: Array, team_b: Array, difficulty: String = "normal", seed_value: int = 73) -> Dictionary:
	if not catalog.valid_team(team_a) or not catalog.valid_team(team_b):
		return {"error": "Cada equipe precisa de três personagens diferentes."}
	if not difficulty in ["easy", "normal", "hard"]:
		return {"error": "Dificuldade inválida."}
	var units: Array = []
	for side in range(2):
		var team: Array = team_a if side == 0 else team_b
		var scale_factor: float = {"easy": 0.82, "normal": 1.0, "hard": 1.15}[difficulty] if side == 1 else 1.0
		for slot in range(3):
			var hero: Dictionary = catalog.hero_by_id[team[slot]]
			units.append({
				"id": "%d-%s" % [side, hero.id], "heroId": hero.id, "side": side, "slot": slot,
				"hp": rounded(hero.hp * scale_factor), "maxHp": rounded(hero.hp * scale_factor),
				"attack": rounded(hero.attack * scale_factor), "defense": hero.defense, "speed": hero.speed,
				"energy": 40, "shield": 0, "guarding": false, "statuses": [], "cooldowns": {},
				"stats": {"damage": 0, "healing": 0, "actions": 0},
			})
	var state := {"units": units, "order": [], "cursor": 0, "round": 1, "phase": "playing", "winner": null, "log": [], "random": seed_value & 0xffffffff, "turns": 0}
	state.order = _turn_order(state)
	_begin_turn(state)
	return state

func _turn_order(state: Dictionary) -> Array:
	var alive: Array = state.units.filter(func(u): return u.hp > 0)
	alive.sort_custom(func(a, b):
		if a.speed != b.speed: return a.speed > b.speed
		if a.side != b.side: return a.side < b.side
		return a.slot < b.slot)
	return alive.map(func(u): return u.id)

func unit(state: Dictionary, id: String) -> Dictionary:
	for candidate in state.units:
		if candidate.id == id:
			return candidate
	return {}

func current(state: Dictionary) -> Dictionary:
	if state.is_empty() or state.cursor >= state.order.size():
		return {}
	return unit(state, state.order[state.cursor])

func get_action(actor: Dictionary, id: String) -> Dictionary:
	return catalog.guard if id == "guard" else catalog.hero_by_id[actor.heroId].get(id, {})

func can_use(actor: Dictionary, id: String) -> bool:
	var action := get_action(actor, id)
	return not action.is_empty() and actor.hp > 0 and actor.energy >= action.cost and actor.cooldowns.get(id, 0) <= 0

func legal_targets(state: Dictionary, actor: Dictionary, action: Dictionary) -> Array:
	if action.kind == "guard": return [actor]
	var friendly: bool = action.kind.begins_with("heal") or action.kind.begins_with("shield")
	return state.units.filter(func(u): return u.hp > 0 and u.side == (actor.side if friendly else 1 - actor.side))

func _random(state: Dictionary) -> float:
	state.random = (int(state.random) * 1664525 + 1013904223) & 0xffffffff
	return float(state.random) / 4294967296.0

func _log(state: Dictionary, event: Dictionary) -> void:
	var entry := {"round": state.round}
	entry.merge(event, true)
	state.log.append(entry)
	if state.log.size() > 100: state.log.pop_front()

func _victory(state: Dictionary) -> bool:
	for side in range(2):
		if not state.units.any(func(u): return u.side == side and u.hp > 0):
			state.phase = "finished"
			state.winner = 1 - side
			return true
	return false

func _heal(target: Dictionary, amount: float) -> int:
	var healed: int = mini(target.maxHp - target.hp, rounded(amount))
	target.hp += healed
	return healed

func _status(target: Dictionary, type: String) -> void:
	if type == "cleanse":
		target.statuses = target.statuses.filter(func(s): return s.type == "regen")
		return
	for status in target.statuses:
		if status.type == type:
			status.turns = 2
			return
	target.statuses.append({"type": type, "turns": 2})

func _begin_turn(state: Dictionary) -> void:
	while state.phase == "playing":
		if state.cursor >= state.order.size():
			state.round += 1
			state.cursor = 0
			state.order = _turn_order(state)
		var actor := current(state)
		if actor.is_empty() or actor.hp <= 0:
			state.cursor += 1
			continue
		actor.guarding = false
		for id in actor.cooldowns:
			actor.cooldowns[id] = maxi(0, actor.cooldowns[id] - 1)
		if state.round >= 12:
			var amount: int = mini(actor.hp, int(ceil(actor.maxHp * minf(0.85, 0.04 + (state.round - 12) * 0.025))))
			actor.hp -= amount
			_log(state, {"type": "fracture", "actor": actor.id, "target": actor.id, "amount": amount})
			if actor.hp <= 0: _log(state, {"type": "defeated", "actor": actor.id, "target": actor.id})
		for status in actor.statuses:
			if actor.hp <= 0: break
			if status.type == "burn":
				var amount: int = mini(actor.hp, rounded(actor.maxHp * 0.065))
				actor.hp -= amount
				_log(state, {"type": "burn", "actor": actor.id, "target": actor.id, "amount": amount})
				if actor.hp <= 0:
					_log(state, {"type": "defeated", "actor": actor.id, "target": actor.id})
					break
			if status.type == "regen":
				var amount := _heal(actor, actor.maxHp * 0.07)
				_log(state, {"type": "heal", "actor": actor.id, "target": actor.id, "amount": amount, "passive": true})
			status.turns -= 1
		actor.statuses = actor.statuses.filter(func(s): return s.turns >= 0)
		if _victory(state): return
		if actor.hp <= 0:
			state.cursor += 1
			continue
		return

func act(state: Dictionary, action_id: String, target_id: String) -> Dictionary:
	if state.phase != "playing": return {"error": "A batalha terminou."}
	var actor := current(state)
	if not can_use(actor, action_id): return {"error": "Ação indisponível: energia ou recarga."}
	var action := get_action(actor, action_id)
	var targets := legal_targets(state, actor, action)
	var selected: Dictionary = {}
	for candidate in targets:
		if candidate.id == target_id: selected = candidate
	if selected.is_empty(): return {"error": "Escolha um alvo válido."}
	var events: Array = []
	var hero: Dictionary = catalog.hero_by_id[actor.heroId]
	actor.energy -= action.cost
	actor.stats.actions += 1
	state.turns += 1
	if action.cooldown > 0: actor.cooldowns[action_id] = action.cooldown + 1
	_log(state, {"type": "action", "actor": actor.id, "name": action.name, "actionId": action_id})
	if action.kind == "guard":
		actor.guarding = true
		var before_shield: int = actor.shield
		actor.shield = mini(rounded(actor.maxHp * 0.6), actor.shield + rounded(actor.maxHp * 0.12))
		actor.energy = mini(100, actor.energy + 25)
		events.append({"type": "guard", "target": actor.id, "amount": actor.shield - before_shield})
		var entry: Dictionary = events.back().duplicate()
		entry.actor = actor.id
		_log(state, entry)
	else:
		for target in targets if action.kind in ["aoe", "healAll", "shieldAll"] else [selected]:
			var event: Dictionary
			if action.kind.begins_with("heal"):
				var amount := _heal(target, target.maxHp * action.power)
				actor.stats.healing += amount
				event = {"type": "heal", "target": target.id, "amount": amount}
			elif action.kind.begins_with("shield"):
				var before: int = target.shield
				target.shield = mini(rounded(target.maxHp * 0.6), before + rounded(target.maxHp * action.power))
				event = {"type": "shield", "target": target.id, "amount": target.shield - before}
			else:
				var weak := 0.8 if actor.statuses.any(func(s): return s.type == "weaken") else 1.0
				var exposed := 0.75 if target.statuses.any(func(s): return s.type == "expose") else 1.0
				var defense: float = target.defense * exposed * (0.75 if hero.classId == "arcano" else 1.0)
				var multiplier := advantage(hero.classId, catalog.hero_by_id[target.heroId].classId)
				var critical := _random(state) < 0.1
				var total: int = maxi(1, rounded(actor.attack * weak * action.power * (100.0 / (100.0 + defense * 0.5)) * multiplier * (0.65 if target.guarding else 1.0) * (1.4 if critical else 1.0)))
				var absorbed: int = mini(target.shield, total)
				target.shield -= absorbed
				var dealt: int = mini(target.hp, total - absorbed)
				target.hp -= dealt
				actor.stats.damage += dealt
				event = {"type": "damage", "target": target.id, "amount": dealt, "absorbed": absorbed, "advantage": multiplier, "critical": critical}
				if hero.classId == "sombrio" and dealt > 0:
					var amount := _heal(actor, dealt * 0.25)
					if amount > 0:
						events.append({"type": "heal", "target": actor.id, "amount": amount, "passive": true})
						actor.stats.healing += amount
			if action_id != "basic" and target.hp > 0 and action.has("effect"):
				_status(target, action.effect)
			events.append(event)
			var entry := event.duplicate()
			entry.actor = actor.id
			_log(state, entry)
			if target.hp == 0:
				events.append({"type": "defeated", "target": target.id})
				_log(state, {"type": "defeated", "actor": actor.id, "target": target.id})
		if action_id == "basic": actor.energy = mini(100, actor.energy + 24)
	actor.statuses = actor.statuses.filter(func(s): return s.turns > 0)
	if not _victory(state):
		state.cursor += 1
		_begin_turn(state)
	return {"actor": actor.id, "heroId": actor.heroId, "actionId": action_id, "animation": hero.animation, "events": events}

func choose_ai(state: Dictionary) -> Dictionary:
	var actor := current(state)
	if actor.is_empty() or state.phase != "playing": return {}
	var hero: Dictionary = catalog.hero_by_id[actor.heroId]
	for id in ["ultimate", "skill", "basic"]:
		if not can_use(actor, id): continue
		var action := get_action(actor, id)
		var targets := legal_targets(state, actor, action)
		if action.kind.begins_with("heal"):
			var weakest: Dictionary = targets[0]
			for target in targets:
				if float(target.hp) / target.maxHp < float(weakest.hp) / weakest.maxHp:
					weakest = target
			if float(weakest.hp) / weakest.maxHp < 0.72:
				return {"actionId": id, "targetId": weakest.id}
			continue
		if action.kind.begins_with("shield"):
			for target in targets:
				if target.shield < target.maxHp * 0.12 and state.round > 1:
					return {"actionId": id, "targetId": target.id}
			continue
		# Stable tie-breaking matches the original roster order.
		var best: Dictionary = targets[0]
		var score: float = INF
		for target in targets:
			var candidate: float = (target.hp + target.shield) / advantage(hero.classId, catalog.hero_by_id[target.heroId].classId)
			if candidate < score:
				score = candidate
				best = target
		return {"actionId": id, "targetId": best.id}
	return {"actionId": "guard", "targetId": actor.id}
