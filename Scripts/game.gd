extends Node3D

const PLAYER = preload("res://Scenes/zombie_player.tscn")
const LEVELS = [preload("res://Scenes/village_dawn.tscn"), preload("res://Scenes/moonlit_keep.tscn")]
var level: Node3D
var player: CharacterBody3D
var camera: Camera3D
var environment: WorldEnvironment
var stage: int = 0
var deaths: int = 0
var elapsed: float = 0
var running: bool = false
var paused: bool = false
var hud: Label
var hint: Label
var modal: PanelContainer
var modal_title: Label
var modal_copy: Label
var action: Button
var secondary: Button
var modal_action: Callable
var hint_timer: float = 0
var ui: Control
var pause_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for pair: Array in [["move_left", KEY_LEFT],["move_right",KEY_RIGHT],["move_forward",KEY_UP],["move_back",KEY_DOWN]]:
		var event := InputEventKey.new()
		event.physical_keycode = pair[1]
		InputMap.action_add_event(pair[0],event)
	build_world()
	build_ui()
	load_stage(0)
	show_modal("ZOMBIE\nVILLAGE RUN", "A little undead. A long way home.\n\nCollect 8 golden shards in each village.\nDodge red traps, jump the gaps, then find the gate.\n\nWASD / Arrows  ·  Move     Space × 2  ·  Double jump\nEsc / P  ·  Pause     R  ·  Restart level", "START ADVENTURE", start_game)

func build_world() -> void:
	environment = WorldEnvironment.new()
	environment.environment = Environment.new()
	var env := environment.environment
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("a9cbd0")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("e1e9ec")
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(environment)
	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-55,-28,0)
	sunlight.light_color = Color("fff0d2")
	sunlight.light_energy = 0.65
	sunlight.shadow_enabled = true
	add_child(sunlight)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 19
	camera.far = 160
	add_child(camera)
	camera.current = true

func load_stage(index: int) -> void:
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	if is_instance_valid(player):
		remove_child(player)
		player.queue_free()
	stage = index
	level = LEVELS[index].instantiate()
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	player = PLAYER.instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(player)
	player.position = Vector3(0,0.3,5)
	player.spawn_point = player.position
	player.active = running
	player.hurt.connect(func() -> void:
		deaths += 1
		set_hint("Ouch! Back to your checkpoint. Collected shards are safe.",3)
		update_hud())
	level.collected.connect(func(_count: int,_total: int) -> void:
		update_hud()
		if level.count == level.total: set_hint("ALL SHARDS FOUND  ·  The gate is open!",6))
	level.checkpoint_reached.connect(func(point: Vector3) -> void:
		player.spawn_point = point
		set_hint("CHECKPOINT SAVED",3))
	level.gate_reached.connect(complete_stage)
	environment.environment.background_color = Color("a9cbd0") if index == 0 else Color("24344c")
	environment.environment.ambient_light_color = Color("e1e9ec") if index == 0 else Color("b4c9ed")
	update_camera(1)
	update_hud()

func _process(delta: float) -> void:
	if running and not paused:
		elapsed += delta
		update_camera(delta)
		update_hud()
		if hint_timer > 0:
			hint_timer -= delta
			if hint_timer <= 0: hint.text = "Collect every shard to open the gate."

func update_camera(delta: float) -> void:
	var target := Vector3(clampf(player.position.x*0.3,-1.2,1.2),0,player.position.z-3.4)
	camera.position = camera.position.lerp(target+Vector3(0,16,17),minf(delta*7,1))
	camera.rotation_degrees = Vector3(-43.3,0,0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE,KEY_P] and (running or paused): toggle_pause()
		elif event.keycode == KEY_R and running and not paused: restart_stage()

func start_game() -> void:
	deaths = 0
	elapsed = 0
	running = true
	paused = false
	get_tree().paused = false
	load_stage(0)
	modal.hide()
	pause_button.show()
	set_hint("Village 01  ·  Follow the golden shards. Space twice for a longer jump.",6)

func restart_stage() -> void:
	get_tree().paused = false
	paused = false
	running = true
	load_stage(stage)
	modal.hide()
	pause_button.show()

func complete_stage() -> void:
	running = false
	player.active = false
	pause_button.hide()
	if stage == 0:
		show_modal("VILLAGE 01\nCOMPLETE", "All 8 shards recovered.\n\nThe moonlit keep is next.\nWatch for faster spikes and fire over the gaps.","ENTER VILLAGE 02",func() -> void:
			running = true
			load_stage(1)
			modal.hide()
			pause_button.show()
			set_hint("Village 02  ·  Cross the gaps through the center or left side.",6))
	else:
		show_modal("HOME AT LAST!", "Both villages cleared  ·  16 / 16 shards\n\nTime  %s     Respawns  %d\n\nThanks for playing Zombie Village Run." % [format_time(),deaths],"PLAY AGAIN",start_game)

