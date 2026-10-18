extends SceneTree
const Combat = preload("res://scripts/combat.gd")
const MainScene = preload("res://scenes/main.tscn")
var checks := 0
var failures: Array = []

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func wait_idle(app: Node, turns: int, timeout := 5.0) -> void:
	var deadline := Time.get_ticks_msec() + int(timeout * 1000)
	while (app.busy or app.ai_pending or app.state.turns < turns) and Time.get_ticks_msec() < deadline:
		await process_frame
	check(not app.busy and not app.ai_pending and app.state.turns >= turns, "Action and AI finished within timeout")

func click(button: Control) -> void:
	var viewport := button.get_viewport()
	var at := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	viewport.push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.position = at
	event.global_position = at
	event.pressed = true
	viewport.push_input(event, true)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	event.button_mask = 0
	viewport.push_input(event, true)
	await process_frame

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Use npm run test:godot to supply fixtures and output paths.")
		quit(1)
		return
	var fixtures: Array = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var results: Array = []
	var combat = Combat.new()
	for fixture in fixtures:
		var state := combat.new_battle(fixture.teams[0], fixture.teams[1], fixture.difficulty, int(fixture.seed))
		var initial := state.duplicate(true)
		for data in state.units:
			data.merge(fixture.patch.get(data.id, {}).duplicate(true), true)
		var commands: Array = []
		for command in fixture.commands:
			var choice := combat.choose_ai(state)
			var result := combat.act(state, command.actionId, command.targetId)
			commands.append({"choice": choice, "result": result})
		results.append({"initial": initial, "commands": commands, "final": state})
	var state := combat.new_battle(combat.catalog.default_teams[0], combat.catalog.default_teams[1])
	var before := state.duplicate(true)
	check(combat.act(state, "ultimate", "1-vesper").has("error"), "Unavailable ultimate rejected")
	check(state == before, "Invalid action cannot mutate state")
	check(combat.act(state, "basic", "0-veyra").has("error"), "Enemy attack cannot target ally")
	check(state == before, "Invalid target cannot mutate state")
	check(combat.new_battle(["veyra", "veyra", "astra"], combat.catalog.default_teams[1]).has("error"), "Duplicate team rejected")
	check(combat.new_battle(["unknown", "veyra", "astra"], combat.catalog.default_teams[1]).has("error"), "Unknown hero rejected")
	check(combat.new_battle(combat.catalog.default_teams[0], combat.catalog.default_teams[1], "invalid").has("error"), "Unknown difficulty rejected")
	for affinity in combat.catalog.classes:
		check(combat.advantage(affinity.id, affinity.strongAgainst) == 1.25, "Forward affinity edge")
		check(combat.advantage(affinity.id, affinity.weakAgainst) == 0.85, "Reverse affinity edge")
	var before_ui := checks
	await _ui()
	if not failures.is_empty():
		quit(1)
		return
	var output := FileAccess.open(args[1], FileAccess.WRITE)
	output.store_string(JSON.stringify({"cases": results, "checks": checks, "uiChecks": checks - before_ui}))
	output.close()
	print("Godot native validation complete: %d checks." % checks)
	quit(0)

