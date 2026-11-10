extends SceneTree
const Combat=preload("res://scripts/combat.gd")
const Main=preload("res://scenes/main.tscn")
const Campaign=preload("res://scripts/campaign.gd")
var checks:=0
var failures:=0
var engine=Combat.new()
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func unlocked(definitions: Array=Campaign.MISSIONS) -> Campaign:
 var story=Campaign.new(engine.catalog,"",definitions)
 for mission in story.missions:story.completed[mission.id]=mission.reward
 story.team=["vektor","axion","saira"]
 return story
func turn(state,id: String):state.order.erase(id);state.order.push_front(id);state.cursor=0
func phase_two(story,mission_id: String) -> Dictionary:
 var state=story.battle(engine,story.mission_index(mission_id))
 var boss=engine.unit(state,state.campaignBossPhase.target)
 boss.hp=int(boss.maxHp*state.campaignBossPhase.healthRatio)
 turn(state,"0-vektor");story.act(engine,state,"guard","0-vektor",false)
 turn(state,boss.id);boss.energy=100;boss.cooldowns.skill=0
 return state
func run():
 var story=unlocked();var state=phase_two(story,"truths-archive")
 var boss=engine.unit(state,"1-boss-archivist");var original=engine.catalog.hero_by_id["boss-archivist"].skill.duplicate(true)
 check(state.campaignBossPhase.reached,"The real Archivist encounter reaches its second phase")
 var skill=engine.get_action(boss,"skill")
 check(skill.get("effect")=="expose","Rebote da ata exposes the trio instead of repeating a plain area strike")
 var result=story.act(engine,state,"skill","0-vektor",false)
 var victims=result.get("events",[]).filter(func(event):return event.type=="damage" and event.target.begins_with("0-") and not event.get("reaction",false))
 check(victims.size()==3 and victims.all(func(event):return event.get("effect")=="expose" and event.get("effectTurns")==2),"Every living ally receives damage and a two-turn exposure receipt")
 var exposed=engine.unit({"units":result.impactUnits},"0-saira")
 check(exposed.statuses.any(func(status):return status.type=="expose" and status.turns==2),"Exposure exists in the authoritative impact snapshot")
 var prepared=story.BossPhases.brief(story.missions[story.mission_index("truths-archive")])
 check(prepared.contains("Defesa −25%") and prepared.contains("Purificação"),"Preparation explains exposure and its cleanse counterplay")
 turn(state,"0-vektor");var cleaner=engine.unit(state,"0-vektor");cleaner.energy=100;cleaner.cooldowns.skill=0
 var cleanse=story.act(engine,state,"skill","0-saira",false)
 check(not cleanse.has("error") and not engine.has_status(engine.unit(state,"0-saira"),"expose"),"The existing chosen ally purification removes the boss's exposure")
 check(engine.catalog.hero_by_id["boss-archivist"].skill==original,"The encounter pattern cannot mutate the boss catalog or free kits")
 state=phase_two(story,"nexus-heart");boss=engine.unit(state,"1-boss-nexus")
 skill=engine.get_action(boss,"skill")
 check(skill.get("pierce")==.35 and skill.cost==34,"The Architect's second-phase pressure pierces 35% while keeping the field-adjusted cost")
 for member in state.units.filter(func(member):return member.side==0):
  member.shield=250;member.shieldTurns=2;member.shieldLayers=[{"amount":250,"expiresRound":state.round+2}];member.guarding=false
 var before=state.duplicate(true);var prediction=engine.preview(state,"skill","0-vektor").normal
 check(state==before,"Previewing the partial shield bypass cannot consume shields, energy or RNG")
 result=story.act(engine,state,"skill","0-vektor",false)
 victims=result.get("events",[]).filter(func(event):return event.type=="damage" and event.target.begins_with("0-") and not event.get("reaction",false))
 check(victims.size()==3 and victims.all(func(event):return event.amount>0 and event.absorbed>0 and event.shieldAfter>0),"Colapso damages life while the three shields still absorb the unpierced part")
 check(result.impactUnits==prediction.impactUnits and result.events==prediction.events,"The displayed normal preview agrees with the real phase attack")
 var guarded=before.duplicate(true);engine.unit(guarded,"0-vektor").guarding=true
 var protected=story.act(engine,guarded,"skill","0-vektor",false)
 var direct=victims.filter(func(event):return event.target=="0-vektor")[0]
 var reduced=protected.events.filter(func(event):return event.type=="damage" and event.target=="0-vektor")[0]
 check(reduced.total<direct.total and reduced.amount<direct.amount,"Guard reduces both total and direct life damage despite the partial shield bypass")
 prepared=story.BossPhases.brief(story.missions[story.mission_index("nexus-heart")])
 check(prepared.contains("35%") and prepared.contains("Defesa"),"The final encounter explains the bypass fraction and guarding counterplay")
 var free_oren=engine.catalog.hero_by_id["oren"].duplicate(true)
 var phase_one=story.battle(engine,story.mission_index("tides-returns-proof"));var sluice_original=engine.get_action(engine.unit(phase_one,"1-boss-sluice"),"skill").duplicate(true)
 check(sluice_original.get("effect","")!="weaken","The Executor keeps its original technique before the phase change")
 state=phase_two(story,"tides-returns-proof");boss=engine.unit(state,"1-boss-sluice");skill=engine.get_action(boss,"skill")
 check(skill.get("effect")=="weaken","Refluxo das mares weakens the trio instead of repeating an undifferentiated area attack")
 check(skill.cost==sluice_original.cost and skill.cooldown==sluice_original.cooldown,"The new pressure preserves the Executor's real energy cost and cooldown")
 before=state.duplicate(true);prediction=engine.preview(state,"skill","0-axion").normal
 check(state==before,"Previewing Refluxo cannot change statuses, energy, life or RNG")
 result=story.act(engine,state,"skill","0-axion",false)
 victims=result.events.filter(func(event):return event.type=="damage" and event.target.begins_with("0-") and not event.get("reaction",false))
 check(victims.size()==3 and victims.all(func(event):return event.get("effect")=="weaken" and event.get("effectTurns")==2),"The real Refluxo impact records two personal turns of weakness on every living ally")
 var weakened=engine.unit({"units":result.impactUnits},"0-axion")
 check(weakened.statuses.any(func(status):return status.type=="weaken" and status.turns==2),"Weakness exists in the authoritative impact snapshot")
 turn(state,"0-axion");var weak_hit=engine.preview(state,"basic",boss.id).normal
 var healthy=state.duplicate(true);engine.unit(healthy,"0-axion").statuses=engine.unit(healthy,"0-axion").statuses.filter(func(status):return status.type!="weaken")
 var healthy_hit=engine.preview(healthy,"basic",boss.id).normal
 var weak_damage=weak_hit.events.filter(func(event):return event.type=="damage" and event.target==boss.id and not event.get("reaction",false))[0]
 var healthy_damage=healthy_hit.events.filter(func(event):return event.type=="damage" and event.target==boss.id and not event.get("reaction",false))[0]
 check(weak_damage.total<healthy_damage.total,"The real weakened basic preview loses damage instead of showing a cosmetic status")
 turn(state,"0-vektor");cleaner=engine.unit(state,"0-vektor");cleaner.energy=100;cleaner.cooldowns.skill=0
 var had_weakness=engine.has_status(engine.unit(state,"0-axion"),"weaken")
 cleanse=story.act(engine,state,"skill","0-axion",false)
 check(had_weakness and not cleanse.has("error") and not engine.has_status(engine.unit(state,"0-axion"),"weaken"),"A freely chosen Vektor's actual purification removes the Executor's weakness")
 boss.hp=boss.maxHp;turn(state,"0-axion");story.act(engine,state,"guard","0-axion",false)
 check(state.campaignBossPhase.reached and engine.get_action(boss,"skill").get("effect")=="weaken","Recovering boss life cannot reverse or reapply its reached pressure phase")
 prepared=story.BossPhases.brief(story.missions[story.mission_index("tides-returns-proof")])
 check(prepared.contains("Ataque −20%") and prepared.contains("Purificação"),"The real preparation explains the attack reduction and its purification counterplay")
 check(engine.catalog.hero_by_id["oren"]==free_oren and engine.catalog.hero_by_id["boss-sluice"].skill==sluice_original,"The pressure stays in the encounter actor and cannot mutate Oren or the boss catalog")
 for patch in [{"skillEffect":"unknown"},{"skillEffect":"heal"},{"skillEffect":5},{"skillPierce":-.1},{"skillPierce":.51},{"skillPierce":"0.35"},{"skillPierce":true},{"skillPirece":.35}]:
  var definitions=Campaign.MISSIONS.duplicate(true)
  definitions[story.mission_index("truths-archive")].bossPhase.merge(patch,true)
  var invalid=unlocked(definitions)
  check(invalid.battle(engine,invalid.mission_index("truths-archive")).has("error"),"Malformed phase pressure cannot start a mission: %s"%patch)
 var app=Main.instantiate();app.preferences_path="user://boss-pattern-ui.cfg";root.add_child(app);await process_frame;await process_frame
 app.campaign=unlocked();app.sound.enabled=false;app.voice.set_enabled(false);app._set_reduced(true)
 for entry in [["truths-archive",4,"Defesa −25%"],["nexus-heart",5,"35%"],["tides-returns-proof",1,"Ataque −20%"]]:
  app.hub.open("story");app.hub.chapter_buttons[entry[1]].pressed.emit()
  var index=app.campaign.mission_index(entry[0]);app.hub.mission_slots[index].pressed.emit()
  check(app.hub.body.find_children("*","Label",true,false).any(func(label):return label.text.contains(entry[2])),"The actual preparation exposes the distinct pressure of "+entry[0])
  app.hub.preparation_button.pressed.emit();app.start_button.pressed.emit()
  var enemy=app.combat.unit(app.state,app.state.campaignBossPhase.target);enemy.hp=int(enemy.maxHp*app.state.campaignBossPhase.healthRatio)
  turn(app.state,"0-axion");turn(app.state,"0-vektor")
  await app._play_turn("guard","0-vektor")
  check(app.state.campaignBossPhase.reached and app.objective_label.text.contains(entry[2]),"The actual HUD identifies the active second-phase pressure of "+entry[0])
  app._leave_battle();await process_frame;await process_frame
 await create_timer(1.5).timeout;app.queue_free();await process_frame
 print("Boss patterns: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
