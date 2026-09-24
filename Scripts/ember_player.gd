# Exercise 6 character integrated into the Exercise 5 controller.
extends "res://Scripts/zombie_player.gd"

func _ready() -> void:
	add_to_group("player")
	visual = $Visual
	var model: Node3D = $Visual/Ember
	var skeleton: Skeleton3D = model.get_node("EmberRig/Skeleton3D")
	animator = model.get_node("AnimationPlayer")
	for name_ in animator.get_animation_library_list(): animator.remove_animation_library(name_)
	var mapping = preload("res://Assets/Ember/Mixamo BoneMap.tres") as BoneMap
	var source = load("res://Assets/Ember/DemoMelee.res") as AnimationLibrary
	var library = AnimationLibrary.new()
	for pair in [["Idle","LightIdle"],["Run","Sprint"],["Jump","Jump"],["Flip","Jump"],["Hurt","Hurt1"]]:
		var clip = source.get_animation(pair[1]).duplicate(true) as Animation
		for i in range(clip.get_track_count()-1,-1,-1):
			var standard = str(clip.track_get_path(i).get_subname(0))
			var bone = str(mapping.get_skeleton_bone_name(standard)) if mapping.profile.find_bone(standard)>=0 else standard
			if bone.is_empty(): bone=standard
			# Physics owns jump displacement; keep the airborne pose without a second visual leap.
			if skeleton.find_bone(bone)<0 or (pair[0] in ["Jump","Flip"] and clip.track_get_type(i)==Animation.TYPE_POSITION_3D):
				clip.remove_track(i)
				continue
			clip.track_set_path(i,NodePath("EmberRig/Skeleton3D:"+bone))
		clip.loop_mode=Animation.LOOP_LINEAR if pair[0] in ["Idle","Run"] else Animation.LOOP_NONE
		library.add_animation(pair[0],clip)
	animator.add_animation_library("game",library)
	play_state("Idle")

func play_state(state: String) -> void:
	if animation_state==state:return
	animation_state=state
	if animator and animator.has_animation("game/"+state):
		animator.play("game/"+state,.12,1.0)
