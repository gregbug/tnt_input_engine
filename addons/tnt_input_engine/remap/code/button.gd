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

extends TouchScreenButton

signal button_pressed(button_name)

var _process_input: bool = true
var _button_selected: bool = false

var joy_button_id_map: int = -1
var _joy_button_name: String = ""

export(TNTInputEngine.btnType) var button_type: int = TNTInputEngine.btnType.BUTTON

func _ready() -> void:
	_joy_button_name = self.name.to_upper()

func _on_Button_pressed() -> void:
	if _process_input:
		$Animation.play("selected")

func _on_Animation_finished(anim_name: String) -> void:
	TNTInputEngine.emit_signal("map_button", _joy_button_name, button_type)

func process_input(process: bool) -> void:
	_process_input = process

