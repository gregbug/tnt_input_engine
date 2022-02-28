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

extends Node

const _JOYDB_PATH: String = "user://JOYDB/"

const remap_design_width: int = 800
const remap_design_height: int = 600

const _PLATFORMS: Dictionary = {
	# From gamecontrollerdb
	"Windows": "Windows",
	"OSX": "Mac OS X",
	"X11": "Linux",
	"Android": "Android",
	"iOS": "iOS",
	# Godot users
	"HTML5": "Javascript",
	"UWP": "UWP",
	# 4.x compat
	"Linux": "Linux",
	"FreeBSD": "Linux",
	"NetBSD": "Linux",
	"BSD": "Linux",
	"macOS": "Mac OS X",
}

const ACTION_JOY_A: String = "joy_a"
const ACTION_JOY_B: String = "joy_b"
const ACTION_JOY_Y: String = "joy_y"
const ACTION_JOY_X: String = "joy_x"
const ACTION_JOY_START: String = "joy_start"
const ACTION_JOY_SELECT: String = "joy_select"
const ACTION_JOY_L2: String = "joy_l2"
const ACTION_JOY_R2: String = "joy_r2"
const ACTION_JOY_L1: String = "joy_l1"
const ACTION_JOY_R1: String = "joy_r1"
const ACTION_JOY_UP: String = "joy_up"
const ACTION_JOY_LEFT: String = "joy_left"
const ACTION_JOY_DOWN: String = "joy_down"
const ACTION_JOY_RIGHT: String = "joy_right"
const ACTION_LEFTAXIS_UP: String = "axis_lefty-"
const ACTION_LEFTAXIS_RIGHT: String = "axis_leftx+"
const ACTION_LEFTAXIS_DOWN: String = "axis_lefty+"
const ACTION_LEFTAXIS_LEFT: String = "axis_leftx-"
const ACTION_RIGHTAXIS_UP: String = "axis_righty-"
const ACTION_RIGHTAXIS_RIGHT: String = "axis_rightx+"
const ACTION_RIGHTAXIS_DOWN: String = "axis_righty+"
const ACTION_RIGHTAXIS_LEFT: String = "axis_rightx-"

const DEFAULT_MAPPING: Dictionary = {
	# Action Buttons
	"A": [JOY_BUTTON_1, "a", ACTION_JOY_A],
	"B": [JOY_BUTTON_0, "b", ACTION_JOY_B],
	"Y": [JOY_BUTTON_3, "y", ACTION_JOY_Y],
	"X": [JOY_BUTTON_2, "x", ACTION_JOY_X],
	# Game cntrol buttons
	"START": [JOY_START, "start", ACTION_JOY_START],
	"SELECT": [JOY_SELECT, "back", ACTION_JOY_SELECT],
	# Trigger Buttons
	"L2": [JOY_L2, "lefttrigger", ACTION_JOY_L2],
	"R2": [JOY_R2, "righttrigger", ACTION_JOY_R2],
	"L1": [JOY_L, "leftshoulder", ACTION_JOY_L1],
	"R1": [JOY_R, "rightshoulder", ACTION_JOY_R1],
	# Direction buttons
	"U": [JOY_DPAD_UP, "dpup", ACTION_JOY_UP],
	"L": [JOY_DPAD_LEFT, "dpleft", ACTION_JOY_LEFT],
	"D": [JOY_DPAD_DOWN, "dpdown", ACTION_JOY_DOWN],
	"R": [JOY_DPAD_RIGHT, "dpright", ACTION_JOY_RIGHT],
	# Left Analog joy Axis
	"JOYLEFTX+": [JOY_AXIS_0, "leftx", 0.5, ACTION_LEFTAXIS_RIGHT],
	"JOYLEFTY+": [JOY_AXIS_1, "lefty", 0.5, ACTION_LEFTAXIS_DOWN],
	"JOYLEFTX-": [JOY_AXIS_0, "leftx", 0.5, ACTION_LEFTAXIS_LEFT],
	"JOYLEFTY-": [JOY_AXIS_1, "lefty", 0.5, ACTION_LEFTAXIS_UP],
	# Right Analog joy Axis
	"JOYRIGHTX+": [JOY_AXIS_2, "rightx", 0.5, ACTION_RIGHTAXIS_RIGHT],
	"JOYRIGHTY+": [JOY_AXIS_3, "righty", 0.5, ACTION_RIGHTAXIS_DOWN],
	"JOYRIGHTX-": [JOY_AXIS_2, "rightx", 0.5, ACTION_RIGHTAXIS_LEFT],
	"JOYRIGHTY-": [JOY_AXIS_3, "righty", 0.5, ACTION_RIGHTAXIS_UP]
}

