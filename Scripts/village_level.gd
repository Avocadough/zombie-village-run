extends Node3D

signal collected(count: int, total: int)
signal gate_reached
signal checkpoint_reached(point: Vector3)
@export_range(1, 2) var stage: int = 1
@export var baked: bool = false
var count: int = 0
var total: int = 8
var coins: Array[Area3D] = []
var hazards: Array[Area3D] = []
var gate: Area3D
var gate_material: StandardMaterial3D
var gate_label: Label3D
var clock: float = 0
var finished: bool = false
var checkpoint_active: bool = false
const COIN_POINTS: Array[Vector3] = [Vector3(-3,1,3), Vector3(3,1,-3), Vector3(0,1,-9), Vector3(-3,1,-16), Vector3(3,1,-22), Vector3(0,1,-27), Vector3(-3,1,-34), Vector3(3,1,-39)]

func _ready() -> void:
	if baked:
		connect_baked_scene()
		return
	var ground_color := Color("708c58") if stage == 1 else Color("485b73")
	for i: int in range(3):
		var z: float = -18.0 * i
		box("Island", Vector3(0,-0.7,z), Vector3(18,1.4,16), ground_color, true)
		box("Path", Vector3(0,0.012,z), Vector3(7,0.025,16), Color("c3b48f") if stage == 1 else Color("878ba0"), false)
		for side: int in [-1,1]:
			for k: int in range(3):
				var pos := Vector3(side * 7.1,0,z + 5 - k * 5)
				prop("Fantasy House" if k != 1 else "Fantasy House-BH2XHWUNmF", pos, 2.8, PI / 2 * -side)
			for k: int in range(5):
				box("PathEdge", Vector3(side*3.7,0.12,z+6-k*3), Vector3(0.35,0.24,1.7), Color("e0cd9f"), false)
		# A safe route around obstacles remains on each side of the street.
		box("CrateObstacle", Vector3(-1.5 if i%2 == 0 else 1.5,0.5,z-1), Vector3(1.6,1,1.4), Color("8c6149"), true)
		prop("Crate", Vector3(-1.5 if i%2 == 0 else 1.5,1,z-1), 0.65)
		prop("Barrel", Vector3(4.4,0,z+2),1.1)
		prop("Market Stand", Vector3(-5.0,0,z-2.8),2.0,PI/2)
		for side: int in [-1,1]:
			tree(Vector3(side*8.1,0,z-6), 1.0+i*0.15)
	for i: int in range(COIN_POINTS.size()):
		var coin := area("Coin%02d" % i, COIN_POINTS[i], Vector3(1.25,1.8,1.25))
		var mesh := MeshInstance3D.new()
		var gem := PrismMesh.new()
		gem.size = Vector3(0.6,0.9,0.6)
		mesh.mesh = gem
		mesh.material_override = material(Color("ffdb70"), 0.8)
		coin.add_child(mesh)
		coin.set_meta("base_y", coin.position.y)
		coin.body_entered.connect(func(body: Node3D) -> void: collect_coin(coin, body))
		coins.append(coin)
	for z: float in [-5.5,-20.0,-36.0]:
		var trap := area("MovingSpikes", Vector3(0,0.35,z), Vector3(1.8,0.65,1.2))
		trap.set_meta("phase", z)
		for x: float in [-0.55,0,0.55]:
			var mesh := MeshInstance3D.new()
			var cone := CylinderMesh.new()
			cone.top_radius = 0
			cone.bottom_radius = 0.28
			cone.height = 0.7
			cone.radial_segments = 6
			mesh.mesh = cone
			mesh.position.x = x
			mesh.material_override = material(Color("dd645d"))
			trap.add_child(mesh)
		trap.body_entered.connect(func(body: Node3D) -> void:
			if body.is_in_group("player"): body.take_hit())
		hazards.append(trap)
	if stage == 2:
		for z: float in [-12,-30]:
			var trap := area("GapFlame", Vector3(2.3,0.4,z), Vector3(1.5,1,1.4))
			var mesh := MeshInstance3D.new()
			var sphere := SphereMesh.new()
			sphere.radius = 0.55
			sphere.height = 1.1
			mesh.mesh = sphere
			mesh.material_override = material(Color("f88649"),0.8)
			trap.add_child(mesh)
			trap.body_entered.connect(func(body: Node3D) -> void:
				if body.is_in_group("player"): body.take_hit())
	var checkpoint := area("Checkpoint", Vector3(0,0.8,-18), Vector3(7,2,1))
	checkpoint.body_entered.connect(func(body: Node3D) -> void:
		if body.is_in_group("player") and not checkpoint_active:
			checkpoint_active = true
			checkpoint_reached.emit(Vector3(0,0.3,-18)))
	box("CheckpointLine",Vector3(0,0.04,-18),Vector3(7,0.08,0.18),Color("5bdec7"),false)
	label3d("CHECKPOINT",Vector3(0,2.5,-18),24)
	gate = area("ExitGate", Vector3(0,1.5,-42), Vector3(3.0,3,1.5))
	gate.body_entered.connect(_gate_entered)
	gate_material = material(Color("d46f64"),0.5)
	for x: float in [-1.8,1.8]:
		box("GatePillar", Vector3(x,1.7,-42), Vector3(0.65,3.4,0.8),Color("ede0ba"),true)
	box("GateLintel",Vector3(0,3.6,-42),Vector3(4.4,0.6,1),Color("ede0ba"),true)
	var veil := box("GateLight",Vector3(0,1.6,-42),Vector3(3,3,0.12),Color.WHITE,false)
	veil.material_override = gate_material
	gate_label = label3d("COLLECT ALL 8",Vector3(0,4.4,-42),32)
	gate_label.name = "GateLabel"
	prop("Bell Tower",Vector3(6,0,-41),7)
	label3d("JUMP THE GAP",Vector3(0,1.7,-7),25)
	label3d("SPACE + SPACE",Vector3(0,1.7,-25),25)

