extends Node

var game: Node3D
var failures: Array[String] = []

func check(condition: bool, description: String) -> void:
	print(("PASS " if condition else "FAIL ") + description)
	if not condition: failures.append(description)

func frames(count: int) -> void:
	for i: int in range(count): await get_tree().physics_frame

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	game = preload("res://Scenes/main.tscn").instantiate()
	add_child(game)
	await frames(3)
	check(game.modal.visible and not game.running,"Menu blocks movement")
	game.start_game()
	await frames(30)
	check(game.player.is_on_floor(),"Player stands on real collision")
	for state: String in ["Idle","Run","Jump","Flip","Hurt"]:
		check(game.player.animator.has_animation("game/"+state),"Animation adapter " + state)
	game.level._gate_entered(game.player)
	check(game.running and not game.level.finished,"Gate locked with missing shards")
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	await frames(6)
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	await frames(3)
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	check(game.player.jumps == 2,"Third airborne jump rejected")
	await frames(90)
	game.toggle_pause()
	var elapsed: float = game.elapsed
	await frames(5)
	check(game.elapsed == elapsed,"Pause freezes timer")
	game.toggle_pause()
	# Isolated damage assertion; traversal below uses actual input and collisions.
	game.player.take_hit()
	check(game.deaths == 1 and game.player.position == game.player.spawn_point,"Damage respawns at checkpoint")
	game.restart_stage()
	for index: int in range(2):
		if index == 1:
			game.modal_action.call()
		await frames(30)
		await walk_route()
		check(game.level.count == 8,"Level %d collects 8 shards through overlaps" % (index+1))
		check(game.level.checkpoint_active,"Level %d activates checkpoint" % (index+1))
		check(game.level.finished,"Level %d reaches unlocked gate" % (index+1))
		if not game.level.finished: break
	check(game.stage == 1 and game.modal_title.text == "HOME AT LAST!","Two-level victory screen")
	game.start_game()
	check(game.stage == 0 and game.level.count == 0 and game.deaths == 0,"Replay resets campaign")
	print("VALIDATION_OK" if failures.is_empty() else "VALIDATION_FAILED: " + str(failures))
	get_tree().quit(0 if failures.is_empty() else 1)

func walk_route() -> void:
	var points: Array[Vector2] = [Vector2(-3,3),Vector2(3,3),Vector2(3,-3),Vector2(4.5,-3),Vector2(4.5,-7),Vector2(0,-7),Vector2(0,-11),Vector2(-3,-13),Vector2(-3,-16),Vector2(0,-18),Vector2(-4.5,-18),Vector2(-4.5,-23),Vector2(3,-23),Vector2(3,-22),Vector2(0,-24.8),Vector2(0,-29),Vector2(-3,-31),Vector2(-3,-34),Vector2(-4.5,-34),Vector2(-4.5,-39),Vector2(3,-39),Vector2(0,-40),Vector2(0,-42)]
	for target: Vector2 in points:
		var budget: int = 800
		while Vector2(game.player.position.x,game.player.position.z).distance_to(target) > 0.17 and budget > 0 and game.running:
			budget -= 1
			var pos: Vector3 = game.player.position
			var direction: Vector2 = target-Vector2(pos.x,pos.z)
			Input.action_press("move_right",clampf(direction.x*5,0,1))
			Input.action_press("move_left",clampf(-direction.x*5,0,1))
			Input.action_press("move_back",clampf(direction.y*5,0,1))
			Input.action_press("move_forward",clampf(-direction.y*5,0,1))
			if game.player.is_on_floor() and ((pos.z < -7.2 and pos.z > -8) or (pos.z < -25.2 and pos.z > -26)):
				Input.action_press("jump")
			else:
				Input.action_release("jump")
			await frames(1)
		for key: String in ["move_left","move_right","move_forward","move_back","jump"]: Input.action_release(key)
		if budget <= 0:
			check(false,"Route timeout at %s; player %s" % [target,game.player.position])
			return
		await frames(2)
	await frames(5)
