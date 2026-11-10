extends SceneTree
const Main=preload("res://scenes/main.tscn")
const Lessons=preload("res://scripts/lessons.gd")
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func perform(app,actor_id: String,action: String,target: String):
 var own=app.state.units.filter(func(unit):return unit.side==0).map(func(unit):return unit.id)
 var foes=app.state.units.filter(func(unit):return unit.side==1).map(func(unit):return unit.id)
 app.state.order=[actor_id]+own.filter(func(id):return id!=actor_id)+foes;app.state.cursor=0
 var actor=app.combat.unit(app.state,actor_id);actor.energy=100;actor.cooldowns.skill=0
 await process_frame;await process_frame
 if not app.started:app.start_button.pressed.emit()
 var turns: int=app.state.turns
 await app._play_turn(action,target)
 check(app.state.turns==turns+1,"The guided %s is a real resolved engine action"%action)
func lesson_reachable(engine,index: int,seed: int) -> bool:
 var state=engine.new_battle(Lessons.TEAMS[index][0],Lessons.TEAMS[index][1],"easy",seed);Lessons.prepare(state,index);var progress={}
 while state.phase=="playing" and state.turns<40 and not Lessons.complete(index,progress):
  var actor=engine.current(state);var choice=engine.choose_ai(state)
  if actor.side==0:
   var action:="guard";var target: String=actor.id
   if index==3 and actor.heroId in ["auren","elyra"] and engine.can_use(actor,"skill"):action="skill";target="0-elyra"
   if index==4:
    action="skill" if actor.heroId in ["ivo","bast"] and engine.can_use(actor,"skill") else "basic"
    target="0-ivo" if actor.heroId=="bast" and action=="skill" else "1-noct"
   if engine.legal_targets(state,actor,engine.get_action(actor,action)).any(func(unit):return unit.id==target):choice={"actionId":action,"targetId":target}
  var side: int=actor.side;var result=engine.act(state,choice.actionId,choice.targetId)
  if result.has("error"):return false
  Lessons.observe(progress,result,side)
 return Lessons.complete(index,progress)
