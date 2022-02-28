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
class_name TNT_Virtual_Dpad, "res://addons/tnt_input_engine/assets/icons/tnt_dpad.png"

enum InputActions { INPUT_ACTION_LEFT, INPUT_ACTION_RIGHT, INPUT_ACTION_UP, INPUT_ACTION_DOWN }
enum JoyDPadType { ALL_DIRECTIONS, LEFT_RIGHT, UP_DOWN }
			
export(JoyDPadType) var Dpad_directions: int = JoyDPadType.ALL_DIRECTIONS

export(String) var action_up: String = TNTInputEngine.ACTION_JOY_UP
export(String) var action_right: String = TNTInputEngine.ACTION_JOY_RIGHT
export(String) var action_down: String = TNTInputEngine.ACTION_JOY_DOWN
export(String) var action_left: String = TNTInputEngine.ACTION_JOY_LEFT

func _ready() -> void:
	._ready()
	_dead_size = dead_zone * _ray 

	_act_down = action_down
	_act_left = action_left
	_act_right = action_right
	_act_up = action_up
		
	_act_up = TNTInputEngine._add_binding("U", _act_up)
	_act_right = TNTInputEngine._add_binding("R", _act_right)
	_act_down = TNTInputEngine._add_binding("D", _act_down)
	_act_left = TNTInputEngine._add_binding("L", _act_left)
	
	if action_up == "":
		action_up = _act_up
	if action_down == "":
		action_down = _act_down
	if action_left == "":
		action_left = _act_left
	if action_right == "":
		action_right = _act_right
	
	_current_direction = JoyDirection.NONE
	_output = Vector2.ZERO

func _reset() -> void:
	._reset()
	_output = Vector2.ZERO

func _input(event: InputEvent, emit_event: bool = false) -> void:
	._input(event, true)

func _update_control(event_position: Vector2, emit_action: bool = true) -> void:
	if !_dimmer_active:
		_texture_1.modulate.a = TNTInputEngine.full_alpha

	var _center: Vector2 = _texture_1.rect_global_position + (_cscale * _texture_1.rect_size * 0.5)
	var _vector: Vector2 = event_position - _center

	if _vector.length() > _dead_size:
		var clamp_size: float = clamp_zone * _ray
		if Dpad_directions == JoyDPadType.ALL_DIRECTIONS:
			_vector = TNTInputEngine._directional_vector(_vector, 8, 0)
		elif Dpad_directions == JoyDPadType.LEFT_RIGHT:
			_vector = TNTInputEngine._directional_vector(_vector, 2, PI)
		elif Dpad_directions == JoyDPadType.UP_DOWN:
			_vector = TNTInputEngine._directional_vector(_vector, 2, PI * 0.5)
		
		if vector_mode == VectorMode.NORMALIZED:
			_output = _vector.normalized()
			TNTInputEngine._center_control(_texture_2, _output * clamp_size + _center, _cscale)
		elif vector_mode == VectorMode.REAL:
			var clamped_vector: Vector2 = _vector.clamped(clamp_size)
			_output = _vector.normalized() * (clamped_vector.length() - _dead_size) / (clamp_size - _dead_size)
			TNTInputEngine._center_control(_texture_2, clamped_vector + _center, _cscale)
		if control_mode == ControlMode.FOLLOWING:
			TNTInputEngine._following(_vector, 2.25, rect_size * _cscale, _texture_1)
			
		if abs(_output.x) < _TOZERO:
			_output.x = 0
		if abs(_output.y) < _TOZERO:
			_output.y = 0

		if _output.x > 0:
			Input.action_press(_act_right, _output.x)
			_current_direction = _current_direction | JoyDirection.RIGHT
			if _current_direction & JoyDirection.LEFT:
				Input.action_release(_act_left)	
			if (_output.y) == 0:
				if _current_direction & JoyDirection.UP:
					Input.action_release(_act_up)
					_current_direction = _current_direction ^ JoyDirection.UP
				elif _current_direction & JoyDirection.DOWN:
					Input.action_release(_act_down)
					_current_direction = _current_direction ^ JoyDirection.DOWN
		elif _output.x < 0:
			Input.action_press(_act_left, _output.x)
			_current_direction = _current_direction | JoyDirection.LEFT
			if _current_direction & JoyDirection.RIGHT:
				Input.action_release(_act_right)
				_current_direction = _current_direction ^ JoyDirection.RIGHT
			if (_output.y) == 0:
				if _current_direction & JoyDirection.UP:
					Input.action_release(_act_up)
					_current_direction = _current_direction ^ JoyDirection.UP
				elif _current_direction & JoyDirection.DOWN:
					Input.action_release(_act_down)
					_current_direction = _current_direction ^ JoyDirection.DOWN
					
		if _output.y > 0:
			Input.action_press(_act_down, _output.y)
			_current_direction = _current_direction | JoyDirection.DOWN
			if _current_direction & JoyDirection.UP:
				Input.action_release(_act_up)
				_current_direction = _current_direction ^ JoyDirection.UP
			if (_output.x) == 0:
				if _current_direction & JoyDirection.LEFT:
					Input.action_release(_act_left)
					_current_direction = _current_direction ^ JoyDirection.LEFT
				elif _current_direction & JoyDirection.RIGHT:
					Input.action_release(_act_right)
					_current_direction = _current_direction ^ JoyDirection.RIGHT
		elif _output.y < 0:
			Input.action_press(_act_up, _output.y)
			_current_direction = _current_direction | JoyDirection.UP
			if _current_direction & JoyDirection.DOWN:
				Input.action_release(_act_down)
				_current_direction = _current_direction ^ JoyDirection.DOWN
			if (_output.x) == 0:
				if _current_direction & JoyDirection.LEFT:
					Input.action_release(_act_left)
					_current_direction = _current_direction ^ JoyDirection.LEFT
				elif _current_direction & JoyDirection.RIGHT:
					Input.action_release(_act_right)
					_current_direction = _current_direction ^ JoyDirection.RIGHT
	else:
		_output = Vector2.ZERO
		if _current_direction == (_current_direction | JoyDirection.RIGHT):
			Input.action_release(_act_right)
		if _current_direction == (_current_direction | JoyDirection.LEFT):
			Input.action_release(_act_left)
		if _current_direction == (_current_direction | JoyDirection.UP):
			Input.action_release(_act_up)
		if _current_direction == (_current_direction | JoyDirection.DOWN):
			Input.action_release(_act_down)
		_current_direction = JoyDirection.NONE
		TNTInputEngine._reset_handle(_texture_1, _texture_2, _cscale)
