extends SceneTree
const Main=preload("res://scenes/main.tscn")
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func run():
 var app=Main.instantiate();app.preferences_path="user://showcase-framing.cfg";root.add_child(app);await process_frame;await process_frame
 app.sound.enabled=false;app.voice.set_enabled(false)
 for width in [1600,1280]:
  root.size=Vector2i(width,width*9/16);app._open_showcase();await process_frame;await process_frame
  var gallery=app.showcase
  for id in ["kira","vektor"]:
   var index=gallery.HEROES.find(id);gallery.hero_picker.item_selected.emit(index);await process_frame;await process_frame
   gallery.action_buttons[0].pressed.emit()
   var top:=INF;var deadline=Time.get_ticks_msec()+6000
   while gallery.playing and Time.get_ticks_msec()<deadline:
    var art=gallery.fighters.actor.artwork
    var transform=art.get_global_transform()
    for point in [Vector2.ZERO,Vector2(art.size.x,0),art.size,Vector2(0,art.size.y)]:top=minf(top,(transform*point).y-gallery.stage.global_position.y)
    await process_frame
   check(not gallery.playing and top>=2,"%s at %d: authored attack stays inside the gallery's upper edge (minimum %.1f px)"%[id,width,top])
  gallery.hide()
 app.queue_free();await process_frame
 print("Showcase framing: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
