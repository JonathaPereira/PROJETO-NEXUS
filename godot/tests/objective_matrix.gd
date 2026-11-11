extends SceneTree
## Reproducible balance sample, not a claim about competitive win rates.
const Campaign = preload("res://scripts/campaign.gd")
const Combat = preload("res://scripts/combat.gd")
const TEAMS = [
	["axion","veyra","astra"],
	["rhazen","sylva","riven"],
	["oren","kira","saira"],
	["nima","riven","kira"],
]
const OFFSETS = [0,37,113]

func _initialize() -> void:
	var engine := Combat.new()
	var build := "basic"
	var gem_level := 0
	var mastery_points := 0
	var trained := false
	var include_lumi := false
	var mature_bonds := false
	var all_heroes := false
	var journeys := false
	var pacts := false
	var teams: Array = TEAMS.duplicate(true)
	for arg in OS.get_cmdline_user_args():
		if arg == "--lumi": include_lumi = true
		if arg == "--bonds": mature_bonds = true
		if arg == "--all-heroes": all_heroes = true
		if arg == "--journeys": journeys = true
		if arg == "--pacts":
			pacts = true
			journeys = true
		if arg in ["assault","channel"]: build = arg
		if arg in ["--gems=1","--gems=2","--gems=3"]: gem_level = int(arg.right(1))
		if arg == "--mastery=3": mastery_points = int(Campaign.Progression.settings.masteryThresholds[-1])
		if arg == "--training":
			trained = true
			mastery_points = int(Campaign.Progression.settings.masteryThresholds[-1])
	if include_lumi: teams.append_array([["auren","solen","elyra"],["auren","zaya","veyra"],["solen","saira","axion"]])
	if all_heroes:
		teams = [["veyra","rhazen","cindra"],["torv","oren","sylva"],["nima","axion","brin"],["kira","bast","vektor"],["astra","elun","saira"],["ivo","vesper","maura"],["noct","auren","elyra"],["riven","solen","zaya"]]
	var rows: Array = []
	var errors := 0
	for team in teams:
		for offset in OFFSETS:
			var story := Campaign.new(engine.catalog,"user://matrix-unused-progress.json")
			story.team = team.duplicate()
			story.completed = Campaign.LEGACY_REWARDS.duplicate()
			if journeys:
				for hero in team:
					var journey: Dictionary = story.missions[story.journey_index(hero)]
					story.completed[journey.id] = journey.reward
			if mature_bonds:
				for _victory in range(Campaign.Bonds.REQUIRED_VICTORIES): Campaign.Bonds.record(story.bonds,team)
			for hero in team:
				if mastery_points > 0: story.mastery[hero] = mastery_points
				if trained: story.ability_choices[hero] = {"basic":"rhythm","skill":"burst","ultimate":"economy"}
				if pacts:
					if not story.ability_choices.has(hero): story.ability_choices[hero] = {}
					story.ability_choices[hero].skill = "pact"
			if build != "basic":
				for hero in team:
					story.gear[hero] = [{"variant":"standard" if build == "assault" else "channel","tier":3},{"variant":"standard" if build == "assault" else "bastion","tier":3},{"variant":"standard" if build == "assault" else "anchor","tier":3}]
			if gem_level > 0:
				if gem_level > 1:
					story.repeat_wins = {"gate":2 if gem_level == 2 else 12}
					for type in Campaign.GemForge.BASE_IDS:
						story.gem_crafts[type] = 1 if gem_level == 2 else 8
						story.gem_fusions[type] = 3 if gem_level == 2 else 9
						if gem_level == 3: story.gem_fusions[type+":2"] = 3
				for hero in team: story.equipped[hero] = Campaign.GemForge.BASE_IDS.map(func(type):return Campaign.GemForge.key(type,gem_level))
				var inventory_error := Campaign.GemForge.validate(story.gem_crafts,story.gem_fusions,story.equipped,story.completed,Campaign.Equipment.earned(story.completed,story.repeat_wins)-Campaign.Equipment.spent(story.gear),engine.catalog.heroes.map(func(h):return h.id))
				if inventory_error != "":
					push_error(inventory_error)
					quit(1)
					return
			for index in range(story.missions.size()):
				var mission: Dictionary = story.missions[index]
				if mission.get("kind") == "journey": continue
				if mission.id in Campaign.LEGACY_ORDER and not mission.has("objective") and not mission.has("waves") and not mission.has("field") and not mission.has("bossPhase"): continue
				for required in mission.requires:
					if not story.completed.has(required):
						story.completed[required] = story.missions[story.mission_index(required)].reward
				mission.seed += offset
				var state: Dictionary = story.battle(engine,index)
				var personal_uses := 0
				while state.phase == "playing" and state.turns < 400:
					var choice: Dictionary = story.choose_ai(engine,state)
					var actor: Dictionary = engine.current(state)
					if actor.side == 0 and engine.get_action(actor,choice.actionId).get("trainingLabel", "") == "Pacto pessoal": personal_uses += 1
					var result: Dictionary = story.act(engine,state,choice.actionId,choice.targetId)
					if result.has("error"):
						errors += 1
						break
				if state.phase != "finished": errors += 1
				rows.append({"personalUses":personal_uses,"mission":mission.id,"conditions":{"objective":mission.get("objective",{"type":"clear"}),"waves":mission.get("waves",[]),"field":mission.get("field",{}),"bossPhase":mission.get("bossPhase",{})},"seed":mission.seed,"team":team,"teamLevel":state.teamLevel,"winner":state.winner,"result":state.get("missionResult",{}),"turns":state.turns,"units":state.units.map(func(u): return {"id":u.id,"hp":u.hp,"maxHp":u.maxHp,"damage":u.stats.damage,"healing":u.stats.healing,"shieldGranted":u.stats.shieldGranted})})
	var report := {"scope":"original tactical encounters and expanded campaign; automatic policy", "rulesVersion":engine.rules.rulesVersion,"includesLumi":include_lumi or all_heroes,"allHeroes":all_heroes,"journeys":journeys,"pacts":pacts, "matureBonds":mature_bonds, "build":build,"gemLevel":gem_level,"masteryPoints":mastery_points,"trained":trained,"abilityTraining":Campaign.AbilityTraining.settings,"progression":Campaign.Progression.settings,"gemForge":Campaign.GemForge.settings,"equipment":Campaign.Equipment.settings,"tactics":Campaign.new(engine.catalog,"user://matrix-unused-progress.json").tactics,"scenarios":rows,"errors":errors}
	var output := "user://objective-matrix-%s%s%s%s.json" % [build,"-gems-%d" % gem_level if gem_level > 0 else "","-mastery-3" if mastery_points > 0 else "","-trained" if trained else ""]
	if mature_bonds: output = output.trim_suffix(".json")+"-bonds.json"
	if include_lumi: output = output.trim_suffix(".json")+"-lumi.json"
	if all_heroes: output = output.trim_suffix(".json")+"-all-heroes.json"
	if journeys: output = output.trim_suffix(".json")+("-pacts.json" if pacts else "-journeys.json")
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null:
		push_error("Matrix output could not be opened")
		quit(1)
		return
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("Objective matrix (%s): %d scenarios, %d victories, %d errors. %s" % [build,rows.size(),rows.filter(func(row):return row.winner == 0).size(),errors,ProjectSettings.globalize_path(output)])
	quit(1 if errors else 0)
