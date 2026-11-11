extends SceneTree
const Main=preload("res://scenes/main.tscn")
const PATH="user://defeat-presentation.cfg"
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func fallen(fighter) -> bool:
 # The new sheets' last cell is a kneeling body; the preserved cast uses tilt.
 var kneeling=fighter.hero_id in ["rhazen","cindra","oren","nima","kira","vektor","axion","astra","elun","saira","veyra","sylva","vesper","auren","torv","brin","bast","ivo","noct","maura","riven","elyra","solen","zaya"] and fighter.pose_index==7 and fighter.artwork.texture!=fighter.resting_art
 return fighter.dead and fighter.visual_root.modulate.a*fighter.artwork.modulate.a>=.3 and (kneeling or fighter.visual_root.position.y>260 and absf(fighter.visual_root.rotation)>0.1)
func idle(app):
 var deadline=Time.get_ticks_msec()+6000
 while app.busy and Time.get_ticks_msec()<deadline:await process_frame
 check(not app.busy,"The actual presentation reaches its logical end")
func run():
 DirAccess.remove_absolute(PATH)
 var app=Main.instantiate();app.preferences_path=PATH;root.add_child(app);await process_frame;await process_frame
 app.mode="local";app.sound.enabled=false;app.voice.set_enabled(false);app._enter_free();await process_frame
 app.combat.unit(app.state,"1-vesper").hp=1
 app.start_button.pressed.emit();app.execute_button.pressed.emit();await idle(app)
 var defeated=app.fighters["1-vesper"]
 check(fallen(defeated),"The lethal hit finishes with a visible fallen opponent")
 app.execute_button.pressed.emit();await process_frame;await process_frame
 check(fallen(defeated),"Starting the next action cannot stand a defeated opponent back up")
 app._skip_animation();app._set_reduced(true);app._new_battle()
 app.combat.unit(app.state,"1-vesper").hp=1
 app.start_button.pressed.emit();app.execute_button.pressed.emit();await idle(app)
 check(fallen(app.fighters["1-vesper"]),"Reduced motion presents the settled defeat pose without requiring a recoil animation")
 app._set_reduced(false);app._new_battle();app.combat.unit(app.state,"1-vesper").hp=1
 app.start_button.pressed.emit();app.execute_button.pressed.emit();app.skip_button.pressed.emit();await process_frame
 check(fallen(app.fighters["1-vesper"]) and app.state.turns==1,"Skipping before impact commits the lethal result and its settled pose once")
 await create_timer(1.5).timeout
 check(fallen(app.fighters["1-vesper"]) and app.state.turns==1,"Abandoned animation callbacks cannot restore a defeated opponent")
 app._new_battle();app.start_button.pressed.emit()
 var next_id=app.state.order[(app.state.cursor+1)%app.state.order.size()]
 var next=app.combat.unit(app.state,next_id);next.hp=1;next.statuses=[{"type":"burn","turns":2}]
 app.execute_button.pressed.emit();await idle(app)
 check(fallen(app.fighters[next_id]) and app.combat.unit(app.state,next_id).hp==0,"Lethal start-of-turn damage also leaves a settled defeat pose")
 app._new_battle();app.start_button.pressed.emit()
 var actor_id: String=app.combat.current(app.state).id
 app.combat.unit(app.state,actor_id).hp=1
 app.combat.unit(app.state,app.target_id).statuses=[{"type":"mirror","turns":2}]
 var expected=app.state.duplicate(true);var receipt=app.combat.act(expected,app.selected_action,app.target_id)
 check(app.combat.unit(expected,actor_id).hp==0 and receipt.events.any(func(event):return event.get("reaction",false)),"The reflection fixture actually defeats the attacking actor")
 app.execute_button.pressed.emit();await idle(app)
 check(fallen(app.fighters[actor_id]) and app.combat.unit(app.state,actor_id).hp==0,"An actor defeated by reflection settles after its attack recovery")
 app.execute_button.pressed.emit();await process_frame
 check(fallen(app.fighters[actor_id]),"A later action cannot stand the reflected attacker back up")
 app.skip_button.pressed.emit()
 app._new_battle()
 check(app.fighters.values().all(func(fighter):return not fighter.dead and fighter.visual_root.position==Vector2(93,257) and fighter.visual_root.rotation==0),"A new battle restores the living roster without an old fallen pose")
 for hero in app.catalog.heroes:
  var partners=app.catalog.heroes.filter(func(other):return other.id!=hero.id).slice(0,2).map(func(other):return other.id)
  var trio=[hero.id]+partners
  var snapshot=app.combat.new_battle(trio,trio)
  for side in range(2):
   var data=app.combat.unit(snapshot,"%d-%s"%[side,hero.id]).duplicate(true)
   var fighter=app.Fighter.new();app.field.add_child(fighter);fighter.setup(hero,data.id,app.catalog.affinity_color(hero.classId))
   fighter.refresh(data,false,false,false);data.hp=0;fighter.refresh(data,false,false,false)
   check(fallen(fighter) and fighter.health.value==0 and fighter.visual_root.modulate.a>0 and fighter.visual_root.modulate.a<0.5,"%s side %d: a loaded dead snapshot keeps a visible fallen body and zero health"%[hero.name,side])
   data.hp=data.maxHp;fighter.refresh(data,false,false,true)
   check(not fighter.dead and fighter.visual_root.rotation==0 and fighter.visual_root.position==Vector2(93,257) and fighter.visual_root.modulate.a==1,"%s side %d: replacing the snapshot with a living state restores its normal pose"%[hero.name,side])
   fighter.queue_free()
  await process_frame
 app._leave_battle();await create_timer(1.5).timeout;app.queue_free();await process_frame
 DirAccess.remove_absolute(PATH)
 print("Defeat presentation: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
