extends RefCounted
const RulesText=preload("res://scripts/rules_text.gd")
## Changes only the living boss's next technique, at a campaign checkpoint.

static func attach(state: Dictionary, mission: Dictionary) -> String:
	if not mission.has("bossPhase"): return ""
	var phase: Variant = mission.bossPhase
	if not _valid(phase): return "Fase de chefe inválida."
	var target: Variant = phase.get("target")
	if not state.units.any(func(unit):
		return unit.id == target and unit.side == 1 and unit.heroId.begins_with("boss-")):
		return "Chefe da missão ausente."
	state.campaignBossPhase = phase.duplicate(true)
	state.campaignBossPhase.reached = false
	return ""

static func _valid(phase: Variant) -> bool:
	if not phase is Dictionary: return false
	if phase.keys().any(func(key):return key not in ["target","name","skillName","healthRatio","skillPower","skillEffect","skillPierce"]):return false
	for key in ["target","name","skillName"]:
		if not phase.get(key) is String or phase[key].strip_edges().is_empty(): return false
	if phase.has("skillPierce") and not _between(phase.skillPierce,0.0,0.5):return false
	if phase.has("skillEffect") and phase.skillEffect not in ["burn","bleed","expose","weaken"]:return false
	return _between(phase.get("healthRatio"),0.1,0.9) and _between(phase.get("skillPower"),0.1,1.5)

static func brief(mission: Dictionary) -> String:
	var phase: Variant = mission.get("bossPhase")
	if not _valid(phase): return ""
	var condition := "Na última onda, com" if mission.has("waves") else "Com"
	return "%s %d%% de vida ou menos, o chefe troca sua técnica por %s (ataque em área)." % [condition,roundi(phase.healthRatio * 100),phase.skillName]+_pressure(phase)

static func _pressure(phase: Dictionary) -> String:
	var detail:=""
	if phase.has("skillEffect"):
		detail+=" %s por %d turnos. Purificação remove esse efeito."%[RulesText.status_names()[phase.skillEffect],int(RulesText.rules.status.durationTurns)]
	if phase.get("skillPierce",0)>0:
		detail+=" %s do dano atravessa escudos; o restante ainda pode ser absorvido. Defesa reduz o dano total."%RulesText.percent(phase.skillPierce)
	return detail

static func label(state: Dictionary) -> String:
	var phase: Dictionary = state.get("campaignBossPhase",{})
	if phase.is_empty(): return ""
	if not phase.reached:return "Fase 1/2"
	var text:="Fase 2/2 · %s"%phase.name
	if phase.has("skillEffect"):text+=" · "+RulesText.status_names()[phase.skillEffect]
	if phase.get("skillPierce",0)>0:text+=" · atravessa escudo: "+RulesText.percent(phase.skillPierce)
	return text

static func _between(value: Variant, minimum: float, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= minimum and value <= maximum

static func resolve(engine, state: Dictionary) -> void:
	var phase: Dictionary = state.get("campaignBossPhase",{})
	if phase.is_empty() or phase.reached: return
	var boss: Dictionary = engine.unit(state,phase.target)
	if boss.hp <= 0 or boss.hp > boss.maxHp * phase.healthRatio: return
	var previous: Dictionary = engine.get_action(boss,"skill")
	var skill := {
		"id":"skill", "name":phase.skillName, "kind":"aoe", "power":phase.skillPower,
		"cost":previous.cost, "cooldown":previous.cooldown,
		"description":"%d%% do ataque contra todos os adversários. Custa %d EN." % [roundi(phase.skillPower * 100),previous.cost],
	}
	if phase.has("skillEffect"):
		skill.effect=phase.skillEffect
	if phase.has("skillPierce"):skill.pierce=phase.skillPierce
	skill.description+=_pressure(phase)
	if previous.has("fieldLabel"): skill.fieldLabel = previous.fieldLabel
	var overrides: Dictionary = boss.get("campaignActions",{})
	overrides.skill = skill
	boss.campaignActions = overrides
	phase.reached = true
	state.log.append({"type":"objective","round":state.round,"text":"Fase 2 · %s: %s substitui a técnica anterior." % [phase.name,skill.name]+_pressure(phase)})
	if state.log.size() > 100: state.log.pop_front()
