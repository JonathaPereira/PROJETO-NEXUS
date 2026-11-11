extends SceneTree
const Combat = preload("res://scripts/combat.gd")
const Campaign = preload("res://scripts/campaign.gd")
const Main = preload("res://scenes/main.tscn")
const BOSS := "1-boss-forge"
const STRIKER := "0-veyra"
var engine := Combat.new()
var failures := 0
var checks := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _schedule(state: Dictionary, next: String, current: String = STRIKER) -> void:
	for id in [next,current]:
		state.order.erase(id)
		state.order.push_front(id)
	state.cursor = 0

func _battle(story: Campaign) -> Dictionary:
	var state := story.battle(engine,story.mission_index("forge-heart"))
	_schedule(state,"0-astra")
	return state

func _run() -> void:
	var story := Campaign.new(engine.catalog,"user://boss-test.json")
	for id in Campaign.LEGACY_ORDER.slice(0,8): story.completed[id] = Campaign.LEGACY_REWARDS[id]
	var state := _battle(story)
	var boss := engine.unit(state,BOSS)
	var original_skill := engine.get_action(boss,"skill").duplicate(true)
	check(original_skill.name == "Coração de ferro", "The Arconte opens with its defensive technique")
	boss.shield = 25
	boss.shieldTurns = 2
	boss.cooldowns.skill = 1
	boss.statuses = [{"type":"mirror","turns":2}]
	var normal: Dictionary = engine.preview(state,"basic",BOSS).normal
	var damage: int = boss.hp-engine.unit({"units":normal.impactUnits},BOSS).hp
	check(damage > 0,"The controlled hit damages the Arconte")
	boss.hp = 876+damage
	story.act(engine,state,"basic",BOSS,false)
	check(boss.hp == 876 and engine.get_action(boss,"skill") == original_skill,"Just above half life the defensive pattern still applies")
	state = _battle(story)
	boss = engine.unit(state,BOSS)
	boss.shield = 25
	boss.shieldTurns = 2
	boss.cooldowns.skill = 1
	boss.statuses = [{"type":"mirror","turns":2}]
	boss.hp = 875+damage
	var result := story.act(engine,state,"basic",BOSS,false)
	var impact := engine.unit({"units":result.impactUnits},BOSS)
	check(impact.hp == 875 and boss.hp == 875,"The threshold hit lands without retroactive damage or a health reset")
	check(engine.get_action(boss,"skill").name == "Erupção do núcleo","A living Arconte at exactly half life changes to its offensive technique")
	check(boss.energy == 64 and boss.cooldowns.skill == 1 and boss.statuses == impact.statuses and boss.shield == impact.shield,"Transition preserves energy, cooldown, shield and the remaining effects of the first phase")
	check(not engine.can_use(boss,"skill"),"Erupção respects the existing technique cooldown")
	boss.hp = 1000
	boss.cooldowns.skill = 0
	_schedule(state,"0-astra",BOSS)
	var eruption := story.act(engine,state,"skill",STRIKER,false)
	var victims: Array = eruption.get("events",[]).filter(func(event): return event.type == "damage" and event.target.begins_with("0-") and not event.get("reaction",false))
	check(victims.size() == 3 and boss.energy == 34 and boss.cooldowns.skill == 3,"The new technique spends 30 energy and attacks the trio with the normal cooldown")
	boss.hp = 875
	story.act(engine,state,"guard","0-astra",false)
	check(engine.get_action(boss,"skill").name == "Erupção do núcleo" and state.log.filter(func(event):return event.get("text","").contains("Núcleo exposto")).size() == 1,"Healing and crossing again cannot undo or repeat the phase")
	check(engine.catalog.hero_by_id["boss-forge"].skill == original_skill and engine.catalog.hero_by_id.rhazen.skill == original_skill,"Phase changes stay in the encounter snapshot")

	state = _battle(story)
	boss = engine.unit(state,BOSS)
	boss.hp = 1
	story.act(engine,state,"basic",BOSS,false)
	check(boss.hp == 0 and engine.get_action(boss,"skill") == original_skill,"A lethal hit skips the transition without reviving the boss")
	state = _battle(story)
	boss = engine.unit(state,BOSS)
	boss.hp = 900
	boss.shield = 30
	boss.shieldTurns = 2
	boss.statuses = [{"type":"burn","turns":2}]
	_schedule(state,BOSS)
	story.act(engine,state,"guard",STRIKER,false)
	check(boss.hp < 875 and boss.shield == 30 and engine.current(state).id == BOSS and engine.get_action(boss,"skill").name == "Erupção do núcleo","A periodic hit changes the technique before the Arconte takes its turn")
	state = _battle(story)
	boss = engine.unit(state,BOSS)
	boss.hp = 876
	boss.statuses = [{"type":"mirror","turns":2}]
	for unit in state.units.filter(func(unit):return unit.side == 0): unit.hp = 1 if unit.id == STRIKER else 0
	story.act(engine,state,"basic",BOSS,false)
	check(state.winner == 1 and boss.hp < 875 and engine.get_action(boss,"skill") == original_skill,"Defeat by reflection takes precedence over a phase transition")
	check(engine.get_action(engine.unit(_battle(story),BOSS),"skill") == original_skill,"A new attempt starts in phase one")

	var definitions: Array = Campaign.MISSIONS.duplicate(true)
	var finale: Dictionary = definitions[story.mission_index("forge-heart")]
	finale.field = definitions[story.mission_index("tidal-heart")].field
	finale.waves = definitions[story.mission_index("tidal-gate")].waves
	var combined := Campaign.new(engine.catalog,"user://boss-combined.json",definitions)
	combined.completed = story.completed.duplicate()
	combined.mastery = {"veyra":60}
	combined.ability_choices = {"veyra":{"basic":"rhythm"}}
	state = _battle(combined)
	boss = engine.unit(state,BOSS)
	boss.hp = 2
	combined.act(engine,state,"guard",STRIKER,false)
	check(engine.get_action(boss,"skill").name == original_skill.name,"Only the final wave carries the boss phase")
	for unit in state.units.filter(func(unit):return unit.side == 1): unit.hp = 1
	_schedule(state,STRIKER,"0-astra")
	engine.current(state).energy = 100
	combined.act(engine,state,"ultimate",BOSS,false)
	check(state.phase == "playing" and engine.get_action(boss,"skill").name == original_skill.name,"Reinforcements keep the boss's original technique at full health")
	boss.hp = int(boss.maxHp/2.0)
	_schedule(state,"0-astra")
	combined.act(engine,state,"guard",STRIKER,false)
	check(engine.get_action(boss,"skill").name == "Erupção do núcleo" and engine.get_action(boss,"skill").cost == 35 and engine.get_action(engine.unit(state,STRIKER),"basic").energyGain == 32,"The final phase keeps the field cost and the allied training")
	finale.bossPhase = {"target":STRIKER,"name":"Invalid","skillName":"Invalid","healthRatio":0.5,"skillPower":0.8}
	var invalid := Campaign.new(engine.catalog,"user://boss-invalid.json",definitions)
	invalid.completed = story.completed.duplicate()
	check(invalid.battle(engine,invalid.mission_index("forge-heart")).has("error"),"An encounter that points its phase at a player cannot start")

	var app = Main.instantiate()
	root.add_child(app)
	await process_frame
	for id in Campaign.LEGACY_ORDER.slice(0,8): app.campaign.completed[id] = Campaign.LEGACY_REWARDS[id]
	app.hub.open("story")
	app.hub.chapter_buttons[2].pressed.emit()
	check(app.hub.body.find_children("*","Label",true,false).any(func(label):return label.text.contains("50%") and label.text.contains("Erupção do núcleo")),"The actual preparation explains the threshold and the new technique")
	app.hub.mission_slots[app.campaign.mission_index("forge-heart")].pressed.emit()
	app.hub.preparation_button.pressed.emit()
	check(app.objective_label.text.contains("Fase 1/2"),"The combat HUD shows the opening phase")
	_schedule(app.state,"0-astra")
	app.combat.unit(app.state,BOSS).hp = 876
	app._set_reduced(true)
	app.start_button.pressed.emit()
	await app._play_turn("basic",BOSS)
	check(app.objective_label.text.contains("Fase 2/2") and app.log_view.text.contains("Erupção do núcleo"),"The live HUD and battle log announce the new phase")
	for enemy in app.state.units.filter(func(unit):return unit.side == 1): enemy.hp = 1
	_schedule(app.state,STRIKER,"0-astra")
	app.combat.current(app.state).energy = 100
	await app._play_turn("ultimate",BOSS)
	check(app.result_dialog.dialog_text.contains("Núcleo exposto") and app.campaign.is_complete(app.campaign.mission_index("forge-heart")),"The result records the reached phase and awards the real victory")
	app._leave_battle()
	await create_timer(.6).timeout
	app.queue_free()
	await process_frame
	print("Boss phases: %d checks, %d failures." % [checks,failures])
	quit(1 if failures else 0)
