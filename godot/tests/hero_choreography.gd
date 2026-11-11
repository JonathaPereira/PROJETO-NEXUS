extends SceneTree
const Main=preload("res://scenes/main.tscn")
const Impact=preload("res://scripts/impact_modern.gd")
const PATH="user://choreography-test.cfg"
const PROFILES=[{"id":"oren","support":["skill","ultimate"]},{"id":"nima","support":[]},{"id":"kira","support":[]},{"id":"vektor","support":["skill","ultimate"]},{"id":"axion","support":["skill","ultimate"]},{"id":"astra","support":[]},{"id":"elun","support":["skill"]},{"id":"saira","support":["skill","ultimate"]},{"id":"veyra","support":[]},{"id":"sylva","support":["skill","ultimate"]},{"id":"vesper","support":["skill"]},{"id":"auren","support":["skill"]},{"id":"torv","support":[]},{"id":"brin","support":["skill","ultimate"]},{"id":"bast","support":["skill","ultimate"]},{"id":"ivo","support":[]},{"id":"noct","support":[]},{"id":"maura","support":["ultimate"]},{"id":"riven","support":[]},{"id":"elyra","support":["skill","ultimate"]},{"id":"solen","support":[]},{"id":"zaya","support":["skill","ultimate"]}]
var selected_heroes:Array=[]
var checks:=0
var failures:=0
func _initialize():
 for argument in OS.get_cmdline_user_args():
  if argument.begins_with("--heroes="):
   selected_heroes=Array(argument.trim_prefix("--heroes=").split(","))
   var known=PROFILES.map(func(profile):return profile.id)+["rhazen","cindra"]
   if selected_heroes.is_empty() or selected_heroes.any(func(id):return id not in known):
    push_error("Unknown choreography selection");quit(1);return
 if not selected_heroes.is_empty():print("Choreography selection: %s; Rhazen/Cindra baseline always included."%str(selected_heroes))
 run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func prepare(app,action: String,side:=0,hero_id:="rhazen"):
 var partners=app.catalog.heroes.filter(func(hero):return hero.id!=hero_id).slice(0,2).map(func(hero):return hero.id)
 app.teams[side]=[hero_id]+partners;app._new_battle()
 var id="%d-%s"%[side,hero_id];app.state.order.erase(id);app.state.order.push_front(id);app.state.cursor=0
 app.combat.unit(app.state,id).energy=100
 await process_frame;await process_frame
 app.start_button.pressed.emit();app.action_buttons[action].pressed.emit()
 return app.fighters[id]
func present(app,action: String,side:=0,hero_id:="rhazen") -> Dictionary:
 var fighter=await prepare(app,action,side,hero_id)
 var expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id)
 var hits: int=app.director.impact_count
 app.execute_button.pressed.emit()
 var frames: Array=[];var sheets: Array=[];var launch:={};var deadline=Time.get_ticks_msec()+6000
 while app.busy and Time.get_ticks_msec()<deadline:
  if fighter.artwork.texture!=fighter.resting_art and (frames.is_empty() or frames[-1]!=fighter.pose_index):frames.append(fighter.pose_index)
  if fighter.artwork.texture is AtlasTexture and fighter.artwork.texture!=fighter.resting_art:
   var sheet: String=fighter.artwork.texture.atlas.resource_path
   if not sheet in sheets:sheets.append(sheet)
  if launch.is_empty():
   for effect in app.effects.get_children():
    if not effect.is_queued_for_deletion() and effect.get_script()==Impact and effect.phase=="travel":launch={"origin":effect.origin,"offset":effect.origin-fighter.hit_position()};break
  await process_frame
 return {"frames":frames,"sheets":sheets,"resolved":not app.busy and app.state==expected and app.director.impact_count==hits+1,"fighter":fighter,"launch":launch}
