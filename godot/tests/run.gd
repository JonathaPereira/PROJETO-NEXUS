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
		check(fighter.health.size.y == 8 and fighter.energy.size.y == 4, "Health and energy bars do not overlap the stats")
	await _layout(app)
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
	app.action_buttons.ultimate.pressed.emit()
	check(app.selected_action == "ultimate" and not app.action_buttons.ultimate.available, "Unavailable ultimate can be inspected")
	check(app.execute_button.disabled and app.description.text.contains("Faltam"), "Insufficient energy is explained and blocks execution")
	app._select_action("basic")
	app.fighters["1-vesper"].pressed.emit()
	app.execute_button.pressed.emit()
	var first_turns: int = app.state.turns
	app._execute()
	check(app.state.turns == first_turns, "Input during animation cannot act twice")
	await wait_idle(app, 2)
	check(app.combat.unit(app.state, "1-vesper").hp < app.combat.unit(app.state, "1-vesper").maxHp, "Player attack damaged selected rival")
	check(app.combat.current(app.state).heroId == "astra", "AI took a valid turn before next ally")
	app._select_action("guard")
	app.action_buttons.guard.grab_focus()
	var confirm := InputEventKey.new()
	confirm.keycode = KEY_ENTER
	confirm.pressed = true
	root.push_input(confirm, true)
	await wait_idle(app, 3)
	check(app.combat.unit(app.state, "0-astra").energy == 65, "Enter confirms the action even while its skill card has focus")
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
	check(app.fighters["0-veyra"].posing, "Normal action starts an anticipation pose")
	check(app.state.turns == 0, "Turn state does not advance before impact and recovery")
	await create_timer(0.22).timeout
	check(app.effects.get_child_count() > 0, "Normal action creates procedural visual effects")
	check(app.fighters["1-vesper"].health.value == app.combat.unit(app.state, "1-vesper").hp, "Health does not change during anticipation")
	await create_timer(0.2).timeout
	check(app.fighters["1-vesper"].health.value < app.combat.unit(app.state, "1-vesper").hp and app.state.turns == 0, "Health updates at impact while the same actor is presented until recovery")
	app._set_reduced(true)
	check(app.fighters["1-vesper"].health.value < app.combat.unit(app.state, "1-vesper").hp, "Changing animation preference during impact cannot restore old health")
	app._set_reduced(false)
	await wait_idle(app, 1)
	app._execute()
	await process_frame
	app._new_battle()
	await create_timer(0.8).timeout
	check(not app.busy and app.state.turns == 0 and app.effects.get_child_count() == 0, "Restart during animation cancels stale effects and actions")
	await _gallery(app)
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

func _layout(app) -> void:
	var original := root.size
	for dimensions in [Vector2i(960, 640), Vector2i(1280, 800), Vector2i(1600, 1000), Vector2i(1874, 1048)]:
		root.size = dimensions
		await process_frame
		await process_frame
		var bounds: Rect2 = app.field.get_global_rect()
		var plates: Array[Rect2] = []
		for data in app.state.units:
			var fighter = app.fighters[data.id]
			var sample: Dictionary = data.duplicate(true)
			sample.shield = 300
			sample.statuses = ["burn", "regen", "weaken", "expose"].map(func(type): return {"type": type, "turns": 2})
			fighter.refresh(sample, false, false, false)
			var rect: Rect2 = fighter.plate.get_global_rect()
			check(bounds.encloses(rect), "Status nameplate stays inside arena at %s" % dimensions)
			for other in plates: check(not rect.intersects(other), "Nameplates never overlap at %s" % dimensions)
			plates.append(rect)
		check(root.get_visible_rect().encloses(app.execute_button.get_global_rect()), "Confirmation stays visible at %s" % dimensions)
		check(root.get_visible_rect().encloses(app.start_button.get_global_rect()), "Start button stays visible at %s" % dimensions)
	root.size = original
	await process_frame
	await process_frame
	app._refresh()

func _gallery(app) -> void:
	app._open_showcase()
	await process_frame
	await process_frame
	var gallery = app.showcase
	var preserved: Dictionary = app.state.duplicate(true)
	check(gallery.hero_buttons.size() == 6, "Gallery exposes one representative per class")
	check(gallery.size.y <= root.get_visible_rect().size.y, "Gallery window fits the viewport instead of inflating during text wrapping")
	var content := Rect2(Vector2.ZERO, Vector2(gallery.size))
	for button in gallery.action_buttons: check(content.encloses(button.get_global_rect()), "Gallery action buttons stay visible")
	var profiles: Array = []
	for id in gallery.HEROES:
		gallery._select_hero(id)
		await process_frame
		var baseline: int = gallery.director.impact_count
		await gallery._play("skill")
		check(not gallery.playing and gallery.director.impact_count == baseline + 1, "%s technique lands once and finishes" % id)
		check(gallery.fighters.actor.visual_root.position == Vector2(93, 257), "%s recovers the home pose" % id)
		check(gallery.stage.get_global_rect().encloses(gallery.fighters.actor.plate.get_global_rect()), "%s preview nameplate stays visible inside the stage" % id)
		profiles.append(gallery.director.last_profile)
		await gallery._play("basic")
		check(not gallery.playing, "%s basic attack completes" % id)
		await gallery._play("ultimate")
		check(not gallery.playing, "%s supreme completes" % id)
	check(profiles.size() == 6 and profiles.all(func(profile): return profiles.count(profile) == 1), "All six classes have distinct choreography profiles")
	check(app.state == preserved, "The gallery does not mutate the live battle")
	gallery.reduced_motion = true
	gallery._select_hero("veyra")
	await gallery._play("skill")
	check(gallery.effects.get_child_count() == 0 and not gallery.fighters.actor.motion_enabled, "Reduced motion is honored inside the gallery")
	gallery.hide()
	await process_frame
