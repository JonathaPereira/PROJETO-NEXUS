extends Control
## A restrained painted underlay and continuous floor light frame the hero's VFX.
const PAINT = preload("res://shaders/painted_resonance.gdshader")
const MODERN = preload("res://shaders/modern_impact.gdshader")
static var effect_texture: Texture2D
var origin := Vector2.ZERO
var destinations: Array[Vector2] = []
var tint := Color.WHITE
var affinity := "igneo"
var signature := ""
var title := ""
var support := false
var action_kind := "damage"
var icon: Texture2D
var stage := "charge"
var elapsed := 0.0
var stage_time := 0.0
var panels: Array[ColorRect] = []
var materials: Array[ShaderMaterial] = []
var sprites: Array[TextureRect] = []
var font: Font

func _ready() -> void:
	mouse_filter=MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	font=preload("res://assets/space-grotesk.ttf")

func release() -> void:
	stage="cast"
	stage_time=0

func impact() -> void:
	stage="impact"
	stage_time=0
	if not effect_texture: effect_texture=preload("res://assets/ultimate-atlas.png")
	var water := signature=="runes"
	var profile: int = 2 if water else 7 if action_kind.begins_with("heal") or action_kind.begins_with("support") else 6 if action_kind.begins_with("shield") or action_kind=="guard" else {"igneo":1,"natural":3,"tecnico":4,"arcano":4,"sombrio":5}.get(affinity,4)
	var color := Color("65ddea") if water else tint
	var cell := Vector2(effect_texture.get_size())/Vector2(3,2)
	var index: int = 5 if support and not water else {"igneo":0,"natural":1,"tecnico":2,"arcano":3,"sombrio":4}.get(affinity,3)
	for at in destinations:
		var material := ShaderMaterial.new()
		material.shader=MODERN
		material.set_shader_parameter("profile",profile)
		material.set_shader_parameter("tint",color)
		material.set_shader_parameter("seed",float(signature.length()))
		var panel := ColorRect.new()
		panel.size=Vector2(310,265)
		panel.position=at-Vector2(155,170)
		panel.mouse_filter=MOUSE_FILTER_IGNORE
		panel.material=material
		add_child(panel)
		panels.append(panel)
		materials.append(material)
		# Keep the previous painted effects as a quiet, moving layer, not a pillar
		# of identical symbols. Saira's layer takes her tidal cyan color.
		var region := Rect2(Vector2(index%3,int(index/3.0))*cell,cell)
		var atlas := AtlasTexture.new()
		atlas.atlas=effect_texture
		atlas.region=region
		atlas.filter_clip=true
		var paint := ShaderMaterial.new()
		paint.shader=PAINT
		paint.set_shader_parameter("region_rect",Vector4(region.position.x/effect_texture.get_width(),region.position.y/effect_texture.get_height(),1.0/3.0,.5))
		paint.set_shader_parameter("tint",color)
		paint.set_shader_parameter("recolor",1.0 if water else .22)
		var sprite := TextureRect.new()
		sprite.texture=atlas
		sprite.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode=TextureRect.STRETCH_SCALE
		sprite.size=Vector2(170,200)
		sprite.position=at-Vector2(85,176)
		sprite.mouse_filter=MOUSE_FILTER_IGNORE
		sprite.material=paint
		add_child(sprite)
		sprites.append(sprite)

func _process(delta: float) -> void:
	elapsed+=delta
	stage_time+=delta
	if stage=="impact":
		var p := clampf(stage_time/1.1,0,1)
		for material in materials: material.set_shader_parameter("progress",p)
		for sprite in sprites: sprite.material.set_shader_parameter("progress",p)
	queue_redraw()
	if elapsed>4.6 or stage=="impact" and stage_time>1.15: queue_free()

func _draw() -> void:
	var fade := minf(1,elapsed*7)
	if stage=="impact": fade*=1-smoothstep(.5,1.15,stage_time)
	draw_rect(Rect2(Vector2.ZERO,size),Color("030b14",fade*.08))
	var width := minf(405,size.x*.35)
	var banner := Rect2(size.x*.5-width*.5,8,width,48)
	var box := StyleBoxFlat.new()
	box.bg_color=Color("07121dea",fade)
	box.border_color=Color(tint,fade*.55)
	box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	draw_style_box(box,banner)
	if icon: draw_texture_rect(icon,Rect2(banner.position+Vector2(8,7),Vector2(34,34)),false,Color(1,1,1,fade))
	draw_string(font,banner.position+Vector2(53,17),"SUPREMO",HORIZONTAL_ALIGNMENT_LEFT,width-62,10,Color(tint,fade))
	draw_string(font,banner.position+Vector2(53,36),title,HORIZONTAL_ALIGNMENT_LEFT,width-62,16,Color("e9f4ff",fade))
	var p := clampf(stage_time/1.1,0,1) if stage=="impact" else clampf(elapsed/.96,0,1)
	var color := Color("65ddea") if signature=="runes" else tint
	var points: Array = destinations if stage=="impact" else [origin]
	for at in points:
		for ring in range(2):
			var path := PackedVector2Array()
			var radius := (32+p*42+ring*9) if stage=="impact" else (48-p*12+ring*7)
			for i in range(97):
				var angle := TAU*float(i)/96
				path.append(at+Vector2(cos(angle),sin(angle)*.21)*radius)
			draw_polyline(path,Color(color,fade*.4),2 if ring==0 else 1,true)