func run():
 DirAccess.remove_absolute(PATH)
 var app=Main.instantiate();app.preferences_path=PATH;root.add_child(app);await process_frame;await process_frame
 app.mode="local";app.teams[0]=["rhazen","axion","astra"];app.sound.enabled=false;app.voice.set_enabled(false);app._enter_free();await process_frame
 var actor_id="0-rhazen";app.state.order.erase(actor_id);app.state.order.push_front(actor_id);app.state.cursor=0
 app.start_button.pressed.emit()
 var expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id)
 var hits: int=app.director.impact_count
 app.execute_button.pressed.emit();await process_frame
 var fighter=app.fighters[actor_id]
 check(fighter.artwork.texture!=fighter.resting_art,"Rhazen's real attack uses drawn anatomical preparation frames instead of only moving his idle illustration")
 var drawings:={};var deadline=Time.get_ticks_msec()+6000
 while app.busy and Time.get_ticks_msec()<deadline:
  if fighter.artwork.texture is AtlasTexture and fighter.artwork.texture!=fighter.resting_art:drawings[str(fighter.artwork.texture.region)]=true
  await process_frame
 check(drawings.size()>=6,"Rhazen's full hammer attack shows distinct drawn windup, release, contact and recovery poses")
 check(not app.busy and app.state==expected and app.director.impact_count==hits+1,"The multi-frame body sequence resolves the same single legal action and impact")
 var dead_snapshot=app.combat.unit(app.state,actor_id).duplicate(true);dead_snapshot.hp=0
 fighter.refresh(dead_snapshot,false,false,false)
 check(fighter.pose_index==7 and fighter.artwork.texture!=fighter.resting_art,"Rhazen's defeated snapshot selects the authored kneeling drawing rather than a tilted standing illustration")
 fighter.reset_pose()
 check(fighter.pose_index==7 and fighter.visual_root.rotation==0,"Cancelling presentation preserves the drawn kneeling pose without tilting it again")
 var result=await present(app,"skill")
 check(result.frames==[6],"Coração de ferro uses the authored defensive brace instead of swinging the hammer")
 check(result.resolved,"The defensive body sequence keeps the engine's shield, energy and statuses")
 result=await present(app,"ultimate",1)
 check(result.frames==[8,9,10,11,12,13,14,15,0],"Queda da fornalha uses its own mirrored eight-drawing supreme sequence rather than the basic hammer storyboard")
 check(result.sheets==["res://assets/poses/rhazen-supreme-renascimento-v1.png","res://assets/poses/rhazen-renascimento-v1.png"],"The supreme renders its new sheet before returning to the preserved base drawing")
 check(result.resolved and result.fighter.artwork.flip_h,"The mirrored area strike resolves once and keeps the opposing facing")
 result=await present(app,"basic")
 check(result.frames==[1,2,3,4,5,0] and result.sheets==["res://assets/poses/rhazen-renascimento-v1.png"] and result.resolved,"A basic attack after the supreme retains its original drawings and combat result")
 fighter=await prepare(app,"ultimate")
 expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id)
 app.execute_button.pressed.emit();await create_timer(.25).timeout;app.skip_button.pressed.emit();await create_timer(1.2).timeout
 check(not app.busy and app.state==expected and fighter.artwork.texture==fighter.resting_art,"Skipping kills the body-frame tween and cannot replay frames over the next actor")
 fighter=await prepare(app,"ultimate");app.execute_button.pressed.emit();await create_timer(.25).timeout;app._new_battle()
 var fresh=app.state.duplicate(true);await create_timer(1.2).timeout
 check(app.state==fresh and app.fighters.values().all(func(member):return member.artwork.texture==member.resting_art),"Restarting abandons old frame sequences without touching the new roster")
 fighter=await prepare(app,"basic",1)
 app.combat.unit(app.state,"0-rhazen").hp=1;app._select_target("0-rhazen")
 expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id)
 app.execute_button.pressed.emit();deadline=Time.get_ticks_msec()+6000
 while app.busy and Time.get_ticks_msec()<deadline:await process_frame
 var corpse=app.fighters["0-rhazen"]
 check(not app.busy and app.state==expected and corpse.dead and corpse.pose_index==7 and corpse.visual_root.rotation==0,"A real fatal attack selects Rhazen's kneeling body while preserving the engine result")
 app.action_buttons.guard.pressed.emit();app.execute_button.pressed.emit();await process_frame
 check(corpse.pose_index==7 and corpse.dead,"The next action preserves the kneeling body from the actual lethal hit")
 app.skip_button.pressed.emit()
 app._set_reduced(true);result=await present(app,"ultimate")
 check(result.resolved and result.frames.is_empty(),"Reduced motion resolves the same supreme without playing the new body sequence")
 app._set_reduced(false);result=await present(app,"basic",0,"cindra")
 check(result.frames==[1,2,3,4,5,0] and result.resolved,"Cindra's actual ranged shot uses drawn bow preparation, release and recovery while resolving once")
 result=await present(app,"skill",0,"cindra")
 check(result.frames==[6] and result.resolved,"Sinal escarlate uses Cindra's protective posture and preserves team shields and empowerment")
 result=await present(app,"ultimate",1,"cindra")
 check(result.frames==[8,9,10,11,12,13,14,15,0] and result.resolved and result.fighter.artwork.flip_h,"Constelação ardente uses its own mirrored skyward-draw supreme storyboard and still resolves once")
 check(result.sheets==["res://assets/poses/cindra-supreme-renascimento-v1.png","res://assets/poses/cindra-renascimento-v1.png"],"Cindra's supreme renders its own sheet and then returns to the preserved base drawing")
 check(not result.launch.is_empty() and result.launch.offset.x < -20 and result.launch.offset.y < -40,"The mirrored skyward volley launches above the torso from the lifted bow rather than its old horizontal release")
 result=await present(app,"guard",1,"cindra")
 check(result.frames==[6] and result.resolved,"Cindra guards with the crouching bow posture instead of drawing a shot")
 var cindra=result.fighter;var dead=app.combat.unit(app.state,"1-cindra").duplicate(true);dead.hp=0
 cindra.refresh(dead,false,false,false);cindra.reset_pose()
 check(cindra.pose_index==7 and cindra.visual_root.rotation==0,"Cindra's defeated snapshot and cancellation preserve the authored kneeling drawing")
 dead.hp=dead.maxHp;cindra.refresh(dead,false,false,false)
 check(cindra.pose_index==-1 and cindra.artwork.texture==cindra.resting_art,"A living Cindra snapshot restores her original idle art")
 cindra=await prepare(app,"ultimate",0,"cindra");expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id)
 app.execute_button.pressed.emit();await create_timer(.2).timeout;app.skip_button.pressed.emit();await create_timer(1.1).timeout
 check(app.state==expected and not app.busy and cindra.artwork.texture==cindra.resting_art,"Skipping Cindra's draw cancels its frame tween and commits the area action once")
 await prepare(app,"basic",1,"cindra");app.combat.unit(app.state,"0-cindra").hp=1;app._select_target("0-cindra")
 expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id);app.execute_button.pressed.emit();deadline=Time.get_ticks_msec()+6000
 while app.busy and Time.get_ticks_msec()<deadline:await process_frame
 corpse=app.fighters["0-cindra"]
 check(not app.busy and app.state==expected and corpse.dead and corpse.pose_index==7,"Cindra's real fatal hit reaches her kneeling pose with the expected battle result")
 app.action_buttons.guard.pressed.emit();app.execute_button.pressed.emit();await process_frame
 check(corpse.dead and corpse.pose_index==7,"A following action does not lift the defeated archer")
 app.skip_button.pressed.emit();app._set_reduced(true);result=await present(app,"ultimate",0,"cindra")
 check(result.resolved and result.frames.is_empty(),"Reduced motion keeps Cindra's supreme resolution while skipping her body frames")
 app._set_reduced(false)
 for profile in PROFILES:
  if not selected_heroes.is_empty() and profile.id not in selected_heroes:continue
  var hero_id: String=profile.id
  result=await present(app,"basic",0,hero_id)
  check(result.frames==[1,2,3,4,5,0] and result.resolved,"%s's actual attack follows its authored body sequence and resolves once"%hero_id)
  for action in ["skill","ultimate","guard"]:
   var side:=1 if action=="ultimate" else 0
   result=await present(app,action,side,hero_id)
   var storyboard=[6] if action=="guard" or action in profile.support else [1,2,3,4,5,0]
   if hero_id=="oren" and action=="ultimate":storyboard=[8,9,10,11,12,13,14,15,0]
   check(result.resolved and result.frames==storyboard and (side==0 or result.fighter.artwork.flip_h),"%s's %s follows its authored attack/protection poses, facing and engine result"%[hero_id,action])
   if hero_id=="oren" and action=="ultimate":
    check(result.sheets==["res://assets/poses/oren-supreme-renascimento-v1.png","res://assets/poses/oren-renascimento-v1.png"],"Oren's forest awakening renders its own support sheet before returning to the preserved base drawing")
  var fallen_data=app.combat.unit(app.state,"0-"+hero_id).duplicate(true);fallen_data.hp=0
  result.fighter.refresh(fallen_data,false,false,false);result.fighter.reset_pose()
  check(result.fighter.pose_index==7 and result.fighter.visual_root.rotation==0,"%s keeps its drawn kneeling defeat through snapshot and cancellation"%hero_id)
  fallen_data.hp=fallen_data.maxHp;result.fighter.refresh(fallen_data,false,false,false)
  check(result.fighter.pose_index==-1 and result.fighter.artwork.texture==result.fighter.resting_art,"%s's living snapshot returns to original idle art"%hero_id)
  fighter=await prepare(app,"ultimate",0,hero_id);expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id)
  app.execute_button.pressed.emit();await create_timer(.2).timeout;app.skip_button.pressed.emit();await create_timer(1.1).timeout
  check(app.state==expected and not app.busy and fighter.artwork.texture==fighter.resting_art,"%s's skipped supreme cannot leave an old body-frame tween running"%hero_id)
  await prepare(app,"basic",1,hero_id);app.combat.unit(app.state,"0-"+hero_id).hp=1;app._select_target("0-"+hero_id)
  expected=app.state.duplicate(true);app.combat.act(expected,app.selected_action,app.target_id);app.execute_button.pressed.emit();deadline=Time.get_ticks_msec()+6000
  while app.busy and Time.get_ticks_msec()<deadline:await process_frame
  corpse=app.fighters["0-"+hero_id]
  check(not app.busy and app.state==expected and corpse.dead and corpse.pose_index==7,"%s's actual lethal hit reaches its authored kneeling drawing"%hero_id)
  app.action_buttons.guard.pressed.emit();app.execute_button.pressed.emit();await process_frame
  check(corpse.dead and corpse.pose_index==7,"The next action preserves %s's actual defeat"%hero_id)
  app.skip_button.pressed.emit();app._set_reduced(true);result=await present(app,"ultimate",0,hero_id)
  check(result.resolved and result.frames.is_empty(),"Reduced motion keeps %s's supreme result without playing body frames"%hero_id)
  app._set_reduced(false)
 for hero_id in ["kira","vektor","axion","astra","elun","saira","veyra","sylva","vesper","auren","torv","brin","bast","ivo","noct","maura","riven","elyra","solen","zaya"]:
  if not selected_heroes.is_empty() and hero_id not in selected_heroes:continue
  result=await present(app,"basic",0,hero_id)
  check(not result.launch.is_empty() and result.launch.offset.x>35 and (hero_id!="kira" or result.launch.offset.y< -20),"%s's projectile starts at its drawn emission side (measured offset %s)"%[hero_id,result.launch.get("offset")])
  result=await present(app,"basic",1,hero_id)
  check(result.resolved and not result.launch.is_empty() and result.launch.offset.x< -35 and (hero_id!="kira" or result.launch.offset.y< -20),"%s's opposing projectile mirrors its drawn emission point (offset %s)"%[hero_id,result.launch.get("offset")])
 app.skip_button.pressed.emit();app._leave_battle();await create_timer(1.5).timeout;app.queue_free();await process_frame
 DirAccess.remove_absolute(PATH)
 print("Hero choreography: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
