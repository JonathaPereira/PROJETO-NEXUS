extends SceneTree
const Main=preload("res://scenes/main.tscn")
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,why: String):
 checks+=1
 if not ok:failures+=1;push_error(why)
func run():
 var app=Main.instantiate();app.preferences_path="user://pose-transition-test.cfg";root.add_child(app);await process_frame;await process_frame
 app.mode="local";app.teams[0]=["kira","cindra","rhazen"];app.teams[1]=["cindra","kira","oren"];app._enter_free();await process_frame;await process_frame
 var fighter=app.fighters["0-kira"];var context={"tier":"basic","support":false}
 var travel=app.create_tween().set_parallel(true)
 fighter.animate_action_pose(travel,"travel",context,.15);fighter.set_action_pose("impact",context)
 await create_timer(.2).timeout
 check(fighter.pose_index==4,"An older travel tween cannot replace the current contact drawing")
 var recover=app.create_tween().set_parallel(true)
 fighter.animate_action_pose(recover,"recover",context,.15);fighter.reset_pose()
 await create_timer(.2).timeout
 check(fighter.pose_index==-1 and fighter.artwork.texture==fighter.resting_art,"Reset keeps original idle art after an older recovery tween finishes")
 var charge=app.create_tween().set_parallel(true)
 fighter.animate_action_pose(charge,"charge",context,.15);fighter.set_action_pose("charge",{"tier":"guard","support":true})
 await create_timer(.2).timeout
 check(fighter.pose_index==6,"A new command in the same named phase invalidates the previous command's interpolation")
 for tween in [travel,recover,charge]:tween.kill()
 var rhazen=app.fighters["0-rhazen"]
 var supreme=app.create_tween().set_parallel(true)
 rhazen.animate_action_pose(supreme,"charge",{"tier":"ultimate","support":false},.15)
 rhazen.set_action_pose("charge",{"tier":"skill","support":true})
 await create_timer(.2).timeout
 check(rhazen.pose_index==6,"A later defensive command prevents an older tier-specific supreme from replacing the guard drawing")
 var dead=app.combat.unit(app.state,"0-rhazen").duplicate(true);dead.hp=0
 rhazen.refresh(dead,false,false,false)
 rhazen.set_action_pose("charge",{"tier":"ultimate","support":false})
 check(rhazen.pose_index==7,"Tier-specific supreme drawings cannot replace a defeated snapshot's original kneeling pose")
 supreme.kill()
 for pose in [{"hero":"cindra","frame":11,"uv":Vector2(317.0/444.0,132.0/443.0)},{"hero":"kira","frame":3,"uv":Vector2(388.0/444.0,112.0/443.0)}]:
  for side in [0,1]:
   var shooter=app.fighters["%d-%s"%[side,pose.hero]]
   shooter.motion_enabled=false;shooter.set_pose(pose.frame);shooter.visual_root.rotation=.12;shooter.visual_root.scale=Vector2(.7,.7)
   var uv:Vector2=pose.uv
   if shooter.artwork.flip_h:uv.x=1.0-uv.x
   var drawn=shooter.get_parent().get_global_transform().affine_inverse()*(shooter.artwork.get_global_transform()*(shooter.artwork.size*uv))
   check(shooter.projectile_origin().distance_to(drawn)<.01,"%s's side%d emission coincides with its authored point on the actual scaled/rotated drawing, including the default scale"%[pose.hero,side])
 var oren=app.fighters["1-oren"];var support_context={"tier":"ultimate","support":true}
 oren.set_action_pose("charge",support_context,1.0)
 check(oren.pose_index==10,"Oren's friendly supreme can reach its authored gathering drawing instead of the default support hold")
 oren.set_action_pose("charge",{"tier":"ultimate","support":false},1.0)
 check(oren.pose_index==2,"An offensive request does not borrow Oren's friendly ward storyboard")
 var living_rhazen=app.combat.unit(app.state,"0-rhazen").duplicate(true);living_rhazen.hp=living_rhazen.maxHp
 rhazen.refresh(living_rhazen,false,false,false);rhazen.set_action_pose("charge",support_context,1.0)
 check(rhazen.pose_index==6,"A friendly request keeps Rhazen's support fallback instead of borrowing his offensive supreme")
 var awakening=app.create_tween().set_parallel(true)
 oren.animate_action_pose(awakening,"charge",support_context,.15)
 oren.set_action_pose("charge",{"tier":"guard","support":true});await create_timer(.2).timeout
 check(oren.pose_index==6,"A later guard command prevents the older friendly supreme from replacing its original defensive drawing")
 var fallen=app.combat.unit(app.state,"1-oren").duplicate(true);fallen.hp=0
 oren.refresh(fallen,false,false,false);oren.set_action_pose("charge",support_context)
 check(oren.pose_index==7,"A defeated Oren keeps his kneeling drawing even when a friendly supreme phase is requested")
 awakening.kill()
 app.queue_free();await process_frame
 print("Pose transitions: %d checks, %d failures."%[checks,failures]);quit(1 if failures else 0)