signal mapped(button_name, button_key_value)
signal cancel_mapping()
signal hw_joy_connection_changed(device_id, connected)
signal map_button(button_name, button_key_value)
signal save_map()
signal reset_map()
signal close_mapping()

enum ControlDrawMode {FIXED, AUTO_DIMMED}
enum VisibilityMode {ALWAYS, TOUCHSCREEN_ONLY, IF_NOT_JOYDEVICE_BUT_TOUCH_SCREEN }
enum btnType {BUTTON, ANALOGIC_JOY}
enum joy {DPAD, JOY_LEFT, JOY_RIGHT, BTN_A, BTN_B, BTN_X, BTN_Y, SELECT, START, L1, L2, R1, R2}

export(ControlDrawMode) var draw_mode: int = ControlDrawMode.AUTO_DIMMED
export(float, 0.1, 1) var full_alpha: float = 1
export(float, 0, 0.8) var dimmed_alpha: float = 0.4
export(float, .2, 5) var dimmer_time: float = 2
export(VisibilityMode) var visibility_mode: int = VisibilityMode.ALWAYS

var _connected_devices_count: int = 0
var _connected_devices_info: Array
var _buttons_map_binding: Dictionary = {} # Creates an empty dictionary.
var _current_joy_device_id: int = -1 

# ------------------------------------------------------------------------ #

func _init() -> void:  
	_init_devices_info()
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	_clear_buttons_binding()

func _init_devices_info() -> void:
	_connected_devices_count = get_connected_devices_count()
	_connected_devices_info = get_connected_devices_info()
	
	if _connected_devices_count < 1:
		_current_joy_device_id = -1
	else:
		# if one joy present setas default one...
		set_active_joy_id(get_device_id(1))

func open_hw_joy_remap(device_id: int) -> void:
	var root = get_tree().get_root()
	var _current_scene = root.get_child(root.get_child_count() - 1)
	var remap_scene: Object = ResourceLoader.load("res://addons/tnt_input_engine/remap/remap.tscn")
	var _remap_scene: Node = remap_scene.instance()
	_remap_scene._back_scene = get_tree().current_scene.filename
	set_active_joy_id(device_id)
	
	get_tree().get_root().add_child(_remap_scene)
	get_tree().set_current_scene(_remap_scene)
	call_deferred("_free_current_scene", _current_scene)

func _free_current_scene(current_scene: Node) -> void:
	current_scene.queue_free()

# ------------------------------------------------------------------------ #

