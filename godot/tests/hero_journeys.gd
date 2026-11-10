extends SceneTree
const Campaign = preload("res://scripts/campaign.gd")
const Combat = preload("res://scripts/combat.gd")
const PATH := "user://hero-journey-test.json"
var checks := 0
var failures := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	for suffix in ["",".tmp",".bak",".bak.tmp"]: DirAccess.remove_absolute(PATH+suffix)
	var engine := Combat.new()
	var story := Campaign.new(engine.catalog,PATH)
	var missing: Array = engine.catalog.heroes.filter(func(hero):return story.mission_index("journey-"+hero.id) < 0)
	check(missing.is_empty(),"All 24 heroes have a playable individual journey")
	if missing.is_empty():
		var index := story.mission_index("journey-veyra")
		check(not story.can_play(index),"A personal chapter opens after the original prologue")
		for id in ["gate","court","eclipse"]: story.completed[id] = Campaign.LEGACY_REWARDS[id]
		var before := story.loadout_stats("veyra")
		check(story.can_play(index) and story.next_mission() == story.mission_index("tidal-gate"),"A personal journey is available without blocking the main campaign")
		var state := story.battle(engine,index)
		while state.phase == "playing" and state.turns < 400:
			var choice := story.choose_ai(engine,state)
			if story.act(engine,state,choice.actionId,choice.targetId).has("error"): break
		var starting_team: Array = story.team.duplicate()
		check(story.set_team(["axion","astra","elyra"]) and not story.can_play(index),"A journey cannot start with a different protagonist")
		var victory := story.claim_victory(state)
		check(state.winner == 0 and victory.get("saved",false) and victory.has("gem"),"A legal victory uses the starting trio even if the roster changed")
		check(story.set_team(starting_team),"The starting trio can be restored before reopening")
		story = Campaign.new(engine.catalog,PATH)
		check(story.is_complete(index) and story.loadout_stats("veyra").attack > before.attack,"The personal pact persists and has a real effect in the campaign")
		for hero in engine.catalog.heroes:
			var mission := story.journey_index(hero.id)
			if story.is_complete(mission): continue
			var team: Array = [hero.id]
			team.append_array(["axion","veyra","astra"].filter(func(id):return id != hero.id).slice(0,2))
			check(story.set_team(team) and story.can_play(mission),"Any two partners can accompany "+hero.name)
			state = story.battle(engine,mission)
			while state.phase == "playing" and state.turns < 400:
				var choice := story.choose_ai(engine,state)
				if story.act(engine,state,choice.actionId,choice.targetId).has("error"): break
			check(state.winner == 0 and story.claim_victory(state).get("saved",false),"The individual encounter is winnable and persists: "+hero.name+" "+str(state.get("missionResult")))
		check(story.cleared == 27 and story.main_cleared == 3 and story.next_mission() == story.mission_index("tidal-gate"),"All 24 individual victories preserve the main route")
	print("Hero journeys: %d checks, %d failures." % [checks,failures])
	quit(1 if failures else 0)
