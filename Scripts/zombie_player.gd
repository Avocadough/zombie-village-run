# Movement derived from SD Studios' Scripts/player.gd (MIT).
# Physics, bounded double jump and the Poly Pizza animation adapter are revised.
extends CharacterBody3D

signal hurt
const SPEED: float = 6.0
const JUMP: float = 8.8
var jumps: int = 0
var active: bool = false
var invulnerability: float = 0.0
var spawn_point := Vector3(0, 1, 5)
var visual: Node3D
var animator: AnimationPlayer
var flip_time: float = 0.0
var animation_state: String = ""

func _ready() -> void:
	add_to_group("player")
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.6
	collision.shape = capsule
	collision.position.y = 0.8
	add_child(collision)
	visual = Node3D.new()
	visual.name = "Visual"
	add_child(visual)
	var zombie := preload("res://Assets/Models/Zombie by bachosoftdesign - xqEzosAVYX.glb").instantiate()
	visual.add_child(zombie)
	# Imported FBX-to-GLTF units are normalized using actual mesh bounds.
	var bounds := _bounds(zombie)
	var factor: float = 1.65 / maxf(bounds.size.y, 0.01)
	zombie.scale = Vector3.ONE * factor
	zombie.position = Vector3(-bounds.get_center().x, -bounds.position.y, -bounds.get_center().z) * factor
	animator = zombie.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animator:
		var library := AnimationLibrary.new()
		for pair: Array in [["Idle", "Idle"], ["Run", "Walk"], ["Jump", "Idle"], ["Flip", "Idle"], ["Hurt", "Hit_reaction"]]:
			for source: StringName in animator.get_animation_list():
				if String(source).ends_with("|" + pair[1]):
					var clip: Animation = animator.get_animation(source).duplicate(true)
					clip.loop_mode = Animation.LOOP_LINEAR if pair[0] in ["Idle", "Run", "Jump", "Flip"] else Animation.LOOP_NONE
					library.add_animation(pair[0], clip)
					break
		animator.add_animation_library("game", library)
	play_state("Idle")

func _bounds(root: Node3D) -> AABB:
	var bounds := AABB()
	var first: bool = true
	for mesh: Node in root.find_children("*", "MeshInstance3D", true, false):
		var local: AABB = root.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		bounds = local if first else bounds.merge(local)
		first = false
	return bounds

func _physics_process(delta: float) -> void:
	invulnerability = maxf(0, invulnerability - delta)
	visual.visible = invulnerability <= 0 or int(invulnerability * 12) % 2 == 0
	if not active:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	velocity.x = input.x * SPEED
	velocity.z = input.y * SPEED
	if is_on_floor():
		jumps = 0
	velocity.y -= 22.0 * delta
	if Input.is_action_just_pressed("jump") and (is_on_floor() or jumps == 1):
		jumps += 1
		velocity.y = JUMP
		flip_time = 0.5 if jumps == 2 else 0.0
		AudioManager.jump_sfx.play()
	move_and_slide()
	if input.length() > 0.05:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(input.x, input.y), delta * 14)
	if flip_time > 0:
		flip_time = maxf(0, flip_time - delta)
		visual.rotation.x = (1.0 - flip_time / 0.5) * TAU
		play_state("Flip")
	elif not is_on_floor():
		visual.rotation.x = -0.13 if velocity.y > 0 else 0.13
		play_state("Jump")
	else:
		visual.rotation.x = 0
		play_state("Run" if input.length() > 0.05 else "Idle")
	if position.y < -5:
		take_hit()

func play_state(state: String) -> void:
	if animation_state == state:
		return
	animation_state = state
	if animator and animator.has_animation("game/" + state):
		animator.play("game/" + state, 0.15, 1.8 if state == "Run" else 1.0)

func take_hit() -> void:
	if not active or invulnerability > 0:
		return
	position = spawn_point
	velocity = Vector3.ZERO
	jumps = 0
	flip_time = 0
	visual.rotation.x = 0
	invulnerability = 1.5
	play_state("Hurt")
	hurt.emit()