func run():
 root.size=Vector2i(1280,720)
 var app=Main.instantiate();app.preferences_path="user://advanced-lessons.cfg";root.add_child(app);await process_frame;await process_frame
 app.sound.enabled=false;app.voice.set_enabled(false);app._enter_free();await process_frame
 app.campaign.store_path="user://advanced-lessons-campaign.json";check(app.campaign.save_progress(),"The campaign preservation fixture saves its real profile")
 var profile_before=FileAccess.get_file_as_string(app.campaign.store_path)
 var teams_before=app.teams.duplicate(true);var mode_before=app.mode;var difficulty_before=app.difficulty
 var lab_existed=FileAccess.file_exists(app.Lab.STORE)
 app._show_lessons();await process_frame;await process_frame
 var dialogs=app.get_children().filter(func(child):return child is AcceptDialog and child.title.begins_with("Aprender"))
 var menu=dialogs[-1];var buttons=menu.find_children("*","Button",true,false).filter(func(button):return button.text.contains(" · "))
 check(buttons.size()==5,"Aprender exposes five guided battles including the restored cast mechanics")
 if buttons.size()==5:
  buttons[3].pressed.emit();await process_frame;await process_frame
  var ally=app.combat.unit(app.state,"0-elyra")
  check(app.tutorial_index==3 and ally.statuses.any(func(status):return status.type=="bleed") and ally.statuses.any(func(status):return status.type=="expose"),"The fourth battle actually prepares the visible bleeding/exposed ally for purification")
  app._set_reduced(true)
  await perform(app,"0-auren","skill","0-elyra")
  check(app.tutorial_progress.get("cleanse",false) and app.tutorial_progress.get("elementalWard",false),"Auren's actual purification/ward receipt advances both teaching objectives")
  await perform(app,"0-auren","guard","0-auren")
  check(app.Lessons.complete(3,app.tutorial_progress) and app.step_label.text.contains("Concluído"),"The fourth lesson completes from real actions and exposes its contextual conclusion")
  app._begin_lesson(4);await process_frame;await process_frame
  var marked=app.combat.unit(app.state,"1-noct")
  check(marked.statuses.any(func(status):return status.type=="darkmark" and status.owner=="0-maura"),"The fifth lesson visibly prepares Maura's real source mark")
  await perform(app,"0-ivo","skill","1-noct")
  check(app.tutorial_progress.get("spread",false),"Ivo's real transmitted status advances the spread objective")
  await perform(app,"0-bast","skill","0-ivo")
  check(app.tutorial_progress.get("cover",false) and app.Lessons.complete(4,app.tutorial_progress),"Bast's real chosen ally protection completes the interception lesson")
  for unit in app.state.units:
   if unit.side==1:unit.hp=1
  await perform(app,"0-ivo","ultimate","1-noct")
  check(app.state.phase=="finished" and app.result_dialog.visible,"A guided victory actually reaches its result dialog")
  check(FileAccess.file_exists(app.Lab.STORE)==lab_existed and FileAccess.get_file_as_string(app.campaign.store_path)==profile_before,"Guided victory cannot write campaign progress or a free battle record")
  app.result_dialog.hide();app._begin_lesson(3);await process_frame;await process_frame
  await perform(app,"0-auren","skill","0-vektor")
  check(not app.tutorial_progress.get("cleanse",false) and app.tutorial_progress.get("elementalWard",false),"Shielding a healthy ally can teach Ward but cannot pretend to purify afflictions")
  app._begin_lesson(4);await process_frame;await process_frame
  app.combat.unit(app.state,"1-noct").statuses=[]
  await perform(app,"0-ivo","skill","1-noct")
  check(not app.tutorial_progress.get("spread",false),"An attack without an existing affliction cannot teach a nonexistent transmission")
  app._show_lessons();await process_frame;await process_frame
  var exit_menu=app.get_children().filter(func(child):return child is AcceptDialog and child.title.begins_with("Aprender"))[-1]
  var exit_buttons=exit_menu.find_children("*","Button",true,false).filter(func(button):return button.text=="Voltar ao treino livre")
  exit_buttons[0].pressed.emit();await process_frame;await process_frame
  check(app.tutorial_index==-1 and app.teams==teams_before and app.free_settings.is_empty() and app.mode==mode_before and app.difficulty==difficulty_before,"Leaving through the actual lesson menu restores free trios, mode and difficulty")
  check(FileAccess.get_file_as_string(app.campaign.store_path)==profile_before,"Browsing and leaving the teaching flow preserves the campaign profile bytes")
  for dimensions in [Vector2i(1280,720),Vector2i(1600,900)]:
   root.size=dimensions;app._show_lessons();await process_frame;await process_frame
   var picker=app.get_children().filter(func(child):return child is AcceptDialog and child.title.begins_with("Aprender"))[-1]
   var last_button=picker.find_children("*","Button",true,false).filter(func(button):return button.text=="5 · Interceptação e aflições")[0]
   last_button.grab_focus();await process_frame;await process_frame;await process_frame
   var clip=picker.find_children("*","ScrollContainer",true,false)[0]
   check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(Rect2(Vector2(picker.position),Vector2(picker.size))),"The lesson window fits %s"%str(dimensions))
   check(picker.gui_get_focus_owner()==last_button and clip.get_global_rect().encloses(last_button.get_global_rect()),"The last lesson remains reachable and visible by keyboard focus in %s"%str(dimensions))
   picker.hide();await process_frame
  var free_state=app.state.duplicate(true);app.pvp_active=true;app._begin_lesson(4)
  check(app.tutorial_index==-1 and app.state==free_state and app.teams==teams_before,"Guided lessons cannot replace an active PvP session")
  app._show_lessons();await process_frame;await process_frame
  var online_menu=app.get_children().filter(func(child):return child is AcceptDialog and child.title.begins_with("Aprender"))[-1]
  var online_buttons=online_menu.find_children("*","Button",true,false).filter(func(button):return button.text.contains(" · "))
  check(online_buttons.size()==5 and online_buttons.all(func(button):return button.disabled),"The lesson menu explains PvP unavailability through disabled choices")
  online_menu.hide();app.pvp_active=false;await process_frame

 for index in [3,4]:
  for seed in [73,211,509]:check(lesson_reachable(app.combat,index,seed),"Lesson %d objectives are reachable with natural order, initial energy and normal cooldowns (seed %d)"%[index+1,seed])
 app._leave_battle();app.queue_free();await process_frame
 print("Advanced lessons: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
