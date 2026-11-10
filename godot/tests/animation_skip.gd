extends SceneTree
const Main=preload("res://scenes/main.tscn")
const Campaign=preload("res://scripts/campaign.gd")
const PATH="user://animation-skip-campaign.json"
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func button(app,text: String):
 for node in app.find_children("*","Button",true,false):
  if node.text==text:return node
 return null
func run():
 for suffix in ["",".tmp",".bak",".bak.tmp"]:DirAccess.remove_absolute(PATH+suffix)
 var app=Main.instantiate();root.add_child(app);await process_frame;await process_frame
 app.mode="local";app.audio_enabled=false;app.sound.enabled=false;app.voice.set_enabled(false);app._enter_free();await process_frame;await process_frame
 app.start_button.pressed.emit()
 var expected=app.state.duplicate(true)
 var receipt=app.combat.act(expected,app.selected_action,app.target_id)
 check(not receipt.has("error"),"The reference action is legal")
 app.execute_button.pressed.emit();await process_frame
 var skip=button(app,"Pular animação")
 check(skip!=null and skip.is_visible_in_tree() and not skip.disabled,"A playing action exposes an enabled skip-animation control")
 if skip!=null:
  skip.pressed.emit();await process_frame
  check(not app.busy and app.state==expected,"Skipping presents exactly the already calculated action result")
  var committed=app.state.duplicate(true)
  skip.pressed.emit();await create_timer(0.8).timeout
  check(app.state==committed,"Repeated skip and old presentation timers cannot resolve another turn")
 if skip!=null:
  app._new_battle();app.start_button.pressed.emit()
  var next_id=app.state.order[(app.state.cursor+1)%app.state.order.size()]
  var next=app.combat.unit(app.state,next_id);next.statuses=[{"type":"burn","turns":2}]
  expected=app.state.duplicate(true);receipt=app.combat.act(expected,app.selected_action,app.target_id)
  check(not receipt.turnEvents.is_empty(),"The periodic-effect fixture actually resolves a next-turn event")
  app.execute_button.pressed.emit();skip.pressed.emit();await process_frame
  check(app.state==expected,"Skipping retains damage and conditions from the next actor's start of turn")
  app._new_battle();app.start_button.pressed.emit()
  expected=app.state.duplicate(true);receipt=app.combat.act(expected,app.selected_action,app.target_id)
  var hits=app.director.impact_count;app.execute_button.pressed.emit()
  var deadline=Time.get_ticks_msec()+2000
  while app.director.impact_count==hits and Time.get_ticks_msec()<deadline:await process_frame
  check(app.director.impact_count==hits+1 and app.busy,"The recovery fixture reaches the actual impact before skipping")
  skip.pressed.emit();await process_frame
  check(app.state==expected,"Skipping recovery cannot apply the visible impact twice")
  app._new_battle();app.start_button.pressed.emit()
  next_id=app.state.order[(app.state.cursor+1)%app.state.order.size()];next=app.combat.unit(app.state,next_id);next.statuses=[{"type":"burn","turns":2}]
  expected=app.state.duplicate(true);receipt=app.combat.act(expected,app.selected_action,app.target_id)
  app.execute_button.pressed.emit();deadline=Time.get_ticks_msec()+6000
  while not app.phase_label.text.contains("efeitos de turno") and Time.get_ticks_msec()<deadline:await process_frame
  check(app.busy and app.phase_label.text.contains("efeitos de turno"),"The tick fixture reaches its real periodic-effect presentation")
  skip.pressed.emit();await create_timer(1.1).timeout
  check(app.state==expected and not app.busy,"Skipping during a periodic effect commits all ticks exactly once")
  app._new_battle();app.start_button.pressed.emit();app.execute_button.pressed.emit();await process_frame
  app._new_battle();var fresh=app.state.duplicate(true);skip.pressed.emit();await create_timer(0.8).timeout
  check(app.state==fresh and not app.busy,"A stale skip after restarting cannot commit the abandoned action")
  app.start_button.pressed.emit();app.execute_button.pressed.emit();await process_frame
  var authoritative=app.state.duplicate(true);app.pvp_active=true;skip.pressed.emit()
  check(app.busy and app.state==authoritative,"Local skip cannot advance an online presentation or send an action")
  app.pvp_active=false;skip.pressed.emit();await process_frame
  app.mode="training";app._new_battle()
  var allies=app.state.units.filter(func(unit):return unit.side==0);var foes=app.state.units.filter(func(unit):return unit.side==1)
  app.state.order=[allies[0].id,foes[0].id,allies[1].id,allies[2].id,foes[1].id,foes[2].id];app.state.cursor=0
  app.start_button.pressed.emit();app.execute_button.pressed.emit();skip.pressed.emit();await create_timer(0.6).timeout
  check(app.busy and app.state.turns==1,"The opposing AI still starts its scheduled action after a player skip")
  skip.pressed.emit();await process_frame
  check(not app.busy and app.state.turns==2,"Skipping an AI animation also resolves exactly its current action")
  app.mode="local"
  app._leave_battle();app.campaign=Campaign.new(app.catalog,PATH);app.hub.open("story");app._begin_mission(0);await process_frame;await process_frame
  var actor_id=app.state.units.filter(func(unit):return unit.side==0)[0].id
  app.state.order.erase(actor_id);app.state.order.push_front(actor_id);app.state.cursor=0
  var enemies=app.state.units.filter(func(unit):return unit.side==1)
  for enemy in enemies:enemy.hp=0
  enemies[0].hp=1
  var gem=app.campaign.missions[0].reward
  var stock=app.campaign.copies(gem)
  app.start_button.pressed.emit();app.execute_button.pressed.emit();skip.pressed.emit();await process_frame
  check(app.state.phase=="finished" and app.state.winner==0 and app.result_dialog.visible,"A skipped final strike opens the actual campaign victory result")
  check(app.campaign.completed.size()==1 and app.campaign.copies(gem)==stock+1,"The skipped final strike grants its first mission reward exactly once")
  check(app.campaign.team.all(func(hero):return app.campaign.mastery.get(hero,0)==10),"All three starting heroes receive the real victory mastery")
  var saved=FileAccess.get_file_as_string(PATH)
  skip.pressed.emit();await create_timer(0.8).timeout
  check(FileAccess.get_file_as_string(PATH)==saved and app.campaign.copies(gem)==stock+1,"Old final-strike callbacks and repeated skip preserve the saved reward bytes")
 app._leave_battle();await create_timer(0.5).timeout;app.queue_free();await process_frame
 for suffix in ["",".tmp",".bak",".bak.tmp"]:DirAccess.remove_absolute(PATH+suffix)
 print("Animation skip: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
