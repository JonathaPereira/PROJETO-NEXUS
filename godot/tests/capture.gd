extends SceneTree
## Optional visual check with an actual graphical display, not the headless driver.
const MainScene = preload("res://scenes/main.tscn")

func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Pass an output directory after --")
		quit(1)
		return
	var error := root.get_texture().get_image().save_png(args[0].path_join("godot-battle.png"))
	if error != OK:
		push_error("Screenshot failed")
		quit(1)
		return
	app.roster_button.pressed.emit()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(args[0].path_join("godot-roster.png"))
	app.roster_dialog.hide()
	app._start()
	app._execute()
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(args[0].path_join("godot-impact.png"))
	app._new_battle()
	# Let coroutines from the captured action observe the new battle generation.
	await create_timer(1.3).timeout
	app.queue_free()
	await process_frame
	quit()
