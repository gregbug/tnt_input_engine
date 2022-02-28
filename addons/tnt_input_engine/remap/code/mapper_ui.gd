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

extends Node2D

var _back_scene: String = ""
var _save_remap: bool = false
var _close_remap: bool = true
var _clean_buttons: bool = false

onready var btn_remap: PackedScene = preload("res://addons/tnt_input_engine/remap/inputpanel.tscn")
onready var joy_remap: PackedScene = preload("res://addons/tnt_input_engine/remap/joypanel.tscn")

onready var left_stick: Node = $JoyMap/infoContainer/TopJoy/LEFT_STICK
onready var right_stick: Node = $JoyMap/infoContainer/TopJoy/RIGHT_STICK

onready var joy_stick_left_right: Sprite = $JoyMap/infoContainer/TopJoy/LRIGHT
onready var joy_stick_left_left: Sprite = $JoyMap/infoContainer/TopJoy/LLEFT
onready var joy_stick_left_up: Sprite = $JoyMap/infoContainer/TopJoy/LUP
onready var joy_stick_left_down: Sprite = $JoyMap/infoContainer/TopJoy/LDOWN

onready var joy_stick_right_right: Sprite = $JoyMap/infoContainer/TopJoy/RRIGHT
onready var joy_stick_right_left: Sprite = $JoyMap/infoContainer/TopJoy/RLEFT
onready var joy_stick_right_up: Sprite = $JoyMap/infoContainer/TopJoy/RUP
onready var joy_stick_right_down: Sprite = $JoyMap/infoContainer/TopJoy/RDOWN

func _ready() -> void:
	set_process(true)
	show_mapped_buttons()
	$JoyMap/infoContainer/lblDevice.text = ""
	$JoyMap/infoContainer/lblGUID.text = TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id())+" "+TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id())
	TNTInputEngine.connect("mapped", self, "button_mapped")
	TNTInputEngine.connect("cancel_mapping", self, "cancel_mapping")
	init_button_default()
	_save_remap = false
	TNTInputEngine.connect("map_button", self, "_on_button_pressed")
	TNTInputEngine.connect("save_map", self, "_on_btnSave_pressed")
	TNTInputEngine.connect("close_mapping", self, "_on_btnClose_pressed")
	TNTInputEngine.connect("reset_map", self, "_on_btnReset_pressed")

func _process(delta: float) -> void:
#	print(Timer)
	if _clean_buttons:	
		clean_selected_buttons()

	var joyleft: Array 
	if TNTInputEngine._buttons_map_binding.get("JOYLEFTX+") != null:
		joyleft = TNTInputEngine._buttons_map_binding.get("JOYLEFTX+")
	var joyright: Array 
	if TNTInputEngine._buttons_map_binding.get("JOYRIGHTX+") != null:
		joyright = TNTInputEngine._buttons_map_binding.get("JOYRIGHTX+")
			
	for axis in range(JOY_ANALOG_LX, JOY_ANALOG_RY+1):
		var axis_value: float = Input.get_joy_axis(TNTInputEngine.get_active_joy_id(), axis)
		
		if (joyleft.size() > 2):
			if axis == JOY_ANALOG_LX:
				if abs(axis_value) < joyleft[2]: #_deadzone_left:
					joy_stick_left_right.hide()
					joy_stick_left_left.hide()
				elif axis_value > 0:
					joy_stick_left_right.show()
					joy_stick_left_left.hide()
					show_hide_joy(true, true)
				else:
					joy_stick_left_right.hide()
					joy_stick_left_left.show()
					show_hide_joy(true, true)
	
			if axis == JOY_ANALOG_LY:
				if abs(axis_value) < joyleft[2]: #_deadzone_left:
					joy_stick_left_up.hide()
					joy_stick_left_down.hide()
				elif axis_value < 0:
					joy_stick_left_up.show()
					joy_stick_left_down.hide()
					show_hide_joy(true, true)
					continue
				else:
					joy_stick_left_up.hide()
					joy_stick_left_down.show()
					show_hide_joy(true, true)
					continue
				
		if (joyright.size() > 2):
			if axis == JOY_ANALOG_RX:
				if abs(axis_value) < joyright[2]: #_deadzone_right:
					joy_stick_right_right.hide()
					joy_stick_right_left.hide()
				elif axis_value > 0:
					joy_stick_right_right.show()
					joy_stick_right_left.hide()
					show_hide_joy(true, false)
				else:
					joy_stick_right_right.hide()
					joy_stick_right_left.show()
					show_hide_joy(true, false)
			
			if axis == JOY_ANALOG_RY:
				if abs(axis_value) < joyright[2]: #_deadzone_right:
					joy_stick_right_up.hide()
					joy_stick_right_down.hide()
				elif axis_value < 0:
					joy_stick_right_up.show()
					joy_stick_right_down.hide()
					show_hide_joy(true, false)
				else:
					joy_stick_right_up.hide()
					joy_stick_right_down.show()
					show_hide_joy(true, false)
			
	for btn in range(JOY_BUTTON_0, int(min(JOY_BUTTON_MAX, 24))):
		if Input.is_joy_button_pressed(TNTInputEngine.get_active_joy_id(), btn):
			if btn < 17:
				for _button in get_tree().get_nodes_in_group("button"):
					if _button.joy_button_id_map == btn:
						if _button.visible:
							_button.modulate = Color(1, 0, 0)
							_button._button_selected = true
							_clean_buttons = true
							break	 

