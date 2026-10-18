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
				"energy": 40, "shield": 0, "shieldTurns": 0, "guarding": false, "statuses": [], "cooldowns": {},
				"stats": {"damage": 0, "healing": 0, "actions": 0, "shieldDamage": 0, "shieldGranted": 0, "protected": 0, "energyGiven": 0, "combos": 0, "shieldAbsorbed": 0},
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

const POSITIVE = ["regen", "empower", "fortify", "cover", "mirror", "riposte", "taunt", "emberguard"]

func friendly(action: Dictionary) -> bool:
	return action.kind.begins_with("heal") or action.kind.begins_with("shield") or action.kind.begins_with("support")

func legal_targets(state: Dictionary, actor: Dictionary, action: Dictionary) -> Array:
	if action.kind == "guard" or action.get("self", false): return [actor]
	var targets: Array = state.units.filter(func(u): return u.hp > 0 and u.side == (actor.side if friendly(action) else 1 - actor.side))
	if action.kind == "damage":
		var taunting: Array = targets.filter(func(u): return has_status(u, "taunt"))
		if not taunting.is_empty(): targets = taunting
	return targets

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

func healing_multiplier(state: Dictionary, target: Dictionary) -> float:
	var fracture := maxf(0.0, 1.0 - maxi(0, state.round - 11) * 0.1)
	return fracture * (0.65 if has_status(target, "bleed") else 1.0)

func _heal(state: Dictionary, target: Dictionary, amount: float, metadata: Dictionary = {}) -> Dictionary:
	var multiplier := healing_multiplier(state, target)
	var healed: int = mini(target.maxHp - target.hp, rounded(amount * multiplier)) if target.hp > 0 else 0
	target.hp += healed
	var receipt := {"type": "heal", "target": target.id, "amount": healed, "healingPenalty": rounded((1 - multiplier) * 100)}
	receipt.merge(metadata, true)
	return receipt

func has_status(target: Dictionary, type: String) -> bool:
	return target.statuses.any(func(s): return s.type == type)

func _remove(target: Dictionary, type: String) -> void:
	target.statuses = target.statuses.filter(func(s): return s.type != type)

func _status(target: Dictionary, type: String, owner: Variant = null) -> void:
	if type == "cleanse":
		target.statuses = target.statuses.filter(func(s): return s.type in POSITIVE)
		return
	for status in target.statuses:
		if status.type == type:
			status.turns = 2
			if type == "cover": status.owner = owner
			return
	var status := {"type": type, "turns": 2}
	if type == "cover": status.owner = owner
	target.statuses.append(status)

func _turn_event(state: Dictionary, events: Array, actor: Dictionary, event: Dictionary) -> void:
	event.hpAfter = actor.hp
	event.shieldAfter = actor.shield
	_log(state, event)
	events.append(event)

func _begin_turn(state: Dictionary, turn_events: Array = []) -> void:
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
		if actor.shield > 0 and actor.shieldTurns > 0: actor.shieldTurns -= 1
		for id in actor.cooldowns:
			actor.cooldowns[id] = maxi(0, actor.cooldowns[id] - 1)
		if state.round >= 12:
			var amount: int = mini(actor.hp, int(ceil(actor.maxHp * minf(0.85, 0.04 + (state.round - 12) * 0.025))))
			actor.hp -= amount
			_turn_event(state, turn_events, actor, {"type": "fracture", "actor": actor.id, "target": actor.id, "amount": amount, "healingPenalty": mini(100, (state.round - 11) * 10)})
			if actor.hp <= 0: _turn_event(state, turn_events, actor, {"type": "defeated", "actor": actor.id, "target": actor.id})
		for status in actor.statuses:
			if actor.hp <= 0: break
			if status.turns <= 0: continue
			if status.type in ["burn", "bleed"]:
				var amount: int = mini(actor.hp, rounded(actor.maxHp * 0.065))
				actor.hp -= amount
				_turn_event(state, turn_events, actor, {"type": status.type, "actor": actor.id, "target": actor.id, "amount": amount, "remaining": status.turns - 1})
				if actor.hp <= 0:
					_turn_event(state, turn_events, actor, {"type": "defeated", "actor": actor.id, "target": actor.id})
					break
			if status.type == "regen":
				var receipt := _heal(state, actor, actor.maxHp * 0.04, {"actor": actor.id, "passive": true, "remaining": status.turns - 1})
				_turn_event(state, turn_events, actor, receipt)
			status.turns -= 1
		actor.statuses = actor.statuses.filter(func(s): return s.turns > 0 or (s.turns == 0 and not s.type in ["burn", "bleed", "regen"]))
		if _victory(state): return
		if actor.hp <= 0:
			state.cursor += 1
			continue
		return

