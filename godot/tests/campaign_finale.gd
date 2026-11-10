extends SceneTree
const Campaign = preload("res://scripts/campaign.gd")
const Combat = preload("res://scripts/combat.gd")
const PATH := "user://campaign-finale-test.json"
var failures := 0
var checks := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp"]: DirAccess.remove_absolute(PATH+suffix)
	var engine := Combat.new()
	var story := Campaign.new(engine.catalog,PATH)
	check(Campaign.CHAPTERS.size() == 6,"The map reaches As Seis Verdades and Nexus")
	if Campaign.CHAPTERS.size() == 6:
		check(range(6).all(func(chapter): return story.chapter_missions(chapter).size() == 8),"All six chapters each have eight playable main missions")
		check(story.next_mission() == story.mission_index("gate"),"A fresh player still opens the original gate first")
		check(not story.can_play(story.mission_index("truths-courier")) and not story.can_play(story.mission_index("nexus-heart")),"The final chapters require earlier story victories")
		var side := story.mission_index("side-beacon-shelter")
		check(side >= 0,"The opening chapter has a real secondary encounter")
		var route: Array = []
		while route.size() < 48:
			var index := story.next_mission()
			if index < 0 or story.is_complete(index): break
			var mission: Dictionary = story.missions[index]
			var state := story.battle(engine,index)
			check(not state.has("error"),"The next mission starts: "+mission.id)
			if state.has("error"): break
			while state.phase == "playing" and state.turns < 400:
				var choice := story.choose_ai(engine,state)
				if story.act(engine,state,choice.actionId,choice.targetId).has("error"): break
			check(state.phase == "finished" and state.winner == 0,"The default trio can win without mandatory equipment: "+mission.id+" "+str(state.get("missionResult")))
			if state.winner != 0: break
			var award := story.claim_victory(state)
			check(award.get("saved",false) and award.get("first",false) and story.claim_victory(state).has("error"),"The first victory is saved once: "+mission.id)
			route.append(mission.id)
			if mission.id == "gate" and side >= 0:
				check(story.can_play(side) and story.next_mission() == story.mission_index("court"),"Available secondary encounters do not interrupt the main route")
			if mission.id in ["truths-archive","nexus-heart"]:
				check(state.campaignBossPhase.reached and award.materials == 12,"The chapter finale demonstrates its boss phase and pays its chapter bonus")
		check(route.size() == 48 and route.back() == "nexus-heart","The full story reaches the final battle and real conclusion")
		var unopened := Campaign.new(engine.catalog,"")
		var reopened := Campaign.new(engine.catalog,PATH)
		check(reopened.cleared == 48 and reopened.next_mission() == reopened.mission_index("nexus-heart"),"The completed journey reopens on its finale")
		for chapter in range(3):
			var optional: Array = reopened.chapter_missions(chapter,"side")
			check(optional.size() == 1,"The chapter offers a distinct secondary")
			var state := reopened.battle(engine,optional[0])
			while state.phase == "playing" and state.turns < 400:
				var choice := reopened.choose_ai(engine,state)
				if reopened.act(engine,state,choice.actionId,choice.targetId).has("error"): break
			check(state.winner == 0 and reopened.claim_victory(state).get("saved",false),"The secondary has a real, saved victory")
		reopened = Campaign.new(engine.catalog,PATH)
		check(reopened.cleared == 51 and reopened.main_cleared == 48 and reopened.next_mission() == reopened.mission_index("nexus-heart"),"Secondary victories persist without changing the main route or its count")
		for chapter in range(3,6):
			var challenges: Array = reopened.chapter_missions(chapter,"challenge")
			check(challenges.size() == 1,"The final three chapters each have an optional challenge")
			if challenges.size() != 1: continue
			var index: int = challenges[0]
			var mission: Dictionary = reopened.missions[index]
			check(not unopened.can_play(index) and reopened.can_play(index),"The challenge requires its chapter finale")
			var state := reopened.battle(engine,index)
			while state.phase == "playing" and state.turns < 400:
				var choice := reopened.choose_ai(engine,state)
				if reopened.act(engine,state,choice.actionId,choice.targetId).has("error"): break
			check(state.winner == 0 and reopened.claim_victory(state).get("saved",false),"The optional challenge can be won and recorded: "+mission.id+" "+str(state.get("missionResult")))
		reopened = Campaign.new(engine.catalog,PATH)
		check(reopened.cleared == 54 and reopened.main_cleared == 48,"Challenges survive reopening without changing the main campaign")
	print("Nexus finale: %d checks, %d failures." % [checks,failures])
	quit(1 if failures else 0)
