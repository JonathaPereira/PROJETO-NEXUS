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
	var deadline := Time.get_ticks_msec() + 15000
	while (node.playing if node is AcceptDialog else node.busy) and Time.get_ticks_msec() < deadline: await process_frame
	if node.playing if node is AcceptDialog else node.busy:
		push_error("Rendered action did not recover")
		quit(1)

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 1 or args.size() > 2:
		push_error("Pass an output directory after --")
		quit(1)
		return
	output = args[0]
	var review_only: bool = args.size() == 2 and args[1] == "--review"
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.teams = app.catalog.default_teams.duplicate(true)
	app.mode = "training"
	app.difficulty = "normal"
	app.reduced_motion = false
	app._new_battle()
	app.display_mode = "windowed"
	app.display_resolution = Vector2i(1280,720)
	app.windowed_resolution = Vector2i(1280,720)
	app._apply_display()
	await process_frame
	var before_display: Dictionary = app.state.duplicate(true)
	var fullscreen_key := InputEventKey.new()
	fullscreen_key.keycode = KEY_F11
	fullscreen_key.pressed = true
	app._input(fullscreen_key)
	await process_frame
	await process_frame
	if root.size != Vector2i(1920,1080) or app.state != before_display:
		push_error("Fullscreen did not render Full HD or changed the battle")
		quit(1)
		return
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
				if data.side == 1:
					data.shield = 120
					data.shieldTurns = 2
		else:
			var victim: Dictionary = app.combat.unit(app.state, "1-oren")
			victim.shield = app.combat.rounded(victim.maxHp * 0.25) if case == "shield-critical" else 120
			victim.shieldTurns = 2
			if case == "shield-break": victim.statuses = [{"type": "burn", "turns": 2}]
		app._start()
		app._select_target("1-oren")
		app._select_action("basic" if case == "shield-critical" else "skill" if case == "shield-break" else "ultimate")
		var baseline: int = app.director.impact_count
		app._execute()
		await wait_hit(app.director, baseline)
		await shot("godot-" + case)
		await wait_done(app)
	app.teams = [["saira", "maura", "sylva"], ["nima", "riven", "kira"]]
	app._new_battle()
	app.state.round = 16
	app.state.order = ["0-saira", "0-maura", "0-sylva", "1-nima", "1-riven", "1-kira"]
	app.state.cursor = 0
	for unit in app.state.units:
		if unit.side == 0:
			unit.hp = 200
			unit.energy = 100
			unit.statuses = [{"type": "bleed", "turns": 2}]
	app._start()
	app._select_action("skill")
	await shot("godot-healing-preview")
	var heal_baseline: int = app.director.impact_count
	app._execute()
	await wait_hit(app.director, heal_baseline)
	await shot("godot-healing")
	await wait_done(app)
	app.teams = app.catalog.default_teams.duplicate(true)
	app._new_battle()
	await create_timer(1.2).timeout
	app._open_showcase()
	await process_frame
	await process_frame
	var gallery = app.showcase
	gallery.scenario.select(1)
	if not review_only:
		for id in gallery.HEROES:
			gallery._select_hero(id)
			await process_frame
			var baseline: int = gallery.director.impact_count
			var start_msec := Time.get_ticks_msec()
			gallery._play("skill")
			await wait_hit(gallery.director, baseline)
			await shot("godot-demo-" + id)
			await wait_done(gallery)
			print("Rendered %s in %.2fs" % [id, (Time.get_ticks_msec() - start_msec) / 1000.0])
	gallery.scenario.select(2)
	gallery._select_hero("veyra")
	gallery._play("basic")
	var deadline := Time.get_ticks_msec() + 7000
	while not gallery.report.text.contains("SANGRAMENTO") and Time.get_ticks_msec() < deadline: await process_frame
	await shot("godot-debuffs")
	await wait_done(gallery)
	gallery.hide()
	app._new_battle()
	await create_timer(1.4).timeout
	app._show_lab()
	await app.lab._simulate()
	await process_frame
	await shot("godot-balance")
	app.lab.source.select(2)
	app.lab.refresh()
	await shot("godot-balance-stress")
	app.lab.hide()
	app._begin_lesson(1)
	await process_frame
	await shot("godot-lesson")
	app._end_lesson()
	var escape_key := InputEventKey.new()
	escape_key.keycode = KEY_ESCAPE
	escape_key.pressed = true
	app._input(escape_key)
	await process_frame
	if app.display_mode != "windowed":
		push_error("Escape failed to leave fullscreen")
		quit(1)
	root.size = Vector2i(960, 540)
	await process_frame
	await shot("godot-small-window")
	app.queue_free()
	await process_frame
	await process_frame
	quit()
