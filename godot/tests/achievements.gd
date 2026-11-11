extends SceneTree
const Main=preload("res://scenes/main.tscn")
const Campaign=preload("res://scripts/campaign.gd")
const Achievements=preload("res://scripts/achievements.gd")
const PATH="user://achievement-test.json"
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures+=1;push_error(message)
func entry(story,id: String) -> Dictionary:
 for milestone in Achievements.entries(story):
  if milestone.id==id:return milestone
 return {}
func run():
 var app=Main.instantiate();root.add_child(app)
 await create_timer(0.10).timeout
 app.campaign=Campaign.new(app.catalog,PATH)
 app.hub.open("extras")
 await process_frame
 check(is_instance_valid(app.hub.find_child("LocalAchievements",true,false)),"Extras presents local achievements and their campaign progress")
 check(Achievements.entries(app.campaign).size()==8 and Achievements.entries(app.campaign).all(func(item):return not item.unlocked),"A fresh profile has eight visible milestones and no invented achievements")
 check(not FileAccess.file_exists(PATH),"Opening achievements never creates or writes a save")
 var partial=Campaign.new(app.catalog,"user://achievement-partial.json",Campaign.MISSIONS.slice(0,9))
 check(not entry(partial,"full-chorus").unlocked and not entry(partial,"against-odds").unlocked,"A partial catalog cannot invent completed journeys or challenges with a zero goal")
 check(app.campaign.complete(0).get("saved",false) and entry(app.campaign,"first-light").unlocked and entry(app.campaign,"six-paths").current==1,"A saved first mission unlocks the first achievement and advances the full campaign")
 var original:=FileAccess.get_file_as_string(PATH)
 app.hub.open("extras");await process_frame
 check(FileAccess.get_file_as_string(PATH)==original,"Viewing acquired milestones preserves the save byte for byte")
 var reopened=Campaign.new(app.catalog,PATH)
 check(entry(reopened,"first-light").unlocked,"The first achievement survives reopening through the saved mission fact")
 reopened.completed=Campaign.LEGACY_REWARDS.duplicate()
 check(entry(reopened,"first-light").unlocked and not entry(reopened,"side-by-side").unlocked and not entry(reopened,"own-mastery").unlocked and not entry(reopened,"first-pact").unlocked,"Old mission victories grant their achievement without inferring bonds, mastery or personal journeys")
 for mission in reopened.missions:reopened.completed[mission.id]=mission.reward
 check(entry(reopened,"six-paths").goal==48 and entry(reopened,"six-paths").unlocked,"The full campaign achievement counts all forty-eight main missions")
 check(entry(reopened,"full-chorus").goal==24 and entry(reopened,"full-chorus").unlocked and entry(reopened,"first-pact").unlocked,"All twenty-four recorded journeys complete the personal chorus")
 check(entry(reopened,"against-odds").goal==3 and entry(reopened,"against-odds").unlocked and entry(reopened,"beacon-awake").unlocked,"Optional challenges and maximum team level have independent milestones")
 for victory in range(3):reopened.Bonds.record(reopened.bonds,["veyra","axion","astra"])
 check(entry(reopened,"side-by-side").unlocked and not entry(reopened,"own-mastery").unlocked,"A mature bond does not also invent individual mastery")
 reopened.mastery["veyra"]=60
 check(entry(reopened,"own-mastery").unlocked,"One hero with sixty participation points achieves mastery III")
 check(reopened.save_progress(),"The acquired campaign facts can be persisted normally: "+reopened.error_text)
 var saved:=FileAccess.get_file_as_string(PATH)
 var replayed=Campaign.new(app.catalog,PATH)
 app.campaign=replayed;app.hub.open("extras");await process_frame
 var labels=app.hub.find_child("LocalAchievements",true,false).find_children("*","Label",true,false)
 check(labels.any(func(label):return label.text=="Conquistas locais · 8/8") and FileAccess.get_file_as_string(PATH)==saved,"The real Extras page shows all eight earned milestones after reopening without rewriting the save")
 app.voice.stop_line();app.sound.stop_all();app.queue_free()
 await create_timer(0.15).timeout
 print("Local achievements: %d checks, %d failures."%[checks,failures])
 quit(1 if failures else 0)
