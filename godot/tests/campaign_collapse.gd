extends SceneTree
const Combat = preload("res://scripts/combat.gd")
const Campaign = preload("res://scripts/campaign.gd")
const Main = preload("res://scenes/main.tscn")
const PATH := "user://collapse-test.json"
const FRESH_PATH := "user://collapse-fresh-test.json"
const FIRST := "collapse-warning"
const FINALE := "collapse-anchor"
var checks := 0
var failures := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	for path in [PATH,FRESH_PATH]:
		for suffix in ["", ".tmp", ".bak", ".bak.tmp"]: DirAccess.remove_absolute(path+suffix)
	var engine := Combat.new()
	var story := Campaign.new(engine.catalog,PATH)
	var first := story.mission_index(FIRST)
	check(Campaign.CHAPTERS.size() >= 4 and first >= 0 and story.chapter_missions(3).size() == 8,"The restored Farol leads to eight playable missions in O Colapso")
	if first >= 0:
		check(not story.can_play(first),"O Colapso opens only after restoring the Farol")
		story.completed = Campaign.LEGACY_REWARDS.duplicate()
		check(story.save_progress(),"A schema-eight journey with all nine original victories can be opened")
		story = Campaign.new(engine.catalog,PATH)
		check(story.cleared == 9 and story.completed == Campaign.LEGACY_REWARDS and story.can_play(first) and story.next_mission() == first,"A completed legacy journey continues without retroactive rewards")
		check(story.missions[story.chapter_final(3)].id == FINALE,"Chapter IV has a canonical finale")
		var original := Campaign.new(engine.catalog,PATH,Campaign.MISSIONS.slice(0,9))
		check(original.next_mission() == original.mission_index("forge-heart"),"An original-only definition list can still revisit its canonical finale")
		var app = Main.instantiate()
		root.add_child(app)
		await process_frame
		app.campaign = story
		app.hub.story_button.pressed.emit()
		check(app.hub.selected_chapter == 3 and app.hub.mission_buttons.size() == 8 and app.hub.next_mission_button.text.contains("A carta de amanhã"),"The real menu opens O Colapso and names the next mission")
		check(app.hub.mission_buttons.filter(func(button):return not button.disabled).size() == 1,"The preparation map keeps the next seven encounters locked")
		app.hub.next_mission_button.pressed.emit()
		app.hub.preparation_button.pressed.emit()
		check(app.state.campaignMissionId == FIRST and app.backdrop.environment == "sanctum","Continue launches the new mission in the chapter's environment")
		app._leave_battle()
		app.queue_free()
		await process_frame
		story = Campaign.new(engine.catalog,FRESH_PATH,Campaign.MISSIONS.slice(0,17))
		for index in range(story.missions.size()):
			var mission: Dictionary = story.missions[index]
			check(story.next_mission() == index and story.can_play(index),"A victory opens the next encounter: "+mission.id)
			var state := story.battle(engine,index)
			check(not state.has("error"),"Chapter encounter starts: "+mission.id)
			if state.has("error"): break
			while state.phase == "playing" and state.turns < 400:
				var action := story.choose_ai(engine,state)
				if story.act(engine,state,action.actionId,action.targetId).has("error"): break
			check(state.phase == "finished" and state.winner == 0,"The default trio wins using legal commands: "+mission.id+" / "+str(state.get("missionResult")))
			if state.winner != 0: break
			var initial_copies := story.copies(mission.reward)
			var receipt := story.claim_victory(state)
			check(receipt.get("saved",false) and receipt.get("first",false) and receipt.get("materials") == (12 if mission.id in ["eclipse","tidal-heart","forge-heart",FINALE] else 6),"The real victory persists its first-clear reward: "+mission.id)
			check(story.copies(mission.reward) == initial_copies + 1 and story.claim_victory(state).has("error"),"The same attempt cannot award a second gem: "+mission.id)
			if mission.id == FINALE:
				check(state.log.any(func(event):return event.get("text","").contains("Estilhaço prismático")),"The chapter boss demonstrates its offensive phase in a full battle")
		story = Campaign.new(engine.catalog,FRESH_PATH,Campaign.MISSIONS.slice(0,17))
		check(story.cleared == 17 and story.copies("ember") == 9 and story.copies("sap") == 8 and story.copies("pulse") == 9 and story.next_mission() == story.chapter_final(3),"Reopening preserves 17 victories and every earned gem")
	print("O Colapso: %d checks, %d failures." % [checks,failures])
	quit(1 if failures else 0)
