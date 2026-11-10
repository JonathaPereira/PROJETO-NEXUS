extends SceneTree
const Main=preload("res://scenes/main.tscn")
const PATH="user://keyboard-controls-test.cfg"
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
func key(viewport,code: int,ctrl:=false,shift:=false):
 var event:=InputEventKey.new();event.keycode=code;event.pressed=true;event.ctrl_pressed=ctrl;event.shift_pressed=shift
 viewport.push_input(event,true);await process_frame
 event=event.duplicate();event.pressed=false;viewport.push_input(event,true);await process_frame
func run():
 DirAccess.remove_absolute(PATH)
 var app=Main.instantiate();app.preferences_path=PATH;root.add_child(app);await process_frame;await process_frame
 var open=button(app,"Teclado")
 check(open!=null,"The Nexus menu exposes keyboard remapping")
 if open!=null:
  open.pressed.emit();await process_frame
  check(app.keyboard_settings.visible,"The keyboard preferences open without leaving the hub")
  var panel=app.keyboard_settings
  panel.buttons.skill.pressed.emit();await key(panel,KEY_H)
  check(panel.buttons.skill.text=="H","A real captured key updates the technique control")
  panel.hide();app.mode="local";app._enter_free();app.start_button.pressed.emit();await process_frame
  await key(root,KEY_H)
  check(app.selected_action=="skill","The remapped key selects the actual technique")
  check(app.action_buttons.skill.kind_label.text.begins_with("H  ") and app.controls_note.text.contains("1/H/3/4"),"Card and footer hints use the same remapped technique key")
  await key(root,KEY_1);await key(root,KEY_2)
  check(app.selected_action=="basic","The old technique key is no longer active")
  await key(root,KEY_H,true);await key(root,KEY_H,false,true)
  check(app.selected_action=="basic","Modified shortcuts cannot issue battle commands")
  app._show_keyboard_settings();await process_frame;panel.buttons.basic.pressed.emit();await key(panel,KEY_H)
  check(panel.buttons.basic.text=="H" and panel.buttons.skill.text=="1","Binding an occupied key swaps the previous bindings")
  var bytes=FileAccess.get_file_as_string(PATH)
  panel.buttons.ultimate.pressed.emit();await key(panel,KEY_F11);await key(panel,KEY_H,true)
  check(FileAccess.get_file_as_string(PATH)==bytes and panel.capture_action=="ultimate","Reserved and modified keys leave the persisted map intact")
  await key(panel,KEY_ESCAPE)
  check(panel.visible and panel.capture_action.is_empty() and panel.buttons.ultimate.text=="3","Escape cancels capture without closing or changing the binding")
  panel.buttons.execute.pressed.emit();await key(panel,KEY_J)
  panel.buttons.target_next.pressed.emit();await key(panel,KEY_L)
  panel.buttons.auto.pressed.emit();await key(panel,KEY_O)
  panel.buttons.skip.pressed.emit();await key(panel,KEY_K)
  panel.hide();await process_frame
  var previous=app.target_id;await key(root,KEY_L)
  check(app.target_id!=previous,"The remapped target command selects another legal target")
  app.action_buttons.basic.grab_focus();await key(root,KEY_J)
  check(app.busy,"The remapped confirmation starts the real action from battle focus")
  await key(root,KEY_K)
  check(not app.busy and app.state.turns==1,"The remapped skip finishes exactly the current action")
  app._show_keyboard_settings();await process_frame;await key(panel,KEY_O)
  check(not app.auto_play,"A settings window blocks remapped battle shortcuts")
  panel.hide();await key(root,KEY_O);check(app.auto_play,"The remapped automatic control works after closing settings")
  await key(root,KEY_O)
  app._leave_battle();await create_timer(1.5).timeout;app.queue_free();await process_frame
  app=Main.instantiate();app.preferences_path=PATH;root.add_child(app);await process_frame;await process_frame
  check(app.keyboard.key_name("basic")=="H" and app.keyboard.key_name("skill")=="1" and app.keyboard.key_name("execute")=="J","A fresh game restores the saved conflict swap and commands")
  var snapshot=app.keyboard.to_data();snapshot.skill=KEY_ESCAPE
  check(not app.keyboard.load_data(snapshot) and app.keyboard.key_name("skill")=="1","An invalid saved binding is rejected atomically")
  snapshot=app.keyboard.to_data();snapshot.skill=snapshot.basic
  check(not app.keyboard.load_data(snapshot) and app.keyboard.key_name("skill")=="1","Duplicate saved bindings cannot replace a valid map")
  app._show_keyboard_settings();await process_frame;button(app,"Restaurar teclado").pressed.emit();app.keyboard_settings.hide()
  check(app.keyboard.key_name("basic")=="1" and app.keyboard.key_name("skill")=="2" and app.keyboard.key_name("execute")=="Enter","Reset restores the documented defaults")
  app.mode="local";app._enter_free();app.start_button.pressed.emit();app.execute_button.grab_focus();await key(root,KEY_KP_ENTER)
  check(app.busy,"The numeric keypad Enter remains a default confirmation alias")
  await key(root,KEY_SPACE)
  check(not app.busy and app.state.turns==1,"The default Space shortcut finishes the active local animation once")
  app.execute_button.pressed.emit();var lobby_state=app.state.duplicate(true);app.pvp_active=true;await key(root,KEY_A);await key(root,KEY_SPACE)
  check(not app.auto_play and app.busy and app.state==lobby_state,"Actual local automation and skip shortcuts cannot advance an in-flight PvP presentation")
  app.pvp_active=false;await key(root,KEY_SPACE);app._leave_battle()
  await create_timer(1.5).timeout
 app.queue_free();await process_frame
 var legacy:=ConfigFile.new();legacy.set_value("audio","enabled",false);legacy.set_value("game","reduced_motion",true);legacy.set_value("game","mode","local");legacy.save(PATH)
 app=Main.instantiate();app.preferences_path=PATH;root.add_child(app);await process_frame;await process_frame
 check(app.keyboard.key_name("skill")=="2" and not app.audio_enabled and app.reduced_motion and app.mode=="local","Preferences predating the keyboard map preserve their settings and default commands")
 app._show_keyboard_settings();await process_frame;app.keyboard_settings.buttons.skill.pressed.emit();await key(app.keyboard_settings,KEY_H)
 legacy.load(PATH)
 check(not legacy.get_value("audio","enabled") and legacy.get_value("game","reduced_motion") and legacy.get_value("game","mode")=="local","Saving a binding preserves audio, motion and free battle preferences")
 app.keyboard_settings.hide();app.queue_free();await process_frame
 legacy.set_value("keyboard","bindings",{"skill":KEY_H});legacy.save(PATH)
 var bad_bytes=FileAccess.get_file_as_string(PATH)
 app=Main.instantiate();app.preferences_path=PATH;root.add_child(app);await process_frame;await process_frame
 check(app.keyboard.key_name("skill")=="2" and FileAccess.get_file_as_string(PATH)==bad_bytes,"An incomplete saved map falls back to defaults without rewriting its source")
 app.queue_free();await process_frame
 DirAccess.remove_absolute(PATH)
 print("Keyboard controls: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