func _add_binding(key_name: String, action: String = "", analog_deadzone: float = 0.5) -> String:
	if key_name == "":
		return ""
	
	var btn: Array = []
	
	if DEFAULT_MAPPING.get(key_name) != null:           
		btn = DEFAULT_MAPPING.get(key_name)
	
	if btn.size() == 0:
		return ""

	key_name = key_name.to_upper()
	if key_name == "JOYLEFTX+":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYLEFTX+"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], 1)
		return btn[3]
	elif key_name == "JOYLEFTX-":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYLEFTX-"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], -1)
		return btn[3]
	elif key_name == "JOYLEFTY+":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYLEFTY+"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], 1)
		return btn[3]
	elif key_name == "JOYLEFTY-":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYLEFTY-"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], -1)
		return btn[3]
	elif key_name == "JOYRIGHTX+":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYRIGHTX+"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], 1)
		return btn[3]
	elif key_name == "JOYRIGHTX-":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYRIGHTX-"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], -1)
		return btn[3]
	elif key_name == "JOYRIGHTY+":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYRIGHTY+"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], 1)
		return btn[3]
	elif key_name == "JOYRIGHTY-":
		btn[2] = analog_deadzone
		if action != "":
			btn[3] = action
		_buttons_map_binding["JOYRIGHTY-"] = btn
		_add_joy_axis_action(btn[3], btn[0], btn[2], 1)
		return btn[3]
			
	if action != "":
		btn[2] = action
	_buttons_map_binding[key_name] = btn
	_add_joy_button_action(btn[2], btn[0])
	return btn[2]
	
func _clear_buttons_binding() -> void:
	_buttons_map_binding.clear()

func _add_joy_button_action(action_name: String, button_index: int) -> void:
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.button_index = button_index
	if !InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)

func _add_joy_axis_action(action_name: String, axis: int, dead_zone: float, default_axis_value: float = 0) -> void:
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name, dead_zone)
	
	var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = default_axis_value
	
	if !InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)
		InputMap.action_set_deadzone(action_name, dead_zone)
		
func add_key_binding(key_scancode: int, action_name: String) -> void:
	if action_name == "":
		return
	
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.5)
	
	var event: InputEventKey = InputEventKey.new()
	event.scancode = key_scancode
	event.pressed = true
	if !InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)
		
func add_joy_binding(button: int, action: Array = ["", "", "", ""], dead_zone: float = 0.5) -> void:
	var key_name: String = ""
	match button:
		joy.JOY_LEFT:
			_add_binding("JOYLEFTX+", action[0], dead_zone)
			_add_binding("JOYLEFTY+", action[1], dead_zone)
			_add_binding("JOYLEFTX-", action[0], dead_zone)
			_add_binding("JOYLEFTY-", action[1], dead_zone)
			return
			
		joy.JOY_LEFT:
			_add_binding("JOYRIGHTX+", action[0], dead_zone)
			_add_binding("JOYRIGHTY+", action[1], dead_zone)
			_add_binding("JOYRIGHTX-", action[0], dead_zone)
			_add_binding("JOYRIGHTY-", action[1], dead_zone)
			return
			
		joy.DPAD:
			_add_binding("U", action[0])
			_add_binding("R", action[1])
			_add_binding("D", action[2])
			_add_binding("L", action[3])
			return
			
		joy.BTN_A:
			key_name = "A"
		joy.BTN_B:
			key_name = "B"
		joy.BTN_X:
			key_name = "X"
		joy.BTN_Y:
			key_name = "Y"
		joy.START:
			key_name = "START"
		joy.SELECT:
			key_name = "SELECT"
		joy.L1:
			key_name = "L1"
		joy.L2:
			key_name = "L2"
		joy.R1:
			key_name = "R1"
		joy.R2:
			key_name = "R2"
			
	_add_binding(key_name, action[0])
		
# ------------------------------------------------------------------------ #

func load_user_dbfile_joy_mapping(joy_guid: String) -> int:
	var io_result: int = OK	
	var file: File = File.new()
	
	if file.file_exists(_JOYDB_PATH+joy_guid+".db"):
		io_result = file.open(_JOYDB_PATH+joy_guid+".db", File.READ)
		if io_result == OK:
			_buttons_map_binding.clear()
			_buttons_map_binding = str2var(file.get_as_text())
	else:
		io_result = ERR_FILE_NOT_FOUND
	
	file.close()
	return io_result

func save_user_dbfile_joy_mapping(joy_guid: String) -> int:
	var io_result: int = OK
	var dir = Directory.new()
	
	if !dir.dir_exists(_JOYDB_PATH):
		io_result = dir.make_dir(_JOYDB_PATH)
		if io_result != OK:
			return io_result

	var file: File = File.new()
	io_result = file.open(_JOYDB_PATH+joy_guid+".db", File.WRITE)
	if io_result == OK:
		file.store_string(var2str(_buttons_map_binding))
	file.close()
		
	return io_result