const SHIELD_CAP := 0.25

func _shield(target: Dictionary, power: float) -> Dictionary:
	var before: int = target.shield
	var grant: int = mini(rounded(target.maxHp * SHIELD_CAP), rounded(target.maxHp * power))
	var remaining: int = 0 if target.shieldTurns == 0 else before
	if grant >= remaining: target.shieldTurns = 2
	target.shield = maxi(remaining, grant)
	return {"type": "shield", "target": target.id, "amount": target.shield - remaining, "shieldBefore": before, "shieldAfter": target.shield, "shieldTurns": target.shieldTurns}

func _hit(target: Dictionary, total: int, pierce: float = 0.0, metadata: Dictionary = {}) -> Dictionary:
	var before: int = target.shield
	var absorbed: int = mini(before, total - rounded(total * pierce))
	target.shield -= absorbed
	if target.shield == 0: target.shieldTurns = 0
	target.stats.shieldAbsorbed += absorbed
	var amount: int = mini(target.hp, total - absorbed)
	target.hp -= amount
	var event := {"type": "damage", "target": target.id, "amount": amount, "absorbed": absorbed, "advantage": 1, "critical": false, "total": total, "shieldBefore": before, "shieldAfter": target.shield, "hpAfter": target.hp}
	event.merge(metadata, true)
	return event

func _emit(state: Dictionary, events: Array, actor: Dictionary, event: Dictionary) -> void:
	events.append(event)
	var entry := event.duplicate(true)
	entry.actor = actor.id
	_log(state, entry)

