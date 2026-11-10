extends SceneTree
## Legal continuous campaign policy. No fabricated victories, gear, mastery or bonds.
const Campaign=preload("res://scripts/campaign.gd")
const Combat=preload("res://scripts/combat.gd")
var rows: Array=[]
var errors: Array=[]
var gear_order: Array=[0,1,2]
var train_skills:=true
var offensive_gems:=false
var play_journeys:=false
var attempted_journeys: Dictionary={}
var decision_times: Array=[]
func _initialize():run.call_deferred()
func prepare(story,index: int) -> void:
 if offensive_gems and story.missions[index].get("objective",{}).get("type")=="target":
  for hero in story.team:story.remove_gems(hero)
  while story.available("ember")<9:
   if not story.craft_gem("ember"):break
  for hero in story.team:
   for slot in range(3):story.equip(hero,"ember",slot)
 for slot in gear_order:
  for tier in [2,3]:
   for hero in story.team:
    if int(story.piece(hero,slot).tier)<tier:story.upgrade_piece(hero,slot)
 for hero in story.team:
  story.fill_gems(hero)
  if not train_skills:continue
  for choice in [["basic","rhythm"],["skill","burst"],["ultimate","economy"]]:
   if story.AbilityTraining.available(hero,choice[0],choice[1],story.mastery_experience(hero),story.completed):story.set_ability(hero,choice[0],choice[1])
func fight(story,engine,index: int):
 prepare(story,index)
 var state: Dictionary=story.battle(engine,index)
 var before={"level":story.team_level(),"materials":story.materials(),"gear":story.gear.duplicate(true),"gems":story.equipped.duplicate(true),"mastery":story.mastery.duplicate(),"bonds":story.bonds.duplicate(),"training":story.ability_choices.duplicate(true)}
 while state.phase=="playing" and state.turns<400:
  var started:=Time.get_ticks_usec()
  var choice: Dictionary=story.choose_ai(engine,state)
  if engine.current(state).side==0:decision_times.append(Time.get_ticks_usec()-started)
  var result: Dictionary=story.act(engine,state,choice.actionId,choice.targetId)
  if result.has("error"):errors.append(result.error);break
 var row={"mission":story.missions[index].id,"team":story.team.duplicate(),"kind":story.missions[index].get("kind","main"),"before":before,"winner":state.winner,"turns":state.turns,"result":state.get("missionResult",{}),"remainingHp":state.units.map(func(unit):return {"hero":unit.heroId,"hp":unit.hp})}
 rows.append(row)
 print("%02d %s: winner %d, %d actions"%[rows.size(),row.mission,state.winner,state.turns])
 if state.phase!="finished" or state.winner!=0:return story
 var receipt: Dictionary=story.claim_victory(state)
 if not receipt.get("saved",false):errors.append(receipt.get("error",story.error_text));return story
 var reopened=Campaign.new(engine.catalog,story.store_path)
 if reopened.completed!=story.completed or reopened.mastery!=story.mastery or reopened.bonds!=story.bonds or reopened.gear!=story.gear or reopened.equipped!=story.equipped:
  errors.append("Reopening changed earned progress");return story
 return reopened
func run():
 var team: Array=["veyra","axion","astra"]
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--team="):team=Array(arg.trim_prefix("--team=").split(","))
  if arg=="--energy-first":gear_order=[0,2,1]
  if arg=="--no-training":train_skills=false
  if arg=="--offense-gems":offensive_gems=true
  if arg=="--journeys":play_journeys=true
 var engine=Combat.new()
 var path="user://playthrough-progress.json"
 if FileAccess.file_exists(path):
  push_error("Use a fresh XDG_DATA_HOME; existing progress is preserved.");quit(1);return
 var story=Campaign.new(engine.catalog,path)
 if not story.set_team(team):push_error("Invalid trio");quit(1);return
 for encounter in range(48):
  var index: int=story.next_mission()
  if index<0 or story.is_complete(index):break
  if play_journeys:
   for hero in team:
    var personal: int=story.journey_index(hero)
    if personal>=0 and not story.is_complete(personal) and not attempted_journeys.has(hero) and story.can_play(personal):
     attempted_journeys[hero]=true
     story=fight(story,engine,personal)
  if not errors.is_empty():break
  story=fight(story,engine,index)
  if not story.is_complete(index) or not errors.is_empty():break
 var count: int=story.main_missions().filter(story.is_complete).size()
 var ordered: Array=decision_times.duplicate();ordered.sort()
 var timing={"scope":"headless native AI decision only; excludes rendering and human input","count":ordered.size(),"maximumUsec":ordered[-1] if not ordered.is_empty() else 0,"p95Usec":ordered[int((ordered.size()-1)*0.95)] if not ordered.is_empty() else 0}
 var report={"timing":timing,"policy":"fixed trio; earned gear upgrades, existing gem inventory and unlocked mastery alternatives; no grind or fabricated progress","gearOrder":gear_order,"training":train_skills,"offensiveGems":offensive_gems,"playJourneys":play_journeys,"team":team,"completed":count,"errors":errors,"encounters":rows}
 var file=FileAccess.open("user://campaign-playthrough.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(report,"\t"));file.close()
 print("Continuous campaign: %d/48 missions, %d errors. %s"%[count,errors.size(),ProjectSettings.globalize_path("user://campaign-playthrough.json")])
 quit(0 if count==48 and errors.is_empty() else 1)
