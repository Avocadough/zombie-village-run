# Maintainer utility: persist generated geometry as editable Godot scenes.
extends SceneTree

func _initialize() -> void:
	call_deferred("bake")

func own(node: Node, root_node: Node) -> void:
	for child: Node in node.get_children():
		child.scene_file_path = ""
		child.owner = root_node
		own(child,root_node)

func bake() -> void:
	for index: int in range(2):
		var level := Node3D.new()
		level.name = "VillageDawn" if index == 0 else "MoonlitKeep"
		level.set_script(load("res://Scripts/village_level.gd"))
		level.stage = index+1
		root.add_child(level)
		level.baked = true
		own(level,level)
		var packed := PackedScene.new()
		var result := packed.pack(level)
		assert(result == OK)
		result = ResourceSaver.save(packed,"res://Scenes/"+("village_dawn" if index == 0 else "moonlit_keep")+".tscn")
		assert(result == OK)
		root.remove_child(level)
		level.free()
	var player := CharacterBody3D.new()
	player.name = "ZombiePlayer"
	player.set_script(load("res://Scripts/zombie_player.gd"))
	root.add_child(player)
	own(player,player)
	var player_scene := PackedScene.new()
	assert(player_scene.pack(player) == OK)
	assert(ResourceSaver.save(player_scene,"res://Scenes/zombie_player.tscn") == OK)
	root.remove_child(player)
	player.free()
	print("BAKED_EDITABLE_LEVELS_OK")
	quit()