func act(state: Dictionary, action_id: String, target_id: String, critical_override: Variant = null) -> Dictionary:
	if state.phase != "playing": return {"error": "A batalha terminou."}
	var actor := current(state)
	if not can_use(actor, action_id): return {"error": "Ação indisponível: energia ou recarga."}
	var action := get_action(actor, action_id)
	var targets := legal_targets(state, actor, action)
	var selected: Dictionary = {}
	for candidate in targets:
		if candidate.id == target_id: selected = candidate
	if selected.is_empty(): return {"error": "Escolha um alvo válido."}
	var hero: Dictionary = catalog.hero_by_id[actor.heroId]
	var events: Array = []
	actor.energy -= action.cost
	actor.stats.actions += 1
	state.turns += 1
	if action.cooldown > 0: actor.cooldowns[action_id] = action.cooldown + 1
	_log(state, {"type": "action", "actor": actor.id, "name": action.name, "actionId": action_id})
	var recipients: Array = targets if action.kind in ["aoe", "healAll", "shieldAll", "supportAll"] else [selected]
	var extra: Dictionary = action.get("secondary", {})
	var boosted_secondary: bool = extra.has("whenStatus") and recipients.any(func(t): return has_status(t, extra.whenStatus))
	var stored_shield: int = actor.shield if action.has("shieldScale") else 0
	if stored_shield > 0:
		actor.shield = 0
		actor.shieldTurns = 0
		_emit(state, events, actor, {"type": "converted", "target": actor.id, "shieldSpent": stored_shield})
	if action.kind == "guard":
		actor.guarding = true
		var event := _shield(actor, 0.06)
		event.type = "guard"
		_emit(state, events, actor, event)
		actor.stats.shieldGranted += event.amount
		actor.energy = mini(100, actor.energy + 25)
	else:
		for target in recipients:
			var event: Dictionary
			if action.kind.begins_with("heal"):
				event = _heal(state, target, target.maxHp * action.power)
				actor.stats.healing += event.amount
			elif action.kind.begins_with("shield"):
				event = _shield(target, action.power)
				actor.stats.shieldGranted += event.amount
			elif action.kind.begins_with("support"):
				event = {"type": "support", "target": target.id, "amount": 0}
			else:
				var weak := 0.8 if has_status(actor, "weaken") else 1.0
				var empowered := 1.2 if has_status(actor, "empower") else 1.0
				var defense: float = target.defense * (0.75 if has_status(target, "expose") else 1.0) * (0.75 if hero.classId == "arcano" else 1.0)
				var multiplier := advantage(hero.classId, catalog.hero_by_id[target.heroId].classId)
				var critical := _random(state) < 0.1
				if critical_override != null: critical = bool(critical_override)
				var bonus := 1.0
				var combo := ""
				if action.has("combo") and has_status(target, action.combo.status):
					bonus *= action.combo.multiplier
					combo = action.combo.status
					actor.stats.combos += 1
					if action.combo.consume: _remove(target, action.combo.status)
				if has_status(target, "focus"):
					bonus *= 1.25
					_remove(target, "focus")
					if combo.is_empty(): combo = "focus"
					actor.stats.combos += 1
				if action.has("executeThreshold") and float(target.hp) / target.maxHp < action.executeThreshold:
					bonus *= action.executeMultiplier
					if combo.is_empty(): combo = "execute"
					actor.stats.combos += 1
				var total: int = maxi(1, rounded((actor.attack * weak * empowered * action.power + stored_shield * action.get("shieldScale", 0)) * 100.0 / (100 + defense * 0.5) * multiplier * (0.65 if target.guarding else 1.0) * (0.85 if has_status(target, "fortify") else 1.0) * bonus * (1.4 if critical else 1.0)))
				var protections: Array = target.statuses.filter(func(s): return s.type == "cover") if action.kind == "damage" else []
				var guardian: Dictionary = unit(state, protections[0].owner) if not protections.is_empty() else {}
				if not guardian.is_empty() and guardian.hp > 0 and guardian.side == target.side and guardian.id != target.id:
					var share := rounded(total * 0.25)
					total -= share
					var receipt := _hit(guardian, share, action.get("pierce", 0), {"intercepted": true})
					_emit(state, events, actor, receipt)
					guardian.stats.protected += receipt.amount
					actor.stats.damage += receipt.amount
					actor.stats.shieldDamage += receipt.absorbed
					if guardian.hp == 0: _emit(state, events, actor, {"type": "defeated", "target": guardian.id})
				event = _hit(target, total, action.get("pierce", 0), {"advantage": multiplier, "critical": critical})
				if not combo.is_empty(): event.combo = combo
				actor.stats.damage += event.amount
				actor.stats.shieldDamage += event.absorbed
				if has_status(target, "seed") and actor.hp > 0:
					_remove(target, "seed")
					var receipt := _heal(state, actor, actor.maxHp * 0.1, {"passive": true, "source": "seed"})
					_emit(state, events, actor, receipt)
					actor.stats.healing += receipt.amount
				if hero.classId == "sombrio" and event.amount > 0 and actor.hp > 0:
					var receipt := _heal(state, actor, event.amount * 0.15, {"passive": true, "source": "drain"})
					if receipt.amount > 0:
						_emit(state, events, actor, receipt)
						actor.stats.healing += receipt.amount
				if target.hp > 0 and actor.hp > 0:
					var retaliation: int = (rounded(event.amount * 0.2) if has_status(target, "mirror") else 0) + (rounded(target.attack * 0.4) if has_status(target, "riposte") else 0)
					if retaliation > 0:
						var receipt := _hit(actor, retaliation, 0, {"reaction": true})
						_emit(state, events, actor, receipt)
						target.stats.damage += receipt.amount
						target.stats.shieldDamage += receipt.absorbed
						if actor.hp == 0: _emit(state, events, actor, {"type": "defeated", "target": actor.id})
					if has_status(target, "emberguard") and actor.hp > 0:
						_status(actor, "burn")
						_emit(state, events, actor, {"type": "status", "target": actor.id, "effect": "burn", "effectTurns": 2, "source": "emberguard"})
			if target.hp > 0:
				for effect in [action.get("effect", ""), action.get("extraEffect", "")]:
					if effect.is_empty(): continue
					if not event.has("effect"):
						event.effect = effect
						event.effectTurns = 0 if effect == "cleanse" else 2
					else: event.extraEffect = effect
					if effect == "cleanse": event.cleansed = target.statuses.filter(func(s): return not s.type in POSITIVE).map(func(s): return s.type)
					_status(target, effect, actor.id)
			_emit(state, events, actor, event)
			if target.hp == 0: _emit(state, events, actor, {"type": "defeated", "target": target.id})
		if not extra.is_empty() and actor.hp > 0:
			var allies: Array = state.units.filter(func(u): return u.side == actor.side and u.hp > 0)
			var destinations: Array = [selected]
			match extra.target:
				"allies": destinations = allies
				"actor": destinations = [actor]
				"lowestAlly":
					var weakest: Dictionary = allies[0]
					for candidate in allies:
						if float(candidate.hp) / candidate.maxHp < float(weakest.hp) / weakest.maxHp: weakest = candidate
					destinations = [weakest]
			for target in destinations:
				if target.hp <= 0: continue
				var power: float = extra.get("power", 0) * (extra.multiplier if boosted_secondary else 1.0)
				match extra.kind:
					"heal":
						var receipt := _heal(state, target, target.maxHp * power, {"source": "secondary"})
						actor.stats.healing += receipt.amount
						_emit(state, events, actor, receipt)
					"shield":
						var receipt := _shield(target, power)
						actor.stats.shieldGranted += receipt.amount
						_emit(state, events, actor, receipt)
					"energy":
						var amount: int = mini(100 - target.energy, extra.amount)
						target.energy += amount
						actor.stats.energyGiven += amount
						_emit(state, events, actor, {"type": "energy", "target": target.id, "amount": amount, "energyAfter": target.energy})
		if action_id == "basic": actor.energy = mini(100, actor.energy + 24)
	if actor.shield > 0 and actor.shieldTurns == 0:
		var expired: int = actor.shield
		actor.shield = 0
		_emit(state, events, actor, {"type": "shieldExpired", "target": actor.id, "amount": expired, "shieldAfter": 0})
	actor.statuses = actor.statuses.filter(func(s): return s.turns > 0)
	var impact_units: Array = state.units.duplicate(true)
	var turn_events: Array = []
	if not _victory(state):
		state.cursor += 1
		_begin_turn(state, turn_events)
	return {"actor": actor.id, "heroId": actor.heroId, "actionId": action_id, "animation": hero.animation, "events": events, "impactUnits": impact_units, "turnEvents": turn_events}

