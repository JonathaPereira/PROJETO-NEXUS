extends RefCounted
## One map supplies combat commands, labels and the saved preference.
const DEFAULTS={"basic":KEY_1,"skill":KEY_2,"ultimate":KEY_3,"guard":KEY_4,"target_previous":KEY_LEFT,"target_next":KEY_RIGHT,"execute":KEY_ENTER,"auto":KEY_A,"skip":KEY_SPACE}
const TITLES={"basic":"Ataque básico","skill":"Técnica","ultimate":"Supremo","guard":"Defesa","target_previous":"Alvo anterior","target_next":"Próximo alvo","execute":"Usar ação","auto":"Automático","skip":"Pular animação local"}
var bindings=DEFAULTS.duplicate()

func reset() -> void:
	bindings=DEFAULTS.duplicate()

func to_data() -> Dictionary:
	return bindings.duplicate()

func load_data(data: Variant) -> bool:
	if not data is Dictionary or data.size()!=DEFAULTS.size():return false
	var used=[]
	for action in DEFAULTS:
		var code: Variant=data.get(action)
		if not (code is int or code is float) or not is_finite(float(code)) or code!=floor(float(code)) or not valid_key(int(code)) or code in used:return false
		used.append(code)
	bindings={}
	for action in DEFAULTS:bindings[action]=int(data[action])
	return true

static func valid_key(code: int) -> bool:
	return code in [KEY_SPACE,KEY_ENTER,KEY_LEFT,KEY_RIGHT] or code>=KEY_A and code<=KEY_Z or code>=KEY_0 and code<=KEY_9

func key_name(action: String) -> String:
	var code: int=bindings[action]
	return {KEY_SPACE:"Espaço",KEY_ENTER:"Enter",KEY_LEFT:"←",KEY_RIGHT:"→"}.get(code,OS.get_keycode_string(code))

func bind(action: String,code: int) -> bool:
	if not DEFAULTS.has(action) or not valid_key(code):return false
	var previous: int=bindings[action]
	var conflict=bindings.find_key(code)
	if conflict!=null:bindings[conflict]=previous
	bindings[action]=code
	return true

static func key_from_event(event: InputEventKey) -> int:
	if not event.pressed or event.echo or event.ctrl_pressed or event.alt_pressed or event.meta_pressed or event.shift_pressed:return 0
	return KEY_ENTER if event.keycode==KEY_KP_ENTER else event.keycode

func action_for(event: InputEventKey) -> String:
	var action=bindings.find_key(key_from_event(event))
	return action if action!=null else ""