func connect_baked_scene() -> void:
	for node: Node in find_children("*", "Area3D",true,false):
		var zone := node as Area3D
		if zone.name.begins_with("Coin"):
			coins.append(zone)
			zone.body_entered.connect(func(body: Node3D) -> void: collect_coin(zone,body))
		elif zone.has_meta("phase"):
			hazards.append(zone)
			zone.body_entered.connect(func(body: Node3D) -> void:
				if body.is_in_group("player"): body.take_hit())
		elif zone.name.begins_with("GapFlame"):
			zone.body_entered.connect(func(body: Node3D) -> void:
				if body.is_in_group("player"): body.take_hit())
		elif zone.name == "Checkpoint":
			zone.body_entered.connect(func(body: Node3D) -> void:
				if body.is_in_group("player") and not checkpoint_active:
					checkpoint_active = true
					checkpoint_reached.emit(Vector3(0,0.3,-18)))
	gate = get_node("ExitGate")
	gate.body_entered.connect(_gate_entered)
	gate_material = get_node("GateLight").material_override.duplicate()
	get_node("GateLight").material_override = gate_material
	gate_label = get_node("GateLabel")

func _process(delta: float) -> void:
	clock += delta
	for coin: Area3D in coins:
		if is_instance_valid(coin) and coin.visible:
			coin.rotation.y += delta*1.8
			coin.position.y = float(coin.get_meta("base_y")) + sin(clock*2.5+coin.position.z)*0.12
	for hazard: Area3D in hazards:
		hazard.position.x = sin(clock*(1.2 if stage == 1 else 1.8)+float(hazard.get_meta("phase"))) * (2.3 if stage == 1 else 2.7)

func collect_coin(coin: Area3D, body: Node3D) -> void:
	if not body.is_in_group("player") or not body.active or not coin.visible:
		return
	coin.hide()
	coin.set_deferred("monitoring", false)
	count += 1
	AudioManager.coin_sfx.play()
	collected.emit(count,total)
	if count == total:
		gate_material.albedo_color = Color("5ce5c2")
		gate_material.emission = Color("5ce5c2")
		gate_label.text = "EXIT OPEN"
		for overlapping: Node3D in gate.get_overlapping_bodies():
			_gate_entered(overlapping)

func _gate_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.active and count == total and not finished:
		finished = true
		gate_reached.emit()

func material(color: Color, glow: float = 0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	if glow > 0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	return mat

func box(title: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = title
	var cube := BoxMesh.new()
	cube.size = size
	mesh.mesh = cube
	mesh.material_override = material(color)
	add_child(mesh)
	mesh.position = pos
	if solid:
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		mesh.add_child(body)
	return mesh

func area(title: String, pos: Vector3, size: Vector3) -> Area3D:
	var zone := Area3D.new()
	zone.name = title
	zone.collision_layer = 0
	zone.collision_mask = 1
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	zone.add_child(collision)
	add_child(zone)
	zone.position = pos
	return zone

func prop(asset: String, pos: Vector3, height: float, angle: float = 0) -> void:
	var model: Node3D = load("res://Assets/Village/" + asset + ".glb").instantiate()
	add_child(model)
	var bounds := AABB()
	var first: bool = true
	for mesh: Node in model.find_children("*", "MeshInstance3D",true,false):
		var local: AABB = model.global_transform.affine_inverse()*mesh.global_transform*mesh.get_aabb()
		bounds = local if first else bounds.merge(local)
		first = false
	var factor: float = height / maxf(bounds.size.y,0.01)
	model.scale = Vector3.ONE*factor
	model.position = pos - (Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)*factor).rotated(Vector3.UP,angle)
	model.rotation.y = angle

func tree(pos: Vector3, factor: float) -> void:
	box("TreeTrunk",pos+Vector3(0,1,0)*factor,Vector3(0.3,2,0.3)*factor,Color("715146"),false)
	for i: int in range(2):
		var mesh := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0
		cone.bottom_radius = (1.2-i*0.3)*factor
		cone.height = 2*factor
		cone.radial_segments = 6
		mesh.mesh = cone
		mesh.material_override = material(Color("35584f") if stage == 1 else Color("365269"))
		add_child(mesh)
		mesh.position = pos+Vector3(0,2+i,0)*factor

func label3d(text: String, pos: Vector3, size: int) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.012
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	add_child(label)
	label.position = pos
	return label