func preview(state: Dictionary, action_id: String, target_id: String) -> Dictionary:
	return {"normal": act(state.duplicate(true), action_id, target_id, false), "critical": act(state.duplicate(true), action_id, target_id, true)}

func choose_ai(state: Dictionary) -> Dictionary:
	var actor := current(state)
	if actor.is_empty() or state.phase != "playing": return {}
	var hero: Dictionary = catalog.hero_by_id[actor.heroId]
	for id in ["ultimate", "skill", "basic"]:
		if not can_use(actor, id): continue
		var action := get_action(actor, id)
		var targets := legal_targets(state, actor, action)
		if friendly(action):
			var target: Dictionary = targets[0]
			if action.kind.begins_with("heal"):
				for candidate in targets:
					if float(candidate.hp) / candidate.maxHp < float(target.hp) / target.maxHp: target = candidate
				var cleansing: bool = action.get("effect") == "cleanse" and targets.any(func(t): return t.statuses.any(func(s): return not s.type in POSITIVE))
				if (float(target.hp) / target.maxHp >= 0.78 or healing_multiplier(state, target) == 0) and not cleansing: continue
			elif action.kind.begins_with("shield"):
				target = {}
				for candidate in targets:
					if candidate.shield < candidate.maxHp * 0.14 or (action.has("effect") and not has_status(candidate, action.effect)):
						target = candidate
						break
				if target.is_empty(): continue
			else:
				for candidate in targets:
					if candidate.energy < target.energy: target = candidate
				if target.energy > 75 and not targets.any(func(t): return t.statuses.any(func(s): return not s.type in POSITIVE)): continue
			return {"actionId": id, "targetId": target.id}
		var best: Dictionary = targets[0]
		var best_score := INF
		for target in targets:
			var combo: float = action.combo.multiplier if action.has("combo") and has_status(target, action.combo.status) else 1.0
			var score: float = (target.hp + target.shield) / (advantage(hero.classId, catalog.hero_by_id[target.heroId].classId) * combo)
			if score < best_score:
				best_score = score
				best = target
		return {"actionId": id, "targetId": best.id}
	return {"actionId": "guard", "targetId": actor.id}
