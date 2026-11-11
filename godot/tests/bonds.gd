extends SceneTree
const Campaign = preload("res://scripts/campaign.gd")
const Combat = preload("res://scripts/combat.gd")
const PATH := "user://bonds-test.json"
var failures := 0
var checks := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _win(story: Campaign, engine: Combat, index: int) -> Dictionary:
	var state := story.battle(engine,index)
	while state.phase == "playing" and state.turns < 400:
		var choice := story.choose_ai(engine,state)
		if story.act(engine,state,choice.actionId,choice.targetId).has("error"): break
	return state

func _run() -> void:
	for suffix in ["",".tmp",".bak",".bak.tmp",".v8.bak"]: DirAccess.remove_absolute(PATH+suffix)
	var engine := Combat.new()
	var legacy := {"schemaVersion":8,"completed":{},"team":["veyra","axion","astra"],"equipped":{},"gear":{},"repeatWins":{},"gemCrafts":{},"gemFusions":{},"mastery":{},"abilityChoices":{}}
	var file := FileAccess.open(PATH,FileAccess.WRITE)
	var original := JSON.stringify(legacy)
	file.store_string(original)
	file.close()
	var story := Campaign.new(engine.catalog,PATH)
	check(story.bonds.is_empty(),"Schema eight never infers who fought alongside whom")
	for index in range(3):
		var victory := _win(story,engine,index)
		check(story.claim_victory(victory).get("saved",false),"A real victory is saved")
		check(story.claim_victory(victory).has("error"),"A replayed receipt has no benefit")
	var next := story.battle(engine,story.next_mission())
	check(engine.unit(next,"0-veyra").energy == 44,"Three victories grant two opening energy for each linked ally")
	check(FileAccess.get_file_as_string(PATH+".v8.bak") == original,"The original schema eight save was preserved exactly")
	story = Campaign.new(engine.catalog,PATH)
	check(story.loadout_stats("veyra").energy == 44,"Reopening restores the earned links")
	check(story.set_team(["astra","veyra","elyra"]) and story.loadout_stats("veyra").energy == 42,"Reordering keeps the same link and replacing one partner removes only its bonus")
	var free := engine.new_battle(story.team,engine.catalog.default_teams[1])
	check(engine.unit(free,"0-veyra").energy == 40,"The bond never changes free combat")
	print("Bonds: %d checks, %d failures." % [checks,failures])
	quit(1 if failures else 0)
