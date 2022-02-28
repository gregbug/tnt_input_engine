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

extends TNT_Virtual_JoyPad
class_name TNT_Virtual_Button, "res://addons/tnt_input_engine/assets/icons/tnt_virtual_button.png"

enum HwJoyMap {NONE, BTN_A, BTN_B, BTN_X, BTN_Y, SELECT, START, L1, L2, R1, R2}
export(HwJoyMap) var hw_joy_map_binding: int = HwJoyMap.NONE
export(String) var action: String = ""

func _ready() -> void:
	var key: String = ""
	match hw_joy_map_binding:
		HwJoyMap.BTN_A:
			key = "A"
		HwJoyMap.BTN_B:
			key = "B"
		HwJoyMap.BTN_X:
			key = "X"
		HwJoyMap.BTN_Y:
			key = "Y"
		HwJoyMap.SELECT:
			key = "SELECT"
		HwJoyMap.START:
			key = "START"
		HwJoyMap.L1:
			key = "L1"
		HwJoyMap.L2:
			key = "L2"
		HwJoyMap.R1:
			key = "R1"
		HwJoyMap.R2:
			key = "R2"
	if key != "":
		_action = TNTInputEngine._add_binding(key, action)
		_strength = 1
	
	if action == "":
		action = _action
		
	_current_direction = JoyDirection.NONE

func _reset() -> void:
	._reset()
	_texture_1.show()
	_texture_2.hide()
	_texture_1.self_modulate = _color
	_texture_2.self_modulate = _pressed_color
	_current_direction = JoyDirection.NONE

func _update_control(event_position: Vector2, emit_action: bool = true) -> void:
	if !_dimmer_active:
		_texture_1.modulate.a = TNTInputEngine.full_alpha
	
	_texture_1.self_modulate = _color
	_texture_2.self_modulate = _pressed_color
	_texture_2.show()
	
	if control_mode == ControlMode.FOLLOWING:
		var center : Vector2 = _texture_1.rect_global_position + (_texture_1.rect_size * 0.5)
		var vector : Vector2 = event_position - center
		TNTInputEngine._following(vector, clamp_zone, rect_size, _texture_1)
		
	if emit_action:
		Input.action_press(_action, _strength)