func delete_dbfile(joy_guid: String) -> int:
	var io_result: int = OK	
	var dir = Directory.new()
	io_result = dir.remove(_JOYDB_PATH+joy_guid+".db")
	return io_result

func user_dbfile_joy_exist(joy_guid: String) -> bool:
	var file: File = File.new()
	var result: bool = file.file_exists(_JOYDB_PATH+joy_guid+".db")
	file.close()
	return result

func reset_to_default() -> void:			
	for key_name in _buttons_map_binding:
			for default_key_name in DEFAULT_MAPPING:
				if key_name == default_key_name:
					var usr_map: Array = _buttons_map_binding.get(key_name)
					var dfl_map: Array = DEFAULT_MAPPING.get(default_key_name)
					if dfl_map.size() == 4:
						usr_map[0] = dfl_map[0]
						usr_map[3] = dfl_map[3]						
					else:
						usr_map[0] = dfl_map[0]
						usr_map[2] = dfl_map[2]
					break
					
func generate_joy_mapping(joy_guid: String, joy_name: String, user: bool = true) -> String:
	var string = "%s,%s," % [joy_guid, joy_name]
	var m: Array
	for k in _buttons_map_binding:
		if user:
			m = _buttons_map_binding[k]
		else:
			m = DEFAULT_MAPPING[k]
			
		if m[1] == "leftx" || m[1] == "lefty" || m[1] == "rightx" || m[1] == "righty":
			if string.find(m[1]) == -1:
				string += "%s:a%s," % [str(m[1]), str(m[0])]
		else:
			string += "%s:b%s," % [str(m[1]), str(m[0])]

	var platform = "Unknown"
	if _PLATFORMS.keys().has(OS.get_name()):
		platform = _PLATFORMS[OS.get_name()]
		
	return string + "platform:" + platform
	
func load_and_apply_joy_db(device_id: int) -> int:
	reset_to_default()
	if user_dbfile_joy_exist(get_device_GUID(get_device_id(device_id))):
	#	print("mapping exists...")
		if load_user_dbfile_joy_mapping(get_device_GUID(get_device_id(device_id))) == OK:
		#	print("mapping db loaded..")
			apply_joy_mapping(get_device_GUID(get_device_id(device_id)), get_device_name(get_device_id(device_id)))
		#	print("mapping db applyed...")
			return OK
		else:
		#	print("error mapping joy db ...")
			return ERR_FILE_NOT_FOUND
	else:
		#print("NO mapping db joy found...")
		return ERR_FILE_NOT_FOUND

func apply_joy_mapping(joy_guid: String, joy_name: String, custom_mapping: bool = true) -> void:
	var mapping: Dictionary
	Input.remove_joy_mapping(joy_guid)
	if custom_mapping:
		mapping = _buttons_map_binding
		Input.add_joy_mapping(generate_joy_mapping(joy_guid, joy_name), true)
	else:
		mapping = DEFAULT_MAPPING
		Input.add_joy_mapping(generate_joy_mapping(joy_guid, joy_name, false), false)

	for key_name in mapping:
		match key_name:
			"JOYLEFTX+", "JOYLEFTX-", "JOYLEFTY+", "JOYLEFTY-", "JOYRIGHTX+", "JOYRIGHTX-", "JOYRIGHTY+", "JOYRIGHTY-":
				if mapping.get(key_name) != null:           
					var btn: Array = mapping.get(key_name)
					if btn.size() > 2:
						_add_binding(key_name, btn[3], btn[2])
			_: if mapping.get(key_name) != null:    
					var btn: Array = mapping.get(key_name)
					if btn.size() > 1:
						_add_binding(key_name, btn[2])
	
# ------------------------------------------------------------------------ #

func set_active_joy_id(id: int) -> void:
	_current_joy_device_id = id

