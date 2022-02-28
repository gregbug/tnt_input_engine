#
#	       ###### ##   ## ######
#	         ##   #### ##   ##
#	         ##   ## ####   ##
#	         ##   ##   ##   ##
#
#       	 Input Engine 1.00
#
#  by Gianluca D'Angelo copyright (c) 2021 
#            all right reserved.                     
#                                         
# - v1.00 release - 01/03/2021 -          
#

extends Control

var wait_for_button: String = ""
var joy_num: int = -1
var joy_GUID: String = ""
var btn_detected: int = -1

func _ready() -> void:

	var screen_size: Vector2 = 	get_viewport_rect().size
	$Panel.rect_position.x = (screen_size.x / 2) - ($Panel.rect_size.x / 2)
	$Panel.rect_position.y = (screen_size.y / 2) - ($Panel.rect_size.y / 2)
	
	$Panel/lblWait.text = "...waiting for "+wait_for_button+" button mapping..."
	Input.remove_joy_mapping(joy_GUID)

func _process(delta: float) -> void:
	for btn in range(JOY_BUTTON_0, int(min(JOY_BUTTON_MAX, 24))):
		if Input.is_joy_button_pressed(joy_num, btn):
			if btn < 17:
				$Panel/lblResult.text = "DETECTED BUTTON "+str(btn)
				$Panel/btnApply.disabled = false
				btn_detected = btn

func _on_btnCancel_pressed() -> void:
	get_tree().set_input_as_handled()
	TNTInputEngine.emit_signal("cancel_mapping")
	queue_free()

func _on_btnApply_pressed() -> void:
	get_tree().set_input_as_handled()
	TNTInputEngine.emit_signal("mapped", wait_for_button, btn_detected)
	queue_free()