func show_hide_joy(show: bool, leftstick: bool) -> void:
	if left_stick.visible:
		if leftstick:
			if show:
				left_stick.modulate = Color(1, 0, 0)
				left_stick._button_selected = true
				_clean_buttons = true
			else:
				left_stick.modulate = Color(0.04, 0.8, 0.11)
				left_stick._button_selected = false
				
	if right_stick.visible:
		if !leftstick:
			if show:
				right_stick.modulate = Color(1, 0, 0)
				right_stick._button_selected = true
				_clean_buttons = true
			else:
				right_stick.modulate = Color(0.04, 0.8, 0.11)
				right_stick._button_selected = false

func hide_mapped_buttons() -> void:
	for _button in get_tree().get_nodes_in_group("button"):
		_button.hide()

func show_mapped_buttons() -> void:
	for _button in get_tree().get_nodes_in_group("button"):
		_button.hide()
		
		for _key_binding in TNTInputEngine._buttons_map_binding:
			var btn_name: String = _button.name
			if btn_name == "LEFT_STICK":
				btn_name = "JOYLEFTX+"
			elif btn_name == "RIGHT_STICK":
				btn_name = "JOYRIGHTX+"
			if (_key_binding == btn_name):
				_button.modulate = Color(0.04, 0.8, 0.11)
				_button.show()
				_button.process_input(true)
				_button._button_selected = false
				break

func clean_selected_buttons() -> void:
	_clean_buttons = false
	for _button in get_tree().get_nodes_in_group("button"):
		for _key_binding in TNTInputEngine._buttons_map_binding:
			var btn_name: String = _button.name
			if btn_name == "LEFT_STICK":
				btn_name = "JOYLEFTX+"
			elif btn_name == "RIGHT_STICK":
				btn_name = "JOYRIGHTX+"
			if _key_binding == btn_name && _button._button_selected:
				_button.modulate = Color(0.04, 0.8, 0.11)
				_button.show()
				_button.process_input(true)
				_button._button_selected = false
				break

func init_button_default() -> void:
	$JoyMap/infoContainer/TopJoy/A.joy_button_id_map = JOY_BUTTON_0
	$JoyMap/infoContainer/TopJoy/B.joy_button_id_map = JOY_BUTTON_1
	$JoyMap/infoContainer/TopJoy/X.joy_button_id_map = JOY_BUTTON_2
	$JoyMap/infoContainer/TopJoy/Y.joy_button_id_map = JOY_BUTTON_3
	$JoyMap/infoContainer/TopJoy/U.joy_button_id_map = JOY_DPAD_UP
	$JoyMap/infoContainer/TopJoy/D.joy_button_id_map = JOY_DPAD_DOWN
	$JoyMap/infoContainer/TopJoy/L.joy_button_id_map = JOY_DPAD_LEFT
	$JoyMap/infoContainer/TopJoy/R.joy_button_id_map = JOY_DPAD_RIGHT

	$JoyMap/infoContainer/TopJoy/SELECT.joy_button_id_map = JOY_SELECT
	$JoyMap/infoContainer/TopJoy/START.joy_button_id_map = JOY_START

	$JoyMap/infoContainer/FrontJoy/L1.joy_button_id_map = JOY_L
	$JoyMap/infoContainer/FrontJoy/L2.joy_button_id_map = JOY_L2
	$JoyMap/infoContainer/FrontJoy/R1.joy_button_id_map = JOY_R
	$JoyMap/infoContainer/FrontJoy/R2.joy_button_id_map = JOY_R2
	$JoyMap/infoContainer/TopJoy/LEFT_STICK.joy_button_id_map = JOY_ANALOG_LX
	$JoyMap/infoContainer/TopJoy/RIGHT_STICK.joy_button_id_map = JOY_ANALOG_RX
	
