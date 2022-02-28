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

tool
extends Control
class_name TNT_Input_Engine, "res://addons/tnt_input_engine/assets/icons/tnt_input_engine.png"

signal hw_joy_changed(device_id, connected)

#####################################################################
## EDITOR PROPERTIES ################################################
#####################################################################

func _get_property_list() -> Array:
	var ret: Array = []	
	ret.append(
		 {
			name = " Virtual Joypad",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY
		}
	)
	ret.append({
		"name": "VirtualJoy Visibility/Mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Always,Touch Screen Only,If not JoyPad but touch screen"
	})
	
	ret.append({
		"name": "VirtualJoy Draw/Mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Fixed,Auto Dimmed"
	})
	
	if (TNTInputEngine.draw_mode == TNTInputEngine.ControlDrawMode.AUTO_DIMMED):
		ret.append({
			"name": "VirtualJoy Draw/Full Alpha",
			"type": TYPE_REAL,               
			"min,max": "0.1, 1.0",
			"hint": PROPERTY_HINT_RANGE,    
			"hint_string": "0.1, 1.0, 0.05",               
		})
		ret.append({
			"name": "VirtualJoy Draw/Dimmed Alpha",
			"type": TYPE_REAL,               
			"min,max": "0.0, 0.8",
			"hint": PROPERTY_HINT_RANGE,   
			"hint_string": "0.0, 0.8, 0.05",               
		})
		ret.append({
			"name": "VirtualJoy Draw/Dimmer Time",
			"type": TYPE_REAL,               
			"min,max": "0.2, 5.0",
			"hint": PROPERTY_HINT_RANGE,    
			"hint_string": "0.2, 5.0, 0.1",              
		})
	return ret

func _set(prop_name: String, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	match prop_name:
		"VirtualJoy Visibility/Mode":
			TNTInputEngine.visibility_mode = val
			property_list_changed_notify()
		"VirtualJoy Draw/Mode":
			TNTInputEngine.draw_mode = val
			property_list_changed_notify()
		"VirtualJoy Draw/Full Alpha":
			TNTInputEngine.full_alpha = val
		"VirtualJoy Draw/Dimmed Alpha":
			TNTInputEngine.dimmed_alpha = val
		"VirtualJoy Draw/Dimmer Time":
			TNTInputEngine.dimmer_time = val
		_:
			retval = false
	return retval
	
func _get(prop_name: String):
	var retval = null
	match prop_name:
		"VirtualJoy Visibility/Mode":
			return TNTInputEngine.visibility_mode
		"VirtualJoy Draw/Mode":
			return TNTInputEngine.draw_mode
		"VirtualJoy Draw/Full Alpha":
			return TNTInputEngine.full_alpha
		"VirtualJoy Draw/Dimmed Alpha":
			return TNTInputEngine.dimmed_alpha
		"VirtualJoy Draw/Dimmer Time":
			return TNTInputEngine.dimmer_time
	return retval

#####################################################################
#####################################################################
#####################################################################

func _ready() -> void:
	TNTInputEngine.connect("hw_joy_connection_changed", self, "_on_joy_connection_changed")
	_check_vpad_control()

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	_check_vpad_control()
	emit_signal("hw_joy_changed", device_id, connected)

func _check_vpad_control() -> void:
	if !Engine.is_editor_hint():
		for _vpad_node in get_tree().get_nodes_in_group("tnt_input_vpad"):
			_vpad_node._init_control()
			_vpad_node._reset()
