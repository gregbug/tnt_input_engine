extends Node

var current_scene: Node = null
	
func goto_scene(path: String) -> void:
	init_change()
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String) -> void:
	current_scene.free()
	var new_scene: Object = ResourceLoader.load(path)
	current_scene = new_scene.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func init_change() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
