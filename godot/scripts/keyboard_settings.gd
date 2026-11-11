extends AcceptDialog
var app
var capture_action:=""
var buttons:={}
var notice: Label

func _ready() -> void:
	title="Teclado"
	min_size=Vector2i(470,480)
	var column:=VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	add_child(column)
	var explanation: Label=app._label("Escolha uma ação e pressione a nova tecla. Conflitos trocam as teclas. Esc cancela a captura; Tab e F11 continuam reservados.",14,app.MUTED)
	explanation.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	explanation.custom_minimum_size.x=440
	column.add_child(explanation)
	for action in app.keyboard.DEFAULTS:
		var row:=HBoxContainer.new()
		column.add_child(row)
		var label: Label=app._label(app.keyboard.TITLES[action],14)
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var button: Button=app._button("",_capture.bind(action))
		button.name="Bind_"+action
		button.custom_minimum_size.x=150
		row.add_child(button)
		buttons[action]=button
	notice=app._label("",12,app.MUTED)
	notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	notice.custom_minimum_size=Vector2(440,38)
	column.add_child(notice)
	column.add_child(app._button("Restaurar teclado",func():
		capture_action=""
		app.keyboard.reset()
		_changed("Padrões restaurados.")))
	visibility_changed.connect(func():
		capture_action=""
		_refresh())
	_refresh()

func _capture(action: String) -> void:
	capture_action=action
	notice.text="Pressione uma letra, número, seta horizontal, Enter ou Espaço, sem modificadores."
	_refresh()

func _refresh() -> void:
	for action in buttons:
		buttons[action].text="Pressione a tecla…" if action==capture_action else app.keyboard.key_name(action)
		buttons[action].accessibility_name=app.keyboard.TITLES[action]+": "+buttons[action].text

func _changed(message: String) -> void:
	app._save_preferences()
	app._refresh()
	notice.text=message
	_refresh()

func _input(event: InputEvent) -> void:
	if not visible or capture_action.is_empty() or not event is InputEventKey or not event.pressed:return
	get_viewport().set_input_as_handled()
	if event.keycode==KEY_ESCAPE:
		capture_action=""
		notice.text="Captura cancelada."
		_refresh()
		return
	if not app.keyboard.bind(capture_action,app.keyboard.key_from_event(event)):
		notice.text="Tecla reservada ou combinação inválida. Escolha outra tecla, sem modificadores."
		return
	capture_action=""
	_changed("Teclado atualizado. As dicas do combate acompanham sua escolha.")
