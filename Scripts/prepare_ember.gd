extends SceneTree
func _initialize() -> void:
	var source=load("res://.tools/MeleeLib.res") as AnimationLibrary
	if source==null:quit(1);return
	var subset=AnimationLibrary.new()
	for clip in ["LightIdle","Sprint","Jump","Hurt1"]:
		subset.add_animation(clip,source.get_animation(clip))
	var result=ResourceSaver.save(subset,"res://Assets/Ember/DemoMelee.res")
	print("Prepared Ember campaign animation library: ",result)
	quit(result)
