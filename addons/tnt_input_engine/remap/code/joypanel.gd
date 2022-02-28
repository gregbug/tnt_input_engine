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

onready var lblDeadZone: Label = $Panel/lblDeadZone
onready var dead_zone_slider: Slider = $Panel/HSlider

var wait_for_button: String = ""
var joy_num: int = -1
var joy_GUID: String = ""

var _check_left: bool = false
var _check_left_done: bool = false
var _check_up: bool = false
var _check_up_done: bool = false

var _joyleft: Array
var _joyright: Array
var _deadzone: float

var _xjoy_btn: int = -1
var _yjoy_btn: int = -1

func _ready() -> void:
	_joyleft.clear()
	_joyright.clear()
	
	Input.remove_joy_mapping(joy_GUID)
	
	var screen_size: Vector2 = 	get_viewport_rect().size
	$Panel.rect_position.x = (screen_size.x / 2) - ($Panel.rect_size.x / 2)
	$Panel.rect_position.y = (screen_size.y / 2) - ($Panel.rect_size.y / 2)

	$Panel/lblWait.text = "...move "+wait_for_button+" analog joy..."
	$Panel/Spinner/AnimationPlayer.play("rotate")

	if TNTInputEngine._buttons_map_binding.get("JOYLEFTX+") != null:
		_joyleft = TNTInputEngine._buttons_map_binding.get("JOYLEFTX+")
	if TNTInputEngine._buttons_map_binding.get("JOYRIGHTX+") != null:
		_joyright = TNTInputEngine._buttons_map_binding.get("JOYRIGHTX+")
	
	if _joyleft.size() > 2:
		dead_zone_slider.value = _joyleft[2]
	if _joyright.size() > 2:
		dead_zone_slider.value = _joyright[2]
		
	$Panel/Spinner.position.y = $Panel/lblResultLeft.rect_position.y+6

func _process(delta: float) -> void:
	_deadzone = dead_zone_slider.value
	lblDeadZone.text = "Dead Zone: "+str(_deadzone)
	
	if !(_check_left && _check_up):
		for axis in range(JOY_ANALOG_LX, JOY_ANALOG_RY+1):
			var axis_value: float = Input.get_joy_axis(TNTInputEngine.get_active_joy_id(), axis)
			if abs(axis_value) > .5:	
				if (_joyleft != null):
					if (axis == JOY_ANALOG_LX) && (!_check_left):
						if !axis_already_assigned(axis):
							_check_left = true
							_xjoy_btn = axis
							_joyleft[2] = _deadzone
							$Panel/lblResultLeft.text = "Move Left: DETECTED OK."
							break
					elif (axis == JOY_ANALOG_LY) && (!_check_up):
						if !axis_already_assigned(axis):
							_check_up = true
							_yjoy_btn = axis
							_joyleft[2] = _deadzone
							$Panel/lblResultUp.text = "Move Up: DETECTED OK."
							break
				if (_joyright != null):
					if axis == JOY_ANALOG_RX && !_check_left:
						if !axis_already_assigned(axis):
							_check_left = true
							_xjoy_btn = axis
							_joyright[2] = _deadzone
							$Panel/lblResultLeft.text = "Move Left: DETECTED OK."
							break		
					elif axis == JOY_ANALOG_RY && !_check_up:
						if !axis_already_assigned(axis):
							_check_up = true
							_yjoy_btn = axis
							_joyright[2] = _deadzone
							$Panel/lblResultUp.text = "Move Up: DETECTED OK."
							break
		
	if _check_left:
		if !_check_left_done:
			_check_left_done = true
			$Panel/Spinner.hide()
			set_process(false)
			yield(get_tree().create_timer(1), "timeout")
			set_process(true)
			$Panel/Spinner.position.y = $Panel/lblResultUp.rect_position.y+6
			$Panel/Spinner.show()
		
	if _check_up:
		if !_check_up_done:
			_check_up_done = true
			$Panel/Spinner.hide()
			set_process(false)
			yield(get_tree().create_timer(1), "timeout")
			set_process(true)
			$Panel/Spinner.position.y = $Panel/lblResultLeft.rect_position.y+6
			$Panel/Spinner.show()
		
	if _check_left && _check_up:
		$Panel/Spinner/AnimationPlayer.stop()
		$Panel/Spinner.hide()
		$Panel/btnApply.disabled = false
		
func axis_already_assigned(axis: int) -> bool:
#	print(axis)
#	print(((axis == _xjoy_btn) || (axis == _yjoy_btn)))
	return ((axis == _xjoy_btn) || (axis == _yjoy_btn))

func _on_btnCancel_pressed() -> void:
	get_tree().set_input_as_handled()
	TNTInputEngine.emit_signal("cancel_mapping")
	queue_free()

func _on_btnApply_pressed() -> void:
	get_tree().set_input_as_handled()
	TNTInputEngine.emit_signal("mapped", wait_for_button, _xjoy_btn, _yjoy_btn)
	queue_free()
