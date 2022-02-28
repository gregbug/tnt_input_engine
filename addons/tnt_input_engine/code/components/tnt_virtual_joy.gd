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
class_name TNT_Virtual_Joy, "res://addons/tnt_input_engine/assets/icons/tnt_joy_icon.png"

# REAL: return a vector with a lenght beetween 0 (deadzone) and 1; useful for implementing different velocity or acceleration.
# NORMALIZED: return a normalized vector.

enum HwJoyMap {NONE, LEFT_STICK, RIGHT_STICK}

#If the handle is inside this range, in proportion to the background size, the output is zero.
export(HwJoyMap) var hw_joy_map: int = HwJoyMap.NONE

export(String) var action_left_joy_x_left: String = TNTInputEngine.ACTION_LEFTAXIS_LEFT
export(String) var action_left_joy_x_right: String = TNTInputEngine.ACTION_LEFTAXIS_RIGHT
export(String) var action_left_joy_y_up: String = TNTInputEngine.ACTION_LEFTAXIS_UP
export(String) var action_left_joy_y_down: String = TNTInputEngine.ACTION_LEFTAXIS_DOWN

export(String) var action_right_joy_x_left: String = TNTInputEngine.ACTION_RIGHTAXIS_LEFT
export(String) var action_right_joy_x_right: String = TNTInputEngine.ACTION_RIGHTAXIS_RIGHT
export(String) var action_right_joy_y_up: String = TNTInputEngine.ACTION_RIGHTAXIS_UP
export(String) var action_right_joy_y_down: String = TNTInputEngine.ACTION_RIGHTAXIS_DOWN

func _ready() -> void:
	._ready()
	_dead_size = dead_zone * _ray
	match hw_joy_map:
		HwJoyMap.LEFT_STICK:
			_act_down = action_left_joy_y_down
			_act_left = action_left_joy_x_left
			_act_right = action_left_joy_x_right
			_act_up = action_left_joy_y_up
			TNTInputEngine._add_binding("JOYLEFTX-", _act_left, dead_zone)
			TNTInputEngine._add_binding("JOYLEFTX+", _act_right, dead_zone)
			TNTInputEngine._add_binding("JOYLEFTY-", _act_up, dead_zone)
			TNTInputEngine._add_binding("JOYLEFTY+", _act_down, dead_zone)
		HwJoyMap.RIGHT_STICK:
			_act_down = action_right_joy_y_down
			_act_left = action_right_joy_x_left
			_act_right = action_right_joy_x_right
			_act_up = action_right_joy_y_up
			TNTInputEngine._add_binding("JOYRIGHTX-", _act_left, dead_zone)
			TNTInputEngine._add_binding("JOYRIGHTX+", _act_right, dead_zone)
			TNTInputEngine._add_binding("JOYRIGHTY-", _act_up, dead_zone)
			TNTInputEngine._add_binding("JOYRIGHTY+", _act_down, dead_zone)
		
func _reset() -> void:
	._reset()
	_output = Vector2.ZERO
	Input.action_release(_act_down)
	Input.action_release(_act_up)	
	Input.action_release(_act_left)	
	Input.action_release(_act_right)
	
func _input(event: InputEvent, emit_event: bool = false) -> void:
	._input(event, true)

func _update_control(_event_position: Vector2, emit_action: bool = true) -> void:
	if !_dimmer_active:
		_texture_1.modulate.a = TNTInputEngine.full_alpha
		
	var _center: Vector2 = _texture_1.rect_global_position + (_cscale * _texture_1.rect_size * 0.5)
	var _vector: Vector2 = _event_position - _center

	if _vector.length() > _dead_size:
		var clamp_size: float = clamp_zone * _ray
		if vector_mode == VectorMode.NORMALIZED:
			_output = _vector.normalized()
			TNTInputEngine._center_control(_texture_2, _output * clamp_size + _center, _cscale)
		elif vector_mode == VectorMode.REAL:
			var clamped_vector := _vector.clamped(clamp_size)
			_output = _vector.normalized() * (clamped_vector.length() - _dead_size) / (clamp_size - _dead_size)
			TNTInputEngine._center_control(_texture_2, clamped_vector + _center, _cscale)

		if control_mode == ControlMode.FOLLOWING:
			TNTInputEngine._following(_vector, clamp_zone, rect_size * _cscale, _texture_1)
		
		if _output.x > 0:
			Input.action_press(_act_right, _output.x)
		elif _output.x < 0:
			Input.action_press(_act_left, -_output.x)
		if _output.y > 0:
			Input.action_press(_act_down, _output.y)
		elif _output.y < 0:
			Input.action_press(_act_up, -_output.y)	
	else:
		_output = Vector2.ZERO
		TNTInputEngine._reset_handle(_texture_1, _texture_2, _cscale)