func _ui() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	check(app.fighters.size() == 6, "Six illustrated fighters")
	for fighter in app.fighters.values():
		check(fighter.health.size.y == 11 and fighter.energy.size.y == 5, "Health and energy bars do not overlap the stats")
	check(app.sound.cues.size() == 7 and app.sound.cues[0].data.size() > 0, "Synthesized audio cues loaded")
	app.roster_button.pressed.emit()
	check(app.hero_grid.get_child_count() == 24, "Roster contains 24 heroes")
	app.hero_grid.get_node("veyra").pressed.emit()
	check(app.roster_dialog.get_ok_button().disabled, "Incomplete team cannot be confirmed")
	app.hero_grid.get_node("sylva").pressed.emit()
	check(not app.roster_dialog.get_ok_button().disabled, "Three distinct heroes can be confirmed")
	app.hero_grid.get_node("brin").pressed.emit()
	check(app.roster_work[0].size() == 3, "Fourth hero cannot be added")
	app.roster_side.select(1)
	app.roster_side.item_selected.emit(1)
	app.hero_grid.get_node("auren").pressed.emit()
	app.hero_grid.get_node("elyra").pressed.emit()
	check("elyra" in app.roster_work[1], "Both teams can be edited")
	for index in range(1, 7):
		app.roster_filter.select(index)
		app.roster_filter.item_selected.emit(index)
		check(app.hero_grid.get_child_count() == 4, "Each class filters to four heroes")
	app.roster_dialog.hide()
	app._save_roster()
	var restored = MainScene.instantiate()
	root.add_child(restored)
	await process_frame
	check(restored.teams == app.teams and "sylva" in restored.teams[0], "Team preferences survive reopening")
	restored.queue_free()
	await process_frame
	app.teams = app.catalog.default_teams.duplicate(true)
	app.mode = "training"
	app.reduced_motion = true
	app._new_battle()
	await click(app.start_button)
	check(app.started, "Viewport pointer input can start the battle")
	check(app.action_buttons.ultimate.disabled, "Ultimate disabled until enough energy")
	app.fighters["1-vesper"].pressed.emit()
	app.execute_button.pressed.emit()
	var first_turns: int = app.state.turns
	app._execute()
	check(app.state.turns == first_turns, "Input during animation cannot act twice")
	await wait_idle(app, 2)
	check(app.combat.unit(app.state, "1-vesper").hp < app.combat.unit(app.state, "1-vesper").maxHp, "Player attack damaged selected rival")
	check(app.combat.current(app.state).heroId == "astra", "AI took a valid turn before next ally")
	check(app.roster_button.disabled, "Team edit locked while battle is running")
	app._new_battle()
	app._start()
	app._execute()
	await process_frame
	await process_frame
	app._new_battle()
	await create_timer(0.6).timeout
	check(app.state.turns == 0 and not app.started, "Restart cancels pending AI from old battle")
	app.mode = "local"
	app.difficulty = "hard"
	app._new_battle()
	check(app.combat.unit(app.state, "1-vesper").maxHp == app.catalog.hero_by_id.vesper.hp, "Local mode ignores AI difficulty scaling")
	app._start()
	var turns := 0
	while app.state.phase == "playing" and turns < 400:
		var choice: Dictionary = app.combat.choose_ai(app.state)
		app._select_action(choice.actionId)
		app._select_target(choice.targetId)
		app.execute_button.pressed.emit()
		await process_frame
		await process_frame
		turns += 1
	check(app.state.phase == "finished" and app.result_dialog.visible, "Complete local match displays a result")
	app.result_dialog.hide()
	app.result_dialog.confirmed.emit()
	check(app.state.turns == 0 and not app.started, "Replay resets actions and battle state")
	check(app.state.units.all(func(u): return u.hp == u.maxHp), "Replay restores all six heroes")
	app.reduced_motion = false
	app._start()
	app._execute()
	await process_frame
	check(app.effects.get_child_count() > 0, "Normal action creates procedural visual effects")
	await wait_idle(app, 1)
	app._execute()
	await process_frame
	app._new_battle()
	await create_timer(0.8).timeout
	check(not app.busy and app.state.turns == 0 and app.effects.get_child_count() == 0, "Restart during animation cancels stale effects and actions")
	var config := ConfigFile.new()
	config.set_value("teams", "0", ["unknown", "veyra", "veyra"])
	config.set_value("game", "mode", "local")
	config.set_value("game", "difficulty", "hard")
	config.set_value("game", "reduced_motion", "invalid")
	config.save("user://preferences.cfg")
	var malformed = MainScene.instantiate()
	root.add_child(malformed)
	await process_frame
	check(malformed.teams[0] == malformed.catalog.default_teams[0], "Invalid saved team falls back to defaults")
	check(not malformed.reduced_motion, "Malformed preference is ignored")
	check(malformed.combat.unit(malformed.state, "1-vesper").maxHp == malformed.catalog.hero_by_id.vesper.hp, "Saved local mode retains equal attributes")
	malformed.queue_free()
	app.queue_free()
	await process_frame
