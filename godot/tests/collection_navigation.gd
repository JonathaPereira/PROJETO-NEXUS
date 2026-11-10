extends SceneTree
const Main=preload("res://scenes/main.tscn")
const Campaign=preload("res://scripts/campaign.gd")
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func settle():
 await process_frame;await process_frame;await process_frame
func accept():
 var event=InputEventKey.new();event.keycode=KEY_ENTER;event.physical_keycode=KEY_ENTER;event.pressed=true;Input.parse_input_event(event)
 await process_frame
 event=InputEventKey.new();event.keycode=KEY_ENTER;event.physical_keycode=KEY_ENTER;event.pressed=false;Input.parse_input_event(event)
 await settle()
func run():
 root.size=Vector2i(1280,720)
 var app=Main.instantiate();app.preferences_path="user://collection-navigation.cfg";root.add_child(app);await settle()
 app.sound.enabled=false;app.voice.set_enabled(false)
 app.campaign=Campaign.new(app.catalog,"user://collection-navigation.json");app.campaign.completed=Campaign.LEGACY_REWARDS.duplicate()
 app.hub.selected_hero="veyra";app.hub.open("equipment");await settle()
 app.hub.gear_upgrade_buttons[0].grab_focus();await settle()
 var position: int=app.hub.scroll.scroll_vertical
 await accept()
 check(app.campaign.piece("veyra",0).tier==2,"Enter on the focused workshop improvement performs the real paid upgrade")
 check(app.hub.get_viewport().gui_get_focus_owner()==app.hub.gear_upgrade_buttons[0],"A repeatable improvement keeps keyboard focus on its replacement control")
 check(absi(app.hub.scroll.scroll_vertical-position)<=2,"Rebuilding workshop values preserves the current reading position")
 await accept()
 check(app.campaign.piece("veyra",0).tier==3 and app.hub.get_viewport().gui_get_focus_owner()==app.hub.gear_variant_pickers[0],"Reaching the final tier moves focus to the specialization selector in the same card")
 var picker=app.hub.gear_variant_pickers[0];picker.select(1);picker.item_selected.emit(1)
 var funds: int=app.campaign.materials();app.hub.gear_apply_buttons[0].grab_focus();await settle();await accept()
 check(app.campaign.piece("veyra",0).variant=="channel" and app.campaign.materials()==funds,"Enter applies the previewed specialization without spending fragments")
 check(app.hub.get_viewport().gui_get_focus_owner()==app.hub.gear_variant_pickers[0],"After applying a specialization, focus returns to its enabled selector")
 var recipient=app.hub.gear_transfer_pickers[0]
 for index in range(recipient.item_count):
  if recipient.get_item_metadata(index)=="astra":recipient.select(index)
 recipient.item_selected.emit(recipient.selected);app.hub.gear_transfer_buttons[0].grab_focus();await settle()
 position=app.hub.scroll.scroll_vertical;check(position>0,"The exchange fixture exercises a genuinely scrolled workshop")
 await accept()
 check(app.campaign.piece("astra",0).variant=="channel" and app.campaign.piece("astra",0).tier==3 and app.campaign.materials()==funds,"Keyboard exchange preserves the investment and shared materials")
 check(app.hub.gear_transfer_pickers[0].get_item_metadata(app.hub.gear_transfer_pickers[0].selected)=="astra","After exchange the recipient remains the one chosen, so Enter cannot silently target another hero")
 check(app.hub.get_viewport().gui_get_focus_owner()==app.hub.gear_transfer_buttons[0],"Exchanging distinct pieces keeps focus on the same exchange control")
 check(absi(app.hub.scroll.scroll_vertical-position)<=2,"Exchange refresh keeps the scrolled card in place")
 var saved_path: String=app.campaign.store_path
 var saved_bytes=FileAccess.get_file_as_string(saved_path)
 var gear_before=app.campaign.gear.duplicate(true);var gems_before=app.campaign.equipped.duplicate(true)
 app.campaign.store_path="user://collection-navigation-no-directory/progress.json"
 picker=app.hub.gear_variant_pickers[0];picker.select(1);picker.item_selected.emit(1)
 app.hub.gear_apply_buttons[0].grab_focus();await settle();await accept()
 check(app.campaign.gear==gear_before and app.campaign.equipped==gems_before and app.campaign.materials()==funds and FileAccess.get_file_as_string(saved_path)==saved_bytes,"Failed saving rolls back the real specialization and preserves the healthy file, gems and funds")
 check(app.hub.gear_variant_pickers[0].get_item_metadata(app.hub.gear_variant_pickers[0].selected)=="channel" and not app.hub.gear_apply_buttons[0].disabled,"Failed saving preserves the requested specialization preview for an explicit retry")
 check(app.hub.get_viewport().gui_get_focus_owner()==app.hub.gear_apply_buttons[0] and not app.hub.footer.text.is_empty(),"Failed saving retains the retry action and exposes the existing error message")
 app.campaign.store_path=saved_path
 await accept()
 check(app.campaign.piece("veyra",0).variant=="channel" and app.hub.get_viewport().gui_get_focus_owner()==app.hub.gear_variant_pickers[0],"After storage is available, the same focused retry applies exactly the preserved choice")
 check(Campaign.new(app.catalog,saved_path).gear==app.campaign.gear,"A successful keyboard retry survives reopening without duplicating equipment")
 app.campaign.mastery={"veyra":60};app.hub.open("progress");await settle()
 app.hub.training_tabs.current_tab=2;await settle()
 var training=app.hub.training_pickers.basic;training.select(1);training.item_selected.emit(1)
 var trained_id: String=training.get_item_metadata(1)
 app.hub.training_apply_buttons.basic.grab_focus();await settle();position=app.hub.scroll.scroll_vertical;await accept()
 check(app.campaign.ability_choices.get("veyra",{}).get("basic")==trained_id,"Enter applies the real unlocked attack training")
 check(app.hub.training_tabs.current_tab==2 and app.hub.get_viewport().gui_get_focus_owner()==app.hub.training_pickers.basic,"Training keeps its selected mastery tab and returns focus to the selector after applying")
 check(absi(app.hub.scroll.scroll_vertical-position)<=2,"Training refresh preserves its current reading position")
 app.campaign.store_path="user://collection-navigation-no-directory/progress.json"
 training=app.hub.training_pickers.basic;training.select(0);training.item_selected.emit(0)
 app.hub.training_apply_buttons.basic.grab_focus();await settle();await accept()
 check(app.campaign.ability_choices.veyra.basic==trained_id and app.hub.training_pickers.basic.selected==0 and not app.hub.training_apply_buttons.basic.disabled,"Failed training saving keeps the actual ability and the requested original-version preview for retry")
 check(app.hub.get_viewport().gui_get_focus_owner()==app.hub.training_apply_buttons.basic,"A failed training save keeps the enabled retry button focused")
 app.campaign.store_path=saved_path
 var team_before=app.campaign.team.duplicate();var free_before=app.teams.duplicate(true)
 for screen in ["equipment","progress","gems"]:
  app.hub.selected_hero="veyra";app.hub.open(screen);await settle()
  app.hub.hero_picker.grab_focus()
  var selected_index: int=app.catalog.heroes.find(app.catalog.hero_by_id.astra)
  app.hub.hero_picker.select(selected_index);app.hub.hero_picker.item_selected.emit(selected_index);await settle()
  check(app.hub.selected_hero=="astra" and app.hub.get_viewport().gui_get_focus_owner()==app.hub.hero_picker,"Changing the inspected hero keeps the replacement selector focused in "+screen)
 app.hub.open("heroes");await settle();app.hub.hero_buttons.bast.grab_focus();await accept()
 check(app.hub.selected_hero=="bast" and app.hub.get_viewport().gui_get_focus_owner()==app.hub.hero_buttons.bast,"Enter on a roster portrait keeps focus on the same hero after rebuilding details")
 check(app.campaign.team==team_before and app.teams==free_before,"Inspecting heroes preserves the chosen campaign and free trios")
 app.hub.open("equipment");await settle();app.hub.gear_upgrade_buttons[1].pressed.emit()
 app.hub.open("story");app.hub.nav_buttons.story.grab_focus();await settle()
 check(app.hub.page=="story" and app.hub.get_viewport().gui_get_focus_owner()==app.hub.nav_buttons.story,"A pending collection refresh cannot steal focus after navigation to another page")
 app.hub.open("equipment");await settle();app.hub.gear_upgrade_buttons[2].pressed.emit()
 app.hub.hero_picker.grab_focus();await settle()
 check(app.hub.get_viewport().gui_get_focus_owner()==app.hub.hero_picker,"A pending refresh respects a newer explicit focus choice on the same page")
 for width in [1280,1600]:
  root.size=Vector2i(width,width*9/16)
  app.hub.selected_hero="bast" if width==1280 else "brin"
  app.hub.open("equipment");await settle()
  if width==1600:
   app.hub.gear_upgrade_buttons[1].grab_focus();await accept()
  app.hub.gear_upgrade_buttons[1].grab_focus();await accept()
  var focused=app.hub.get_viewport().gui_get_focus_owner()
  check(focused==app.hub.gear_variant_pickers[1] and app.hub.scroll.get_global_rect().encloses(focused.get_global_rect()),"The post-upgrade fallback stays visible and keyboard-reachable at width %d"%width)
 app.voice.stop_line();app.sound.enabled=false;app.queue_free();await settle();await create_timer(.2).timeout
 print("Collection navigation: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