func button_mapped(button_name: String, button_1_id: int, button_2_id: int = -1) -> void:
	set_process(true)
	for _button in get_tree().get_nodes_in_group("button"):
		_button.process_input(true)
	if (button_name == "LEFT_STICK"):
		TNTInputEngine._buttons_map_binding["JOYLEFTX+"][0] = button_1_id
		TNTInputEngine._buttons_map_binding["JOYLEFTY+"][0] = button_2_id
		TNTInputEngine.apply_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()), TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id()))
		_save_remap = true
	elif (button_name == "RIGHT_STICK"):
		TNTInputEngine._buttons_map_binding["JOYRIGHTX+"][0] = button_1_id
		TNTInputEngine._buttons_map_binding["JOYRIGHTY+"][0] = button_2_id
		TNTInputEngine.apply_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()), TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id()))
		_save_remap = true
	else:
		TNTInputEngine._buttons_map_binding[button_name][0] = button_1_id
		TNTInputEngine.apply_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()), TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id()))
		_save_remap = true

func cancel_mapping() -> void:
	set_process(true)
	for _button in get_tree().get_nodes_in_group("button"):
		_button.process_input(true)
	TNTInputEngine.apply_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()), TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id()))

func _on_button_pressed(button_name: String, button_type: int) -> void:
	for _button in get_tree().get_nodes_in_group("button"):
		_button.process_input(false)

	var rmap: Control
	if button_type == TNTInputEngine.btnType.ANALOGIC_JOY:
		rmap = joy_remap.instance()
	else:
		rmap = btn_remap.instance()
		
	rmap.wait_for_button = button_name
	rmap.joy_num = TNTInputEngine.get_active_joy_id()
	rmap.joy_GUID = TNTInputEngine.get_device_GUID(rmap.joy_num)

	add_child(rmap)
	get_tree().set_input_as_handled()
	set_process(false)

func _on_btnSave_pressed() -> void:
	if TNTInputEngine.save_user_dbfile_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id())) == OK:
		_save_remap = false
		TNTInputEngine.load_and_apply_joy_db((TNTInputEngine.get_active_joy_id()))
		#TNTInputEngine.apply_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()), TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id()))

func _on_btnReset_pressed() -> void:
	_save_remap = true
	TNTInputEngine.reset_to_default()
	TNTInputEngine.apply_joy_mapping(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()), TNTInputEngine.get_device_name(TNTInputEngine.get_active_joy_id()))
	TNTInputEngine.delete_dbfile(TNTInputEngine.get_device_GUID(TNTInputEngine.get_active_joy_id()))
	
func _on_btnClose_pressed() -> void:
	_close_remap = true	
	if _save_remap:
		$ConfirmationDialog.popup_exclusive = true
		$ConfirmationDialog.popup_centered()
	else:
		_on_ConfirmationDialog_confirmed()
		
func _on_ConfirmationDialog_confirmed() -> void:
	if _back_scene != "":
		var root = get_tree().get_root()
		var _remap_scene = root.get_child(root.get_child_count() - 1)
		
		var backscene: Object = ResourceLoader.load(_back_scene)
		var _backscene = backscene.instance()
		
		get_tree().get_root().add_child(_backscene)
		get_tree().set_current_scene(_backscene)
		
		call_deferred("_free_current_scene", _remap_scene)

func _free_current_scene(remap_scene: Node) -> void:
	remap_scene.queue_free()

