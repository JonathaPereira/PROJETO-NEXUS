extends SceneTree
const Campaign = preload("res://scripts/campaign.gd")
const Combat = preload("res://scripts/combat.gd")
const Main = preload("res://scenes/main.tscn")
const PATH := "user://pact-ability-test.json"
var checks := 0
var failures := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok:
  failures+=1
  push_error(message)

func _run() -> void:
 for suffix in ["",".tmp",".bak",".bak.tmp"]:DirAccess.remove_absolute(PATH+suffix)
 var engine:=Combat.new()
 var story:=Campaign.new(engine.catalog,PATH)
 check(not story.set_ability("veyra","skill","pact"),"A personal technique requires the completed journey")
 story.completed=Campaign.LEGACY_REWARDS.duplicate()
 var index:=story.journey_index("veyra")
 check(story.complete(index).get("saved",false),"The personal journey is recorded through the campaign ledger")
 check(story.set_ability("veyra","skill","pact"),"The acquired pact technique can be selected without mastery grinding")
 if story.ability_choices.get("veyra",{}).get("skill")=="pact":
  var original: Dictionary=engine.catalog.hero_by_id.veyra.skill.duplicate(true)
  var state:=story.battle(engine,0)
  state.order.erase("0-veyra");state.order.push_front("0-veyra");state.cursor=0
  var actor: Dictionary=engine.current(state)
  actor.energy=100
  var ability:=engine.get_action(actor,"skill")
  check(ability.secondary.kind=="shield" and ability.power<original.power,"Veyra trades part of the hit for a personal barrier")
  var prediction: Dictionary=engine.preview(state,"skill","1-minion-acolyte").normal
  var result:=story.act(engine,state,"skill","1-minion-acolyte",false)
  check(not result.has("error") and result.events==prediction.events and actor.shield>0,"The selected pact technique executes exactly its preview and creates the barrier")
  var reopened:=Campaign.new(engine.catalog,PATH)
  check(reopened.ability_choices==story.ability_choices and reopened.trained_action("veyra","skill")==ability,"Reopening restores the acquired choice and its real behavior")
  check(story.set_ability("veyra","skill","") and engine.get_action(actor,"skill")==ability,"Removing a choice affects the next mission and preserves the active battle")
  check(engine.catalog.hero_by_id.veyra.skill==original,"The base catalog remains isolated from the campaign alternative")
 for hero in engine.catalog.heroes:
  var team: Array=[hero.id]
  team.append_array(["axion","veyra","astra"].filter(func(id):return id!=hero.id).slice(0,2))
  story.set_team(team)
  check(story.complete(story.journey_index(hero.id)).get("saved",false),"The pact can be acquired for "+hero.name)
  check(story.set_ability(hero.id,"skill","pact"),"The personal technique unlocks for "+hero.name)
  var base: Dictionary=hero.skill.duplicate(true)
  var state:=story.battle(engine,0)
  state.order.erase("0-"+hero.id);state.order.push_front("0-"+hero.id);state.cursor=0
  var actor: Dictionary=engine.current(state)
  actor.energy=100
  for unit in state.units:
   unit.hp=int(unit.maxHp*0.6)
  var action:=engine.get_action(actor,"skill")
  var targets: Array=engine.legal_targets(state,actor,action)
  var before: Dictionary=state.duplicate(true)
  var prediction: Dictionary=engine.preview(state,"skill",targets[0].id).normal
  check(state==before,"The personal preview does not mutate the battle: "+hero.name)
  var result:=story.act(engine,state,"skill",targets[0].id,false)
  check(not result.has("error") and result.events==prediction.events and action.trainingLabel=="Pacto pessoal" and hero.skill==base,"The personal action resolves its own public preview: "+hero.name)
 story.set_team(["axion","veyra","astra"])
 var field_state:=story.battle(engine,story.mission_index("tidal-heart"))
 var field_skill: Dictionary=engine.get_action(engine.unit(field_state,"0-veyra"),"skill")
 check(field_skill.cost==35 and field_skill.description.contains("Custo: 35 EN.") and not field_skill.description.contains("Custo 30 EN."),"A personal technique shows its final cost under the energy field")
 var healthy:=FileAccess.get_file_as_string(PATH)
 var invalid: Dictionary=JSON.parse_string(healthy)
 invalid.completed.erase("journey-veyra")
 var file=FileAccess.open(PATH,FileAccess.WRITE)
 file.store_string(JSON.stringify(invalid));file.close()
 var denied:=Campaign.new(engine.catalog,PATH)
 check(not denied.save_progress() and FileAccess.get_file_as_string(PATH)==JSON.stringify(invalid),"A forged unearned personal technique cannot overwrite the original save")
 file=FileAccess.open(PATH,FileAccess.WRITE);file.store_string(healthy);file.close()
 var legacy: Dictionary=JSON.parse_string(healthy)
 legacy.schemaVersion=9;legacy.abilityChoices={}
 var raw:=JSON.stringify(legacy)
 file=FileAccess.open(PATH,FileAccess.WRITE);file.store_string(raw);file.close()
 var migrating:=Campaign.new(engine.catalog,PATH)
 check(migrating.set_ability("veyra","skill","pact") and FileAccess.get_file_as_string(PATH+".v9.bak")==raw,"A schema nine profile migrates with an exact backup")
 var app=Main.instantiate()
 root.add_child(app)
 await create_timer(0.12).timeout
 app.campaign=Campaign.new(app.catalog,PATH)
 app.hub.selected_hero="veyra";app.hub.open("progress")
 await create_timer(0.08).timeout
 var picker=app.hub.training_pickers.skill
 check(picker.item_count==3 and not picker.is_item_disabled(2) and picker.get_item_metadata(picker.selected)=="pact","The acquired personal technique appears selected in the real Evolution menu")
 picker.select(0);picker.item_selected.emit(0)
 app.hub.training_apply_buttons.skill.pressed.emit()
 check(app.campaign.ability_choices.get("veyra",{}).get("skill","")=="","The same menu restores the original technique")
 app.voice.stop_line();app.sound.stop_all()
 app.queue_free()
 await process_frame
 print("Personal pact abilities: %d checks, %d failures."%[checks,failures])
 quit(1 if failures else 0)