func toggle_pause() -> void:
	if paused:
		paused = false
		get_tree().paused = false
		modal.hide()
		return
	paused = true
	get_tree().paused = true
	show_modal("TAKE A BREATHER", "WASD / Arrows  ·  Move\nSpace  ·  Jump / Double jump\nR  ·  Restart current level\n\nCollect all 8 shards, then enter the glowing gate.","RESUME",toggle_pause)
	secondary.text = "RESTART LEVEL"
	secondary.show()

func format_time() -> String:
	return "%02d:%02d" % [int(elapsed)/60,int(elapsed)%60]

func update_hud() -> void:
	if not hud: return
	hud.text = "VILLAGE %02d / 02     SHARDS %d / 8     %s     RESPAWNS %d" % [stage+1,level.count,format_time(),deaths]

func set_hint(text: String, duration: float) -> void:
	hint.text = text
	hint_timer = duration

func panel_style(color: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	style.border_color = border
	style.set_border_width_all(1)
	return style

func build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui)
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 24
	top.offset_right = -24
	top.offset_top = 20
	top.offset_bottom = 78
	top.add_theme_stylebox_override("panel",panel_style(Color("182c39ef")))
	ui.add_child(top)
	hud = Label.new()
	hud.add_theme_font_size_override("font_size",19)
	hud.add_theme_color_override("font_color",Color("f4e7c4"))
	top.add_child(hud)
	pause_button = Button.new()
	pause_button.text = "PAUSE  II"
	ui.add_child(pause_button)
	pause_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -170
	pause_button.offset_right = -38
	pause_button.offset_top = 30
	pause_button.offset_bottom = 72
	pause_button.pressed.connect(toggle_pause)
	pause_button.hide()
	hint = Label.new()
	ui.add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -50
	hint.offset_bottom = -20
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size",18)
	hint.add_theme_color_override("font_shadow_color",Color.BLACK)
	hint.add_theme_constant_override("shadow_offset_x",1)
	hint.add_theme_constant_override("shadow_offset_y",2)
	hint.text = "Collect every shard to open the gate."
	modal = PanelContainer.new()
	ui.add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	modal.offset_left = -330
	modal.offset_right = 330
	modal.offset_top = -278
	modal.offset_bottom = 278
	modal.add_theme_stylebox_override("panel",panel_style(Color("172b39f5"),Color("647d78")))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",17)
	modal.add_child(stack)
	var eyebrow := Label.new()
	eyebrow.text = "FIRST 3D GAME  /  A LOW-POLY ADVENTURE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size",14)
	eyebrow.add_theme_color_override("font_color",Color("80caba"))
	stack.add_child(eyebrow)
	modal_title = Label.new()
	modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_title.add_theme_font_size_override("font_size",43)
	modal_title.add_theme_color_override("font_color",Color("f4e7c4"))
	stack.add_child(modal_title)
	modal_copy = Label.new()
	modal_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_copy.add_theme_font_size_override("font_size",18)
	modal_copy.add_theme_color_override("font_color",Color("d6e0df"))
	stack.add_child(modal_copy)
	action = Button.new()
	action.custom_minimum_size.y = 54
	action.add_theme_font_size_override("font_size",19)
	action.add_theme_color_override("font_color",Color("142a33"))
	action.add_theme_stylebox_override("normal",panel_style(Color("e7c676")))
	action.add_theme_stylebox_override("hover",panel_style(Color("f6dfa0")))
	action.pressed.connect(func() -> void: modal_action.call())
	stack.add_child(action)
	secondary = Button.new()
	secondary.pressed.connect(restart_stage)
	stack.add_child(secondary)
	secondary.hide()
	var credits := Label.new()
	credits.text = "Starter: SD Studios  ·  Zombie: bachosoftdesign (CC BY)\nVillage: Quaternius (CC0)  ·  Models from Poly Pizza"
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size",12)
	credits.add_theme_color_override("font_color",Color("93a8b0"))
	stack.add_child(credits)

func show_modal(title: String, copy: String, button: String, callback: Callable) -> void:
	modal_title.text = title
	modal_copy.text = copy
	action.text = button
	modal_action = callback
	secondary.hide()
	modal.show()
	action.grab_focus()