func get_active_joy_id() -> int:
	return _current_joy_device_id

func get_connected_devices_count() -> int:
	return Input.get_connected_joypads().size()	

func get_connected_devices_info() -> Array:
	return Input.get_connected_joypads()

func get_device_id(device_index: int) -> int:
	if get_connected_devices_count() == 0:
		return -1
	elif get_connected_devices_count()-1 >= device_index:
		return _connected_devices_info[device_index]
	return -1
	
func get_device_name(device_id: int) -> String:
	if (device_id >= 0):
		return Input.get_joy_name(device_id)
	else:
		return ""

func get_device_GUID(device_id: int) -> String:
	if (device_id >= 0):
		return Input.get_joy_guid(device_id)
	else:
		return ""
	
func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	_init_devices_info()
	emit_signal("hw_joy_connection_changed", device_id, connected)
	
# -----------------------------------------------------------------------------------------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------------------------------------------------------------------------------------

func _is_inside_control_rect(global_position: Vector2, control: Control) -> bool:
	if global_position.x > control.rect_global_position.x && (global_position.x < control.rect_global_position.x + (control.rect_size.x * control.rect_scale.x)):
		if global_position.y > control.rect_global_position.y && (global_position.y < control.rect_global_position.y + (control.rect_size.y * control.rect_scale.y)):
			return true
	return false 

func _directional_vector(vector: Vector2, n_directions: int, _symmetry_angle: float = PI * 0.5) -> Vector2:
	var directions: float = PI / n_directions
	var angle: float = (vector.angle() + _symmetry_angle) / (directions)
	angle = floor(angle) if angle >= 0 else ceil(angle)
	if abs(angle) as int % 2 == 1:
		angle = angle + 1 if angle >= 0 else angle - 1
	angle *= directions
	angle -= _symmetry_angle
	return Vector2(cos(angle), sin(angle)) * vector.length()
	
func _center_control(control: Control, new_global_position: Vector2, scale: Vector2 = Vector2(1, 1)) -> void:	
	control.rect_global_position = new_global_position - ((scale * control.rect_size) * 0.5)

func _reset_handle(texture_1: TextureRect, texture_2: TextureRect, scale: Vector2 = Vector2(1, 1)) -> void:
	_center_control(texture_2, texture_1.rect_global_position + ((scale * texture_1.rect_size) * 0.5), scale)

func _following(vector: Vector2, clamp_zone: float, control_rect_size: Vector2, texture_1: TextureRect) -> void:
	var half_txtr_size_x: float = texture_1.rect_size.x * 0.5
	var clamp_size: float = clamp_zone * half_txtr_size_x
	if vector.length() > clamp_size:
		var radius: Vector2 = vector.normalized() * clamp_size
		var delta: Vector2 = vector - radius
		var new_pos: Vector2 = texture_1.rect_position + delta
		var half_txtr_size_y: float = texture_1.rect_size.y * 0.5
		new_pos.x = clamp(new_pos.x, - half_txtr_size_x, control_rect_size.x - half_txtr_size_x)
		new_pos.y = clamp(new_pos.y, - half_txtr_size_y, control_rect_size.y - half_txtr_size_y)
		texture_1.rect_position = new_pos

func _screen_is_landscape(screen_size: Vector2) -> bool:
	match OS.get_screen_orientation():
		OS.SCREEN_ORIENTATION_LANDSCAPE, OS.SCREEN_ORIENTATION_REVERSE_LANDSCAPE, OS.SCREEN_ORIENTATION_SENSOR_LANDSCAPE:
			return true
		OS.SCREEN_ORIENTATION_PORTRAIT, OS.SCREEN_ORIENTATION_REVERSE_PORTRAIT, OS.SCREEN_ORIENTATION_SENSOR_PORTRAIT:
			return false
		OS.SCREEN_ORIENTATION_SENSOR:
			if screen_size.x > screen_size.y:
				return true
			else:
				return false
		_:
			return true
