extends MarginContainer

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	var screen_size: Vector2 = 	get_viewport_rect().size
	if TNTInputEngine._screen_is_landscape(screen_size):
		rect_scale.y = screen_size.y / TNTInputEngine.remap_design_height
		rect_scale.x = rect_scale.y
	else:
		rect_scale.x = screen_size.x / TNTInputEngine.remap_design_height
		rect_scale.y = rect_scale.x
		
	rect_position.x = (((screen_size.x)/2) - ((rect_size.x*rect_scale.x)/2))
	rect_position.y = (((screen_size.y)/2) - ((rect_size.y*rect_scale.y)/2))

func _on_btnSave_pressed() -> void:
	TNTInputEngine.emit_signal("save_map")

func _on_btnReset_pressed() -> void:
	TNTInputEngine.emit_signal("reset_map")

func _on_btnClose_pressed() -> void:
	TNTInputEngine.emit_signal("close_mapping")
