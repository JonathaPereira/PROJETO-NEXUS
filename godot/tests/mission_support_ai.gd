extends SceneTree
const Campaign=preload("res://scripts/campaign.gd")
const Combat=preload("res://scripts/combat.gd")
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures+=1;push_error(message)
func run():
 var engine=Combat.new()
 var story=Campaign.new(engine.catalog,"user://support-ai.json")
 story.completed=Campaign.LEGACY_REWARDS.duplicate()
 story.set_team(["kira","bast","vektor"])
 story.mastery["vektor"]=10
 check(story.set_ability("vektor","skill","burst"),"The fixture has legally unlocked offensive energy support")
 var state=story.battle(engine,story.mission_index("forge-relay"))
 state.round=6
 state.order=["0-vektor","0-kira","0-bast","1-boss-relay","1-minion-tide","1-minion-siren"]
 state.cursor=0
 var support=engine.unit(state,"0-vektor")
 var striker=engine.unit(state,"0-kira")
 support.energy=100;striker.energy=48
 engine.unit(state,"1-boss-relay").hp=450
 var before=state.duplicate(true)
 var choice=story.choose_ai(engine,state)
 check(choice.actionId=="skill" and choice.targetId==striker.id,"At the deadline, offensive support enables the next ally's decisive ultimate")
 check(state==before,"Evaluating offensive support preserves battle state and RNG")
 if choice.actionId=="skill" and choice.targetId==striker.id:
  story.act(engine,state,choice.actionId,choice.targetId,false)
  check(engine.current(state).id==striker.id and striker.energy>=80,"The selected support really unlocks the immediate allied ultimate")
  var strike=story.choose_ai(engine,state)
  story.act(engine,state,strike.actionId,strike.targetId,false)
  check(state.phase=="finished" and state.winner==0,"Support followed by the ultimate wins before the commander deadline")
 var cooling=before.duplicate(true)
 engine.unit(cooling,"0-kira").cooldowns["ultimate"]=1
 var cooled_choice=story.choose_ai(engine,cooling)
 check(cooled_choice.actionId=="skill" and cooled_choice.targetId=="0-kira","Support forecasting accounts for a cooldown that expires at the next allied turn")
 if cooled_choice.actionId=="skill" and cooled_choice.targetId=="0-kira":
  story.act(engine,cooling,cooled_choice.actionId,cooled_choice.targetId,false)
  var cooled_strike=story.choose_ai(engine,cooling)
  story.act(engine,cooling,cooled_strike.actionId,cooled_strike.targetId,false)
  check(cooling.phase=="finished" and cooling.winner==0,"The recovered ultimate actually wins after the support forecast")
 var late=before.duplicate(true)
 late.order=["0-kira","0-vektor","0-bast","1-boss-relay","1-minion-tide","1-minion-siren"]
 late.cursor=1
 engine.unit(late,"0-bast").hp=0
 var too_late=story.choose_ai(engine,late)
 check(not(too_late.actionId=="skill" and too_late.targetId=="0-kira"),"The AI cannot value support for an ally who has no turn left before the deadline")
 var free=before.duplicate(true)
 free.erase("campaignObjective")
 check(story.choose_ai(engine,free)==engine.choose_ai(free),"Free combat still uses its normalized decision policy")
 story.set_team(["vektor","oren","sylva"])
 var finisher=story.battle(engine,story.mission_index("forge-relay"))
 finisher.round=6
 finisher.order=["0-vektor","0-oren","0-sylva","1-boss-relay","1-minion-tide","1-minion-siren"]
 finisher.cursor=0
 engine.unit(finisher,"0-vektor").energy=100
 engine.unit(finisher,"0-oren").energy=0
 engine.unit(finisher,"0-sylva").energy=0
 engine.unit(finisher,"1-boss-relay").hp=95
 var immediate=story.choose_ai(engine,finisher)
 check(immediate.actionId=="basic" and immediate.targetId=="1-boss-relay","A guaranteed objective victory now has priority over multiple allies' future victory bonuses")
 engine.unit(finisher,"0-oren").hp=100
 var injured_before=finisher.duplicate(true)
 var urgent=story.choose_ai(engine,finisher)
 check(urgent.actionId=="basic" and urgent.targetId=="1-boss-relay" and finisher==injured_before,"Immediate mission victory takes priority over emergency support without mutating state or RNG")
 story.act(engine,finisher,urgent.actionId,urgent.targetId,false)
 check(finisher.phase=="finished" and finisher.winner==0,"The selected finisher really completes the mission with an injured ally")
 print("Offensive mission support: %d checks, %d failures."%[checks,failures])
 quit(1 if failures else 0)
