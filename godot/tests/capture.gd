extends SceneTree
## Optional rendered review; requires a real display and never changes saved teams.
const MainScene = preload("res://scenes/main.tscn")
var output := ""

func _initialize() -> void:
	_capture.call_deferred()

func shot(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png(output.path_join(filename + ".png")) != OK:
		push_error("Screenshot failed: " + filename)
		quit(1)

func wait_hit(director, baseline: int) -> void:
	var deadline := Time.get_ticks_msec() + 6000
	while director.impact_count <= baseline and Time.get_ticks_msec() < deadline: await process_frame
	if director.impact_count <= baseline:
		push_error("Rendered attack did not reach impact")
		quit(1)
	await create_timer(0.01).timeout

func wait_done(node) -> void:
	var deadline := Time.get_ticks_msec() + 9000
	while (node.playing if node is AcceptDialog else node.busy) and Time.get_ticks_msec() < deadline: await process_frame
	if node.playing if node is AcceptDialog else node.busy:
		push_error("Rendered action did not recover")
		quit(1)

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Pass an output directory after --")
		quit(1)
		return
	output = args[0]
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.teams = app.catalog.default_teams.duplicate(true)
	app.mode = "training"
	app.difficulty = "normal"
	app.reduced_motion = false
	app._new_battle()
	await process_frame
	await shot("godot-battle")
	app.roster_button.pressed.emit()
	await shot("godot-roster")
	app.roster_dialog.hide()
	app.mode = "local"
	app.mode_picker.select(1)
	for case in ["shield-critical", "shield-break", "area"]:
		app._new_battle()
		app.state.random = 1972
		if case == "area":
			app.combat.current(app.state).energy = 100
			for data in app.state.units:
				if data.side == 1: data.shield = 120
		else:
			app.combat.unit(app.state, "1-oren").shield = 240
		app._start()
		app._select_target("1-oren")
		app._select_action("basic" if case == "shield-critical" else "skill" if case == "shield-break" else "ultimate")
		var baseline: int = app.director.impact_count
		app._execute()
		await wait_hit(app.director, baseline)
		await shot("godot-" + case)
		await wait_done(app)
	app._new_battle()
	await create_timer(1.2).timeout
	app._open_showcase()
	await process_frame
	await process_frame
	var gallery = app.showcase
	gallery.scenario.select(1)
	for id in gallery.HEROES:
		gallery._select_hero(id)
		await process_frame
		var baseline: int = gallery.director.impact_count
		gallery._play("skill")
		await wait_hit(gallery.director, baseline)
		await shot("godot-demo-" + id)
		await wait_done(gallery)
	gallery.scenario.select(2)
	gallery._select_hero("veyra")
	gallery._play("skill")
	var deadline := Time.get_ticks_msec() + 7000
	while not gallery.report.text.contains("SANGRAMENTO") and Time.get_ticks_msec() < deadline: await process_frame
	await shot("godot-debuffs")
	await wait_done(gallery)
	gallery.hide()
	app._new_battle()
	await create_timer(1.4).timeout
	root.size = Vector2i(960, 640)
	await process_frame
	await shot("godot-small-window")
	app.queue_free()
	await process_frame
	await process_frame
	quit()
