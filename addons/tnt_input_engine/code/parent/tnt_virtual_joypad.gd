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
class_name TNT_Virtual_JoyPad

const _TOZERO: float = 0.05

enum ControlMode {FIXED, DYNAMIC, FOLLOWING}
enum VectorMode {REAL, NORMALIZED}
enum JoyDirection {NONE, LEFT = 2, RIGHT = 4, UP = 8, DOWN = 16}

export(ControlMode) var control_mode: int = ControlMode.FIXED
export(Color) var _color: Color = Color.white setget set_vpad_color, get_vpad_color
export(Color) var _pressed_color: Color = Color.white
export(VectorMode) var vector_mode: int = VectorMode.REAL
export(float, 0.5, 2) var clamp_zone: float = 1.0
export(float, 0, 0.9) var dead_zone: float = 0.5

onready var _texture_1: TextureRect = $Texture_1
onready var _texture_2: TextureRect = $Texture_1/Texture_2
onready var _original_position: Vector2 = _texture_1.rect_position

var real_control_connected: bool = false 			# if real control is connected
var virtual_control_active: bool = false 			# if virtual control is active

# internal variables ##############################################
var _ray: float = 0
var _touch_index: int = -1
var _cscale: Vector2 = Vector2(1, 1)
var _dimmer_active: bool = false
var _is_pressing: bool = false

var _strength: float = 0
var _output: Vector2 = Vector2.ZERO

var _dead_size: float = 0

var _action: String = ""
var _act_up: String = ""
var _act_down: String = ""
var _act_left: String = ""
var _act_right: String = ""
var _current_direction: int = JoyDirection.NONE

func set_vpad_color(new_color: Color) -> void:
	_color = new_color
	
func get_vpad_color() -> Color:
	return _color

func set_vpad_pressed_color(new_color: Color) -> void:
	_pressed_color = new_color

func get_vpad_pressed_color() -> Color:
	return _pressed_color

func _touch_started(event: InputEventScreenTouch) -> bool:
	return event.pressed && _touch_index == -1

func _touch_ended(event: InputEventScreenTouch) -> bool:
	return not event.pressed && _touch_index == event.index

func _reset() -> void:
	_touch_index = -1
	_is_pressing = false
	
	_texture_2.self_modulate = get_vpad_pressed_color()
	_texture_1.self_modulate = get_vpad_color()
	
	_texture_1.rect_position = _original_position

	TNTInputEngine._reset_handle(_texture_1, _texture_2, _cscale)
	
	if virtual_control_active:
		_start_dimmer()
	
	if _current_direction == JoyDirection.NONE:
		Input.action_release(_action)
	
	if 	_current_direction != JoyDirection.NONE:
		if _current_direction == (_current_direction | JoyDirection.RIGHT):
			Input.action_release(_act_right)
		if _current_direction == (_current_direction | JoyDirection.LEFT):
			Input.action_release(_act_left)
		if _current_direction == (_current_direction | JoyDirection.UP):
			Input.action_release(_act_up)
		if _current_direction == (_current_direction | JoyDirection.DOWN):
			Input.action_release(_act_down)
		_current_direction = JoyDirection.NONE
		
func _ready() -> void:
	if TNTInputEngine != null:	
		_init_control()
		_reset()
		_ray  = ($Texture_1.rect_size.x * $Texture_1.get_parent().rect_scale.x) * 0.5
		_cscale = $Texture_1.get_parent().rect_scale

func _init_control() -> void:
	real_control_connected = TNTInputEngine.get_connected_devices_count()
	hide()
		
	virtual_control_active = false

	_is_pressing = false
	
	match TNTInputEngine.visibility_mode:
	# if joypad present use real one, use virtual if not real joy touch present
		TNTInputEngine.VisibilityMode.IF_NOT_JOYDEVICE_BUT_TOUCH_SCREEN:
			if !real_control_connected && OS.has_touchscreen_ui_hint():
				show()
				virtual_control_active = true
		
		TNTInputEngine.VisibilityMode.TOUCHSCREEN_ONLY:
			if OS.has_touchscreen_ui_hint():
				show()
				virtual_control_active = true

		TNTInputEngine.VisibilityMode.ALWAYS:
			show()
			if OS.has_touchscreen_ui_hint():
				virtual_control_active = true
	
	if !virtual_control_active:
		set_process_input(false)
	else:
		set_process_input(true)

func _start_dimmer() -> void:
	if TNTInputEngine.draw_mode == TNTInputEngine.ControlDrawMode.FIXED || _dimmer_active:
		_texture_1.modulate.a = TNTInputEngine.full_alpha
		return
	
	_texture_1.modulate.a = TNTInputEngine.full_alpha
	
	if !_is_pressing:
		yield(get_tree().create_timer(TNTInputEngine.dimmer_time), "timeout")
		if !_is_pressing:
			_dimmer_active = true
			_texture_1.modulate.a = TNTInputEngine.dimmed_alpha
			_dimmer_active = false

func _update_control(event_position: Vector2, emit_action: bool = true) -> void:
	pass

func _input(event: InputEvent, emit_event: bool = false) -> void:
	if !(event is InputEventScreenTouch || event is InputEventScreenDrag):
		return
	if (event is InputEventScreenTouch):
		if _touch_started(event) && TNTInputEngine._is_inside_control_rect(event.position, self):
			if (control_mode == ControlMode.DYNAMIC || control_mode == ControlMode.FOLLOWING):
				TNTInputEngine._center_control(_texture_1, event.position, _cscale)
			if Geometry.is_point_in_circle(event.position, _texture_1.rect_global_position + Vector2(_ray, _ray), _ray):
				_touch_index = event.index
				_texture_2.self_modulate = get_vpad_pressed_color()
				_is_pressing = true
				_update_control(event.position)
		elif _touch_ended(event):
			_reset()
	elif event is InputEventScreenDrag && _touch_index == event.index:
		_update_control(event.position, emit_event)
